// ─────────────────────────────────────────────────────────────────────────────
// AddressProvider — يجيب العناوين ويديرها مع الـ API
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../core/services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _token;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isEmpty => _addresses.isEmpty;

  AddressModel? get defaultAddress =>
      _addresses.isNotEmpty
          ? (_addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => _addresses.first,
            ))
          : null;

  // ─── تحديد التوكن وجلب العناوين ──────────────────────────────
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      fetchAddresses();
    } else {
      _addresses = [];
      notifyListeners();
    }
  }

  // ─── جلب كل العناوين ─────────────────────────────────────────
  Future<void> fetchAddresses() async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    _addresses = await AddressService.getAddresses();
    _isLoading = false;
    notifyListeners();
  }

  // ─── إضافة عنوان ─────────────────────────────────────────────
  Future<AddressModel?> addAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String country,
    String? postalCode,
    String? label,
    String? instructions,
    String? phoneCode,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final newAddress = await AddressService.createAddress(
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      label: label,
      instructions: instructions,
      phoneCode: phoneCode,
      phoneNumber: phoneNumber,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );

    if (newAddress != null) {
      if (isDefault) {
        _addresses = _addresses
            .map((a) => AddressModel(
                  id: a.id,
                  label: a.label,
                  addressLine1: a.addressLine1,
                  addressLine2: a.addressLine2,
                  city: a.city,
                  state: a.state,
                  country: a.country,
                  postalCode: a.postalCode,
                  phoneCode: a.phoneCode,
                  phoneNumber: a.phoneNumber,
                  isDefault: false,
                  instructions: a.instructions,
                ))
            .toList();
      }
      _addresses.add(newAddress);
      notifyListeners();
    }
    return newAddress;
  }

  // ─── تعيين عنوان كـ Default ───────────────────────────────────
  Future<void> setDefault(String id) async {
    final success = await AddressService.setDefault(id);
    if (success) {
      _addresses = _addresses.map((a) => AddressModel(
            id: a.id,
            label: a.label,
            addressLine1: a.addressLine1,
            addressLine2: a.addressLine2,
            city: a.city,
            state: a.state,
            country: a.country,
            postalCode: a.postalCode,
            phoneCode: a.phoneCode,
            phoneNumber: a.phoneNumber,
            isDefault: a.id == id,
            instructions: a.instructions,
          )).toList();
      notifyListeners();
    }
  }

  // ─── حذف عنوان ───────────────────────────────────────────────
  Future<void> deleteAddress(String id) async {
    final success = await AddressService.deleteAddress(id);
    if (success) {
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
    }
  }
}
