import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../core/services/order_service.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/buysawa_logo.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/credit_card_sheet.dart';
import '../profile/profile_address_screen.dart';
import '../../core/services/wallet_service.dart';
import 'payment_webview_screen.dart';
import '../../core/services/country_service.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Address State
  AddressModel? _selectedAddress;
  bool _isAddingNewAddress = false;

  // Inline Form State
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  Map<String, dynamic>? _selectedGovernorate;
  bool _isLoadingCountries = true;
  bool _showValidation = false;

  bool _isSubmitting = false;

  // Payment Method
  String _selectedPaymentMethod = 'wallet'; // wallet, cod, card

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _detailsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final provider = context.read<AddressProvider>();
    
    List<Map<String, dynamic>> list = [];
    
    try {
      // Fetch countries and addresses in parallel for speed safely
      await Future.wait([
        CountryService.getCountries().then((v) => list = v),
        if (provider.addresses.isEmpty) provider.fetchAddresses(),
      ]);
    } catch (e) {
      debugPrint('Checkout fetchData error: $e');
    }

    if (!mounted) return;
    
    if (mounted) {
      setState(() {
        _countries = list;
        _isLoadingCountries = false;

        if (provider.addresses.isNotEmpty) {
          _selectedAddress = provider.defaultAddress ?? provider.addresses.first;
          _isAddingNewAddress = true; // Always show form
          
          // Prefill form
          _cityCtrl.text = _selectedAddress!.city;
          _detailsCtrl.text = _selectedAddress!.addressLine1;
          _phoneCtrl.text = _selectedAddress!.phoneNumber ?? '';
          
          try {
            _selectedCountry = _countries.firstWhere((c) => c['name'].toString().toLowerCase() == _selectedAddress!.country.toLowerCase());
          } catch (_) {}
          
          try {
            if (_selectedCountry != null) {
              _selectedGovernorate = _currentGovernorates.firstWhere((g) => g['name'].toString().toLowerCase() == _selectedAddress!.state.toLowerCase());
            }
          } catch (_) {}

        } else {
          _isAddingNewAddress = true;
          // Defaults if no address
          try {
            _selectedCountry = _countries.firstWhere((c) => c['code'] == 'AE' || c['code'] == 'SA' || c['code'] == 'EG');
          } catch (_) {}
        }
      });
    }
  }

  List<dynamic> get _currentGovernorates {
    if (_selectedCountry == null) return [];
    return _selectedCountry!['cities'] as List? ?? [];
  }

  bool get _isInlineFormValid {
    return _selectedCountry != null &&
        _selectedGovernorate != null &&
        _cityCtrl.text.trim().isNotEmpty &&
        _detailsCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty;
  }

  void _submitOrder() async {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    if (_isAddingNewAddress) {
      setState(() => _showValidation = true);
      if (!_isInlineFormValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAr ? 'يرجى إكمال جميع بيانات العنوان' : 'Please complete all address details')),
        );
        return;
      }
    } else if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'برجاء اختيار عنوان التوصيل أولاً' : 'Please select a delivery address first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String finalPaymentMethod = _selectedPaymentMethod;
      String? targetAddressId = _selectedAddress?.id;

      if (_isAddingNewAddress) {
        final phoneCode = _selectedCountry!['phone_code'];
        String fullPhone = _phoneCtrl.text.trim();
        if (!fullPhone.startsWith('+')) {
          fullPhone = '$phoneCode $fullPhone';
        }

        AddressModel? result;
        if (_selectedAddress != null) {
          result = await context.read<AddressProvider>().updateAddress(
            id: _selectedAddress!.id,
            countryKey: _selectedCountry!['key'],
            cityKey: _cityCtrl.text.trim(),
            governorate: _selectedGovernorate!['name'],
            details: _detailsCtrl.text.trim(),
            phone: fullPhone,
          );
        } else {
          result = await context.read<AddressProvider>().addAddress(
            countryKey: _selectedCountry!['key'],
            cityKey: _cityCtrl.text.trim(), // City text as key since we have no cities API
            governorate: _selectedGovernorate!['name'],
            details: _detailsCtrl.text.trim(),
            phone: fullPhone,
            isDefault: true,
          );
        }

        if (result != null) {
          targetAddressId = result.id;
          // Update profile phone
          final auth = context.read<AuthProvider>();
          if (auth.user != null) {
            await auth.updateProfile(auth.user!.fullName, auth.user!.birthdate ?? '', phone: fullPhone);
          }
        } else {
          throw Exception(isAr ? 'فشل في حفظ العنوان الجديد' : 'Failed to save new address');
        }
      }

      if (_selectedPaymentMethod == 'card') {
        final total = context.read<CartProvider>().total;
        // 1. Top up wallet
        final paymentUrl = await WalletService.topUp(amount: total, provider: 'paymob');
        
        if (paymentUrl == null) {
          throw Exception(isAr ? 'فشل في الاتصال ببوابة الدفع' : 'Failed to connect to payment gateway');
        }

        // 2. Open WebView
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(url: paymentUrl),
          ),
        );

        if (success != true) {
          throw Exception(isAr ? 'تم إلغاء عملية الدفع' : 'Payment was cancelled');
        }

        // 3. If success, we change payment method to wallet to complete the order
        finalPaymentMethod = 'wallet';
      }

      // Checkout directly with selected address and finalized payment method
      final result = await OrderService.checkout(
        shippingAddressId: targetAddressId!,
        paymentMethod: finalPaymentMethod, 
      );

      if (result.order != null && mounted) {
        // Clear cart and show success
        context.read<CartProvider>().clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pop(context); // Go back to cart (which will be empty) or home
      } else {
        throw Exception(result.error ?? "Failed to place order");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';
    final cart = context.watch<CartProvider>();
    final total = cart.subtotal + 25.0; // Assume 25 AED shipping

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
        leading: isAr ? const SizedBox() : _buildShieldIcon(),
        actions: [
          if (isAr) _buildShieldIcon(),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textLight, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        title: Text(
          isAr ? 'إتمام الشراء والدفع' : 'Checkout & Payment',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(R.pad(context, 16)),
              children: [
                _buildAddressSection(isAr),
                SizedBox(height: R.pad(context, 20)),
                _buildProductsSection(cart, isAr),
                SizedBox(height: R.pad(context, 20)),
                _buildPaymentSection(isAr),
                SizedBox(height: R.pad(context, 20)),
                _buildSafeShoppingBanner(isAr),
              ],
            ),
          ),
          _buildFooter(total, isAr),
        ],
      ),
    );
  }

  Widget _buildShieldIcon() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 16),
      ),
    );
  }

  // ─── Address Section ────────────────────────────────────────────────────────
  Widget _buildAddressSection(bool isAr) {
    final provider = context.watch<AddressProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(R.pad(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'عنوان الشحن' : 'Shipping Address',
                    style: TextStyle(
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (provider.isLoading && provider.addresses.isEmpty && !_isAddingNewAddress)
            const Center(child: CircularProgressIndicator())
          else
            _buildInlineAddressForm(isAr),
        ],
      ),
    );
  }

  Widget _buildInlineAddressForm(bool isAr) {
    if (_isLoadingCountries) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: isAr ? 'الدولة *' : 'Country *',
                hint: isAr ? 'اختر الدولة' : 'Select Country',
                value: _selectedCountry,
                items: _countries,
                itemLabel: (c) => c['name'],
                isError: _showValidation && _selectedCountry == null,
                onChanged: (val) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedGovernorate = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: isAr ? 'المحافظة *' : 'Governorate *',
                hint: isAr ? 'اختر المحافظة' : 'Select Governorate',
                value: _selectedGovernorate,
                items: _currentGovernorates,
                itemLabel: (c) => c['name'],
                isError: _showValidation && _selectedGovernorate == null,
                onChanged: (val) {
                  setState(() => _selectedGovernorate = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Text(
          isAr ? 'المدينة *' : 'City *',
          style: TextStyle(fontSize: R.sp(context, 12), color: _showValidation && _cityCtrl.text.trim().isEmpty ? Colors.red : AppColors.textDark, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _showValidation && _cityCtrl.text.trim().isEmpty ? Colors.red : AppColors.border),
          ),
          child: TextField(
            controller: _cityCtrl,
            decoration: InputDecoration(
              hintText: isAr ? 'اسم المدينة (مثال: الدقي)' : 'City Name (e.g. Dokki)',
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 13)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (_showValidation && _cityCtrl.text.trim().isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(isAr ? 'المدينة مطلوبة' : 'City is required', style: const TextStyle(color: Colors.red, fontSize: 10)),
          ),
        
        const SizedBox(height: 16),
        
        Text(
          isAr ? 'العنوان التفصيلي (الشارع، المبنى، الشقة) *' : 'Detailed Address (Street, Building, Apartment) *',
          style: TextStyle(fontSize: R.sp(context, 12), color: _showValidation && _detailsCtrl.text.trim().isEmpty ? Colors.red : AppColors.textDark, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _showValidation && _detailsCtrl.text.trim().isEmpty ? Colors.red : AppColors.border),
          ),
          child: TextField(
            controller: _detailsCtrl,
            decoration: InputDecoration(
              hintText: isAr ? 'تفاصيل العنوان' : 'Detailed Address',
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 13)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          isAr ? 'رقم الهاتف *' : 'Phone Number *',
          style: TextStyle(fontSize: R.sp(context, 12), color: _showValidation && _phoneCtrl.text.trim().isEmpty ? Colors.red : AppColors.textDark, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _showValidation && _phoneCtrl.text.trim().isEmpty ? Colors.red : AppColors.border),
          ),
          child: TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '50 123 4567',
              prefixText: _selectedCountry != null ? '${_selectedCountry!['phone_code']}  ' : null,
              prefixStyle: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 13)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        
        if (_showValidation && !_isInlineFormValid)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF97316), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? 'بيانات الشحن المطلوبة غير مكتملة' : 'Required shipping information missing',
                    style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Products Section ───────────────────────────────────────────────────────
  Widget _buildProductsSection(CartProvider cart, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'المنتجات المطلوبة' : 'Ordered Products',
              style: TextStyle(
                fontSize: R.sp(context, 16),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              isAr ? '${cart.items.length} عناصر' : '${cart.items.length} items',
              style: TextStyle(
                fontSize: R.sp(context, 13),
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.product.imageUrl.isNotEmpty
                            ? CachedImage(
                                imageUrl: item.product.imageUrl.startsWith('http')
                                    ? item.product.imageUrl
                                    : 'https://buysawa.com${item.product.imageUrl.startsWith('/') ? '' : '/'}${item.product.imageUrl}',
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.image_rounded, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isAr ? item.product.arabicName : item.product.name,
                            style: TextStyle(
                              fontSize: R.sp(context, 14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr ? 'الإصدار القياسي' : 'Standard Edition',
                            style: TextStyle(
                              fontSize: R.sp(context, 11),
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.product.price.toInt()} AED',
                                style: TextStyle(
                                  fontSize: R.sp(context, 14),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isAr ? 'الكمية ${item.quantity}' : 'Qty ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: R.sp(context, 11),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Payment Methods ────────────────────────────────────────────────────────
  Widget _buildPaymentSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'طريقة الدفع' : 'Payment Method',
          style: TextStyle(
            fontSize: R.sp(context, 16),
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              _buildPaymentOption(
                id: 'wallet',
                title: isAr ? 'رصيد المحفظة' : 'Wallet Balance',
                subtitle: isAr ? 'خصم فوري' : 'Instant deduction',
                icon: Icons.account_balance_wallet_rounded,
                isAr: isAr,
              ),
              const Divider(height: 30, color: AppColors.border),
              _buildPaymentOption(
                id: 'cod',
                title: isAr ? 'الدفع عند الاستلام' : 'Cash on Delivery',
                subtitle: isAr ? 'الدفع عند المعاينة والاستلام' : 'Pay upon inspection',
                icon: Icons.local_shipping_outlined,
                isAr: isAr,
              ),
              const Divider(height: 30, color: AppColors.border),
              _buildPaymentOption(
                id: 'card',
                title: isAr ? 'بطاقة ائتمان / خصم مباشر' : 'Credit / Debit Card',
                subtitle: isAr ? 'بوابة دفع إلكترونية آمنة' : 'Secure payment gateway',
                icon: Icons.credit_card_rounded,
                isAr: isAr,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isAr,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = id);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F7F6) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: R.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: R.sp(context, 12),
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24)
          else
            const Icon(Icons.circle_outlined, color: AppColors.border, size: 24),
        ],
      ),
    );
  }

  Widget _buildSafeShoppingBanner(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: AppColors.primary, width: isAr ? 4 : 0),
          left: BorderSide(color: AppColors.primary, width: !isAr ? 4 : 0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تسوق آمن ومضمون 100%' : '100% Safe Shopping',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: R.sp(context, 14),
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr 
                      ? 'سيتم تجهيز طلبك وشحنه مباشرة إلى عنوان التوصيل المحدد مع ميزة التتبع.' 
                      : 'Your order will be prepared and shipped directly to the specified delivery address.',
                  style: TextStyle(
                    fontSize: R.sp(context, 12),
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter(double total, bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        R.pad(context, 20),
        R.pad(context, 16),
        R.pad(context, 20),
        R.pad(context, MediaQuery.of(context).padding.bottom + 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'إجمالي المبلغ المطلوب' : 'Total Amount Required',
                style: TextStyle(
                  fontSize: R.sp(context, 14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    total.toInt().toString(),
                    style: TextStyle(
                      fontSize: R.sp(context, 24),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      isAr ? 'درهم إماراتي' : 'AED',
                      style: TextStyle(
                        fontSize: R.sp(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: R.pad(context, 54),
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedAddress == null
                  ? null 
                  : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAddress != null ? AppColors.primary : const Color(0xFFD3D8E0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? 'تأكيد الطلب والدفع' : 'Confirm Order & Pay',
                          style: TextStyle(
                            fontSize: R.sp(context, 16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    required bool isError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: R.sp(context, 12),
            color: isError ? Colors.red : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isError ? Colors.red : AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 13)),
              ),
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: TextStyle(fontSize: R.sp(context, 14), color: AppColors.textDark),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
