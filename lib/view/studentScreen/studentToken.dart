import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kcmit/view/authentication/loginPage.dart';

class studentTokenProvider with ChangeNotifier {
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
    await _checkTokenExpiryAndLogoutIfNeeded();
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'jwt_token');
    await _checkTokenExpiryAndLogoutIfNeeded();
    notifyListeners();
  }

  Future<void> _checkTokenExpiryAndLogoutIfNeeded() async {
    if (_token != null && JwtDecoder.isExpired(_token!)) {
      print("Token has expired. Logging out...");
      await _logout();
    }
  }

  Future<void> _logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  Future<bool> isTokenExpired(String token) async {
    try {
      if (JwtDecoder.isExpired(token)) {
        return true;
      }
      return false;
    } catch (e) {
      return true; // If there's any issue with decoding, consider it expired
    }
  }

  Future<void> clearTokenAndLogout(BuildContext context) async {
    await _logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Future<List<String>> getRoleFromToken(String token) async {
    _token = token;
    final parts = _token?.split('.');
    if (parts?.length != 3) {
      throw Exception("Invalid token");
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts![1])));
    final payloadMap = json.decode(payload);

    print("Decoded Payload: $payload");

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception("Invalid payload");
    }

    if (payloadMap.containsKey('role') && payloadMap['role'] is List) {
      print("Roles found in the token: ${payloadMap['role']}");
      return List<String>.from(payloadMap['role']);
    } else {
      print("No 'role' found in the token payload");
      return [];
    }
  }
}
