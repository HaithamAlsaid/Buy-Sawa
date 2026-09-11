import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/country_service.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileAddressScreen extends StatefulWidget {
  const ProfileAddressScreen({super.key});

  @override
  State<ProfileAddressScreen> createState() => _ProfileAddressScreenState();
}

class _ProfileAddressScreenState extends State<ProfileAddressScreen> {
  final TextEditingController _detailsCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  Map<String, dynamic>? _selectedCity;

  bool _isLoadingCountries = true;
  bool _isSubmitting = false;
  bool _showValidation = false;
  
  // Track if we are editing an existing address
  String? _existingAddressId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final list = await CountryService.getCountries();
    if (!mounted) return;
    
    final provider = context.read<AddressProvider>();
    
    if (provider.addresses.isEmpty) {
      await provider.fetchAddresses();
    }

    if (mounted) {
      setState(() {
        _countries = list;
        _isLoadingCountries = false;

        if (provider.addresses.isNotEmpty) {
          final address = provider.defaultAddress ?? provider.addresses.first;
          _existingAddressId = address.id;
          
          // Try to match country
          try {
            _selectedCountry = _countries.firstWhere((c) => c['name'] == address.country || c['code'] == address.country);
          } catch (_) {}

          // Try to match city
          if (_selectedCountry != null) {
            try {
              final cities = _selectedCountry!['cities'] as List? ?? [];
              _selectedCity = cities.firstWhere((c) => c['name'] == address.city || c['name'] == address.state);
            } catch (_) {}
          }

          _detailsCtrl.text = address.addressLine1;
          
          // Remove phone code if possible to put in text field
          String phone = address.phoneNumber ?? address.phone;
          if (phone.startsWith('+')) {
             phone = phone.split(' ').skip(1).join(' ');
          }
          _phoneCtrl.text = phone;

        } else {
          // Defaults if no address
          try {
            _selectedCountry = _countries.firstWhere((c) => c['code'] == 'AE' || c['code'] == 'SA' || c['code'] == 'EG');
          } catch (_) {}
        }
      });
    }
  }

  List<dynamic> get _currentCities {
    if (_selectedCountry == null) return [];
    return _selectedCountry!['cities'] as List? ?? [];
  }

  bool get _isValid {
    return _selectedCountry != null &&
        _selectedCity != null &&
        _detailsCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    setState(() => _showValidation = true);
    if (!_isValid) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<AddressProvider>();
      
      // Since AddressProvider addAddress handles API call, we just add it.
      // If we are editing, Ideally we would update, but AddressProvider only has delete/add.
      // We can delete old and add new to simulate update for now.
      if (_existingAddressId != null) {
        await provider.deleteAddress(_existingAddressId!);
      }

      final phoneCode = _selectedCountry!['phone_code'];
      String fullPhone = _phoneCtrl.text.trim();
      if (!fullPhone.startsWith('+')) {
        fullPhone = '$phoneCode $fullPhone';
      }

      final result = await provider.addAddress(
        countryKey: _selectedCountry!['key'],
        cityKey: _selectedCity!['key'],
        governorate: _selectedCity!['name'],
        details: _detailsCtrl.text.trim(),
        phone: fullPhone,
        isDefault: true,
      );

      if (result != null && mounted) {
        // Also update the main profile phone number so it appears in the Profile screen
        final auth = context.read<AuthProvider>();
        if (auth.user != null) {
          // Send the updated phone to the backend for the user profile
          await auth.updateProfile(auth.user!.fullName, auth.user!.birthdate ?? '', phone: fullPhone);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address saved successfully!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Failed to save address");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = l10n.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          isAr ? 'عنواني' : 'My Address',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingCountries
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(isAr ? 'الدولة' : 'Country'),
                  _buildDropdown(
                    value: _selectedCountry,
                    items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c['name']))).toList(),
                    hint: isAr ? 'اختر الدولة' : 'Select Country',
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val as Map<String, dynamic>?;
                        _selectedCity = null;
                      });
                    },
                    icon: Icons.public_rounded,
                    hasError: _showValidation && _selectedCountry == null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel(isAr ? 'المدينة' : 'City'),
                  _buildDropdown(
                    value: _selectedCity,
                    items: _currentCities.map((c) => DropdownMenuItem(value: c, child: Text(c['name']))).toList(),
                    hint: isAr ? 'اختر المدينة' : 'Select City',
                    onChanged: (val) => setState(() => _selectedCity = val as Map<String, dynamic>?),
                    icon: Icons.location_city_rounded,
                    hasError: _showValidation && _selectedCity == null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel(isAr ? 'العنوان التفصيلي (الشارع، المبنى، الشقة)' : 'Detailed Address'),
                  _buildTextField(
                    _detailsCtrl, 
                    isAr ? 'اسم الشارع، رقم المبنى، الشقة' : 'Street name, Building No, Appt', 
                    Icons.location_on_outlined,
                    hasError: _showValidation && _detailsCtrl.text.trim().isEmpty,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel(isAr ? 'رقم الهاتف' : 'Phone Number'),
                  _buildTextField(
                    _phoneCtrl, 
                    '50 123 4567', 
                    Icons.phone_outlined,
                    isPhone: true,
                    prefixText: _selectedCountry != null ? '${_selectedCountry!['phone_code']}  ' : null,
                    hasError: _showValidation && _phoneCtrl.text.trim().isEmpty,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      isAr ? 'حفظ العنوان' : 'Save Address',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPhone = false, String? prefixText, bool hasError = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasError ? AppColors.error : Colors.transparent, width: 1),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required String hint,
    required ValueChanged<dynamic> onChanged,
    IconData? icon,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasError ? AppColors.error : Colors.transparent, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textLight, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: value,
                isExpanded: true,
                hint: Text(hint, style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
                items: items,
                onChanged: onChanged,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
