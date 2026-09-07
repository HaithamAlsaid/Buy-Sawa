import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../core/services/country_service.dart';
import '../../core/services/address_service.dart';
import '../../core/services/order_service.dart';
import '../../widgets/credit_card_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Address State
  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  String? _selectedGovernorate; 
  Map<String, dynamic>? _selectedCity;

  final TextEditingController _detailsCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _isLoadingCountries = true;
  bool _isSubmitting = false;

  // Validation state
  bool _showValidation = false;

  // Payment Method
  String _selectedPaymentMethod = 'wallet'; // wallet, cod, card

  // Governorates Mock (Since API doesn't provide them, we mock based on country or just leave it generic)
  final List<String> _uaeEmirates = ['Abu Dhabi', 'Dubai', 'Sharjah', 'Ajman', 'Umm Al Quwain', 'Ras Al Khaimah', 'Fujairah'];
  final List<String> _ksaRegions = ['Riyadh', 'Makkah', 'Madinah', 'Eastern Province', 'Asir', 'Tabuk', 'Hail', 'Northern Borders', 'Jazan', 'Najran', 'Al Baha', 'Al Jouf'];
  final List<String> _egyptGovs = ['Cairo', 'Alexandria', 'Giza', 'Dakahlia', 'Red Sea', 'Beheira', 'Fayoum', 'Gharbia', 'Ismailia', 'Menofia', 'Minya', 'Qaliubiya', 'New Valley', 'Suez', 'Aswan', 'Assiut', 'Beni Suef', 'Port Said', 'Damietta', 'Sharkia', 'South Sinai', 'Kafr El Sheikh', 'Matrouh', 'Luxor', 'Qena', 'North Sinai', 'Sohag'];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    final list = await CountryService.getCountries();
    if (mounted) {
      setState(() {
        _countries = list;
        _isLoadingCountries = false;
        
        // Auto-select UAE or SA if available
        try {
          _selectedCountry = _countries.firstWhere((c) => c['code'] == 'AE' || c['code'] == 'SA' || c['code'] == 'EG');
          _phoneCtrl.text = _selectedCountry?['phone_code'] ?? '';
        } catch (_) {}
      });
    }
  }

  List<String> get _currentGovernorates {
    if (_selectedCountry == null) return [];
    if (_selectedCountry!['code'] == 'AE') return _uaeEmirates;
    if (_selectedCountry!['code'] == 'SA') return _ksaRegions;
    if (_selectedCountry!['code'] == 'EG') return _egyptGovs;
    return ['Main Region', 'Other Region']; // Fallback
  }

  List<dynamic> get _currentCities {
    if (_selectedCountry == null) return [];
    return _selectedCountry!['cities'] as List? ?? [];
  }

  bool get _isAddressValid {
    return _selectedCountry != null &&
        _selectedGovernorate != null &&
        _selectedCity != null &&
        _detailsCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty;
  }

  List<String> get _missingFields {
    final List<String> missing = [];
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';
    
    if (_selectedCountry == null) missing.add(isAr ? 'الدولة' : 'Country');
    if (_selectedGovernorate == null) missing.add(isAr ? 'المحافظة' : 'Governorate');
    if (_selectedCity == null) missing.add(isAr ? 'المدينة' : 'City');
    if (_detailsCtrl.text.trim().isEmpty) missing.add(isAr ? 'العنوان التفصيلي' : 'Address Details');
    if (_phoneCtrl.text.trim().isEmpty) missing.add(isAr ? 'رقم الهاتف' : 'Phone');
    return missing;
  }

  void _submitOrder() async {
    setState(() => _showValidation = true);
    if (!_isAddressValid) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Create Address
      final address = await AddressService.createAddress(
        addressLine1: _detailsCtrl.text.trim(),
        country: _selectedCountry!['name'],
        state: _selectedGovernorate!,
        city: _selectedCity!['name'],
        phoneNumber: _phoneCtrl.text.trim(),
      );

      if (address == null) {
        throw Exception("Failed to create address");
      }

      // 2. Checkout
      final result = await OrderService.checkout(
        shippingAddressId: address.id,
        paymentMethod: _selectedPaymentMethod, 
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
          const SizedBox(height: 20),
          
          if (_isLoadingCountries)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Country and Governorate
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdown<Map<String, dynamic>>(
                    label: isAr ? 'الدولة *' : 'Country *',
                    hint: isAr ? 'اختر الدولة' : 'Select Country',
                    value: _selectedCountry,
                    items: _countries,
                    itemLabel: (c) => isAr && c['arabic_name'] != null ? c['arabic_name'] : c['name'],
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val;
                        _selectedGovernorate = null;
                        _selectedCity = null;
                        if (val != null && _phoneCtrl.text.isEmpty) {
                          _phoneCtrl.text = val['phone_code'] ?? '';
                        }
                      });
                    },
                    isError: _showValidation && _selectedCountry == null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown<String>(
                    label: isAr ? 'المحافظة *' : 'Governorate *',
                    hint: isAr ? 'اختر المحافظة / الإمارة' : 'Select State',
                    value: _selectedGovernorate,
                    items: _currentGovernorates,
                    itemLabel: (g) => g,
                    onChanged: (val) => setState(() {
                      _selectedGovernorate = val;
                      _selectedCity = null;
                    }),
                    isError: _showValidation && _selectedGovernorate == null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // City
            _buildDropdown<Map<String, dynamic>>(
              label: isAr ? 'المدينة *' : 'City *',
              hint: isAr ? 'اختر المدينة' : 'Select City',
              value: _selectedCity,
              items: _currentCities.cast<Map<String, dynamic>>(),
              itemLabel: (c) => isAr && c['arabic_name'] != null ? c['arabic_name'] : c['name'],
              onChanged: (val) => setState(() => _selectedCity = val),
              isError: _showValidation && _selectedCity == null,
            ),
            const SizedBox(height: 16),

            // Detailed Address
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'العنوان التفصيلي (الشارع، المبنى، الشقة) *' : 'Detailed Address *',
                  style: TextStyle(
                    fontSize: R.sp(context, 12),
                    color: (_showValidation && _detailsCtrl.text.trim().isEmpty) ? Colors.red : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_showValidation && _detailsCtrl.text.trim().isEmpty) 
                          ? Colors.red 
                          : AppColors.border,
                    ),
                  ),
                  child: TextField(
                    controller: _detailsCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: isAr ? 'العنوان التفصيلي (الشارع، المبنى، الشقة)' : 'Street, Building, Flat',
                      hintStyle: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 13)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showValidation && _detailsCtrl.text.trim().isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      isAr ? 'العنوان التفصيلي مطلوب' : 'Detailed address is required',
                      style: TextStyle(color: Colors.red, fontSize: R.sp(context, 11)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'رقم الهاتف *' : 'Phone Number *',
                  style: TextStyle(
                    fontSize: R.sp(context, 12),
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.phone_outlined, color: AppColors.textLight, size: 20),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '+971 50 123 4567',
                            hintStyle: TextStyle(color: AppColors.textLight, fontSize: R.sp(context, 14)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Warning Box
            if (_showValidation && !_isAddressValid)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // Light yellow
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'بيانات الشحن المطلوبة غير مكتملة:' : 'Required shipping data incomplete:',
                            style: TextStyle(
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 13),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _missingFields.join(' • '),
                            style: TextStyle(
                              color: const Color(0xFFD97706),
                              fontSize: R.sp(context, 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
          ],
        ],
      ),
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
                            ? Image.network(item.product.imageUrl, fit: BoxFit.contain)
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
      onTap: () async {
        setState(() => _selectedPaymentMethod = id);
        if (id == 'card') {
          // Calculate subtotal for the sheet
          final cart = context.read<CartProvider>();
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreditCardSheet(totalAmount: cart.total),
          );
        }
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
    final valid = _isAddressValid;

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
              onPressed: _isSubmitting 
                  ? null 
                  : (valid ? _submitOrder : () => setState(() => _showValidation = true)),
              style: ElevatedButton.styleFrom(
                backgroundColor: valid ? AppColors.primary : const Color(0xFFD3D8E0),
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
          if (_showValidation && !valid)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? 'أكمل عنوان الشحن بالأعلى لتفعيل زر الدفع' : 'Complete shipping address to enable payment',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: R.sp(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
