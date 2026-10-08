import 'package:buysawa/screens/checkout/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../core/services/order_service.dart';
import '../../core/services/cart_service.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/cached_image.dart';
import 'payment_webview_screen.dart';
import '../../core/services/country_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/wallet_service.dart';
import '../main/main_screen.dart';
class CheckoutScreen extends StatefulWidget {
  final String? couponCode;
  const CheckoutScreen({super.key, this.couponCode});

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

  // Payment Method: 'wallet' | 'card' | 'tamara'
  String _selectedPaymentMethod = 'wallet';
  double? _walletBalance;
  bool _isLoadingWallet = true;
  bool _insufficientFunds = false;

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
      // Fetch countries, addresses and wallet in parallel
      await Future.wait([
        CountryService.getCountries().then((v) => list = v),
        if (provider.addresses.isEmpty) provider.fetchAddresses(),
        WalletService.getWallet().then((w) {
          if (mounted && w != null) {
            setState(() {
              _walletBalance = w.balance;
              _isLoadingWallet = false;
            });
          } else if (mounted) {
            setState(() => _isLoadingWallet = false);
          }
        }),
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

  // ── Sync local cart items to backend before checkout ──────────
  Future<void> _syncCartToBackend() async {
    final cart = context.read<CartProvider>();
    for (final item in cart.items) {
      if (item.cartItemId == null) {
        debugPrint('🛒 Syncing item to backend: ${item.product.id}');
        final newId = await CartService.addItem(
          productId: item.product.id,
          variantId: item.variantId,
          quantity: item.quantity,
        );
        debugPrint('🛒 Backend returned id: $newId');
      }
    }
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

    setState(() {
      _isSubmitting = true;
      _insufficientFunds = false;
    });

    // Check wallet balance before proceeding
    if (_selectedPaymentMethod == 'wallet') {
      final cart = context.read<CartProvider>();
      final orderTotal = cart.subtotal;
      if (_walletBalance != null && _walletBalance! < orderTotal) {
        setState(() {
          _isSubmitting = false;
          _insufficientFunds = true;
        });
        return;
      }
    }

    try {
      // ── Sync cart to backend first ────────────────────────────
      await _syncCartToBackend();

      String? targetAddressId = _selectedAddress?.id;

      // ── Save / update address if user typed a new one ──────────
      if (_isAddingNewAddress) {
        final phoneCode = _selectedCountry!['phone_code'];
        String fullPhone = _phoneCtrl.text.trim();
        if (!fullPhone.startsWith('+')) {
          fullPhone = '$phoneCode $fullPhone';
        }

        AddressModel? saved;
        if (_selectedAddress != null) {
          saved = await context.read<AddressProvider>().updateAddress(
            id: _selectedAddress!.id,
            countryKey: _selectedCountry!['key'],
            cityKey: _cityCtrl.text.trim(),
            governorate: _selectedGovernorate!['name'],
            details: _detailsCtrl.text.trim(),
            phone: fullPhone,
          );
        } else {
          saved = await context.read<AddressProvider>().addAddress(
            countryKey: _selectedCountry!['key'],
            cityKey: _cityCtrl.text.trim(),
            governorate: _selectedGovernorate!['name'],
            details: _detailsCtrl.text.trim(),
            phone: fullPhone,
            isDefault: true,
          );
        }

        if (saved != null) {
          targetAddressId = saved.id;
          if (mounted) {
            final auth = context.read<AuthProvider>();
            final user = auth.user;
            if (user != null) {
              await auth.updateProfile(user.fullName, user.birthdate, phone: fullPhone);
            }
          }
        } else {
          throw Exception(isAr ? 'فشل في حفظ العنوان الجديد' : 'Failed to save new address');
        }
      }

      // ── Map selected method → API fields ──────────────────────
      // wallet  → payment_method: wallet,  provider: wallet
      // card    → payment_method: card,    provider: ngenius
      // tamara  → payment_method: bnpl,    provider: tamara
      final String apiPaymentMethod;
      final String apiProvider;
      switch (_selectedPaymentMethod) {
        case 'wallet':
          apiPaymentMethod = 'wallet';
          apiProvider = 'wallet';
          break;
        case 'tamara':
          apiPaymentMethod = 'bnpl';
          apiProvider = 'tamara';
          break;
        case 'card':
        default:
          apiPaymentMethod = 'card';
          apiProvider = 'ngenius';
          break;
      }

      // ── Call Checkout API ─────────────────────────────────────
      final result = await OrderService.checkout(
        shippingAddressId: targetAddressId!,
        paymentMethod: apiPaymentMethod,
        provider: apiProvider,
        phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
        couponCode: widget.couponCode,
      );

      if (result.error != null) {
        throw Exception(result.error);
      }

      // ── Handle payment gateway redirect (card / tamara) 
      if (result.redirectionUrl != null && result.redirectionUrl!.isNotEmpty) {
        if (!mounted) return;
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(url: result.redirectionUrl!),
          ),
        );
        if (success != true) {
          if (mounted) {
            context.read<CartProvider>().clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isAr 
                    ? 'تم إلغاء الدفع. تم حفظ الطلب ويمكنك الدفع لاحقاً من طلباتي' 
                    : 'Payment cancelled. Order is saved, you can pay later from My Orders'),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
      }

      // Success 
      if (mounted) {
        context.read<CartProvider>().clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: result.order),
          ),
        );
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
    final total = cart.subtotal;

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
          height: 115,
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
                subtitle: _isLoadingWallet
                    ? (isAr ? 'جاري التحميل...' : 'Loading...')
                    : (_walletBalance != null
                        ? (isAr
                            ? 'رصيدك: ${_walletBalance!.toStringAsFixed(2)} د.إ'
                            : 'Balance: ${_walletBalance!.toStringAsFixed(2)} AED')
                        : (isAr ? 'خصم فوري' : 'Instant deduction')),
                icon: Icons.account_balance_wallet_rounded,
                isAr: isAr,
              ),
              // Insufficient funds warning
              if (_insufficientFunds && _selectedPaymentMethod == 'wallet')
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isAr
                                    ? 'رصيد المحفظة غير كافٍ لإتمام هذا الطلب'
                                    : 'Wallet balance is insufficient for this order',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final cart = context.read<CartProvider>();
                            final needed = cart.subtotal -
                                (_walletBalance ?? 0);
                            final paymentUrl = await WalletService.topUp(
                              amount: needed,
                              provider: 'ngenius',
                            );
                            if (paymentUrl != null && mounted) {
                              final success =
                                  await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentWebViewScreen(
                                      url: paymentUrl),
                                ),
                              );
                              if (success == true && mounted) {
                                // Refresh wallet balance
                                final w = await WalletService.getWallet();
                                if (mounted && w != null) {
                                  setState(() {
                                    _walletBalance = w.balance;
                                    _insufficientFunds = false;
                                  });
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isAr
                                  ? 'اشحن المحفظة الآن'
                                  : 'Top Up Wallet Now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 30, color: AppColors.border),
              _buildPaymentOption(
                id: 'card',
                title: isAr ? 'بطاقة ائتمان / خصم مباشر' : 'Credit / Debit Card',
                subtitle: isAr ? 'بوابة دفع إلكترونية آمنة (N-Genius)' : 'Secure payment gateway (N-Genius)',
                icon: Icons.credit_card_rounded,
                isAr: isAr,
              ),
              const Divider(height: 30, color: AppColors.border),
              _buildPaymentOptionWithLogo(
                id: 'tamara',
                title: isAr ? 'تمارا — اشتري الآن وادفع لاحقاً' : 'Tamara — Buy Now, Pay Later',
                subtitle: isAr ? 'قسّم على 3 أشهر بدون فوائد' : 'Split into 3 months, 0% interest',
                logoAsset: 'assets/images/tamara_logo.png',
                fallbackIcon: Icons.splitscreen_rounded,
                color: const Color(0xFF2D9B6F),
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
      onTap: () => setState(() => _selectedPaymentMethod = id),
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

  Widget _buildPaymentOptionWithLogo({
    required String id,
    required String title,
    required String subtitle,
    required String logoAsset,
    required IconData fallbackIcon,
    required Color color,
    required bool isAr,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              logoAsset,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                color: isSelected ? color : AppColors.textLight,
                size: 24,
              ),
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
                    color: isSelected ? color : AppColors.textDark,
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
            Icon(Icons.check_circle_rounded, color: color, size: 24)
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
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
