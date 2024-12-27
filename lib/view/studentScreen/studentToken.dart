import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class studentTokenProvider with ChangeNotifier {
  String? _token;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? get token => _token;
  final _firebaseMessaging = FirebaseMessaging.instance;


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

  // Future<void> subscribeToRoleBasedTopics(String token) async {
  //   try {
  //     print("Subscribed to topic:");
  //
  //     List<String> roles = await getRoleFromToken(token);
  //     print("Subscribed to topic:");
  //
  //
  //     for (String role in roles) {
  //       await _firebaseMessaging.subscribeToTopic(role);
  //       print("Subscribed to topic: $role");
  //     }
  //   } catch (e) {
  //     print("Error subscribing to topics: $e");
  //   }
  // }
  //
  // Future<void> initNotifications() async {
  //   await _firebaseMessaging.requestPermission();
  //   final FCMToken = await _firebaseMessaging.getToken();
  //
  //   print("FCM Token: $FCMToken");
  //
  //   if (FCMToken != null) {
  //     await subscribeToRoleBasedTopics(FCMToken);
  //   }
  //
  // }

  Future<void> setToken(String token) async {
    _token = token;
    if (_token != null) {
      await _storage.write(key: 'jwt_token', value: token);
    } else {
      await _storage.delete(key: 'jwt_token');
    }

    // print("Token: $token");

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
    if (_token != null && JwtDecoder.isExpired(_token!)) {
      print("Token has expired. Logging out...");
      _logout();
    } else {
      notifyListeners();
    }
  }


  void _logout() {
    _token = null;
    _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
