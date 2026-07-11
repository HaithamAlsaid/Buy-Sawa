// SecureStorageService — حفظ التوكن بشكل مشفر آمن
// بيستخدم flutter_secure_storage بدل SharedPreferences للبيانات الحساسة


import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey = 'auth_token';

  // Save Token 
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  //Get Token 
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  //Delete Token
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  //Check if Token Exists 
  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }
}
