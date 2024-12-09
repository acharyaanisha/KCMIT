import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class parentTokenProvider with ChangeNotifier {
  String? _token;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? get token => _token;

  Future<void> setToken(String token) async {
    _token = token;
    if (_token != null) {
      await _storage.write(key: 'jwt_token', value: token);
    } else {
      await _storage.delete(key: 'jwt_token');
    }
    _checkTokenExpiry();
    notifyListeners();
  }

  void _checkTokenExpiry() {
    if (_token != null && JwtDecoder.isExpired(_token!)) {
      print("Token has expired. Logging out...");
      _logout();
    }
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'jwt_token');
    _checkTokenExpiry();
    notifyListeners();
  }

  void _logout() {
    _token = null;
    _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
