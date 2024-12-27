import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class facultyTokenProvider with ChangeNotifier {
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

  Future<String> getRoleFromToken(String token) async {
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


    if (payloadMap.containsKey('role') && payloadMap['role']) {
      print("Roles found in the token: ${payloadMap['role']}");
      return (payloadMap['role']);
    } else {
      print("No 'role' found in the token payload");
      return "";
    }
  }

  void _logout() {
    _token = null;
    _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
