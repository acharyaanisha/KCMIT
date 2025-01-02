import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Background Message Received: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}

class FirebaseApi {

  String baseUrl = "http://kcmit-api.kcmit.edu.np:5000";

  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;


    print("Message clicked: ${message.notification?.title}");
  }

  Future<String> _getBase64FromImageUrl(String? imageUrl) async {
    if (imageUrl == null) return "";

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      }
      print("Response: $response");
    } catch (e) {
      print("Error fetching image: $e");
    }
    return "";
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/kcmit');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      final imageUrl = message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl;

      if (notification == null) return;

      NotificationDetails notificationDetails;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String fullImageUrl = "$baseUrl$imageUrl";
        final base64Image = await _getBase64FromImageUrl(fullImageUrl);

        print("Image: $fullImageUrl");


        final bigPictureStyleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(base64Image),
          largeIcon: const DrawableResourceAndroidBitmap('@drawable/kcmit'),
          contentTitle: notification.title,
          summaryText: notification.body,
        );

        notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            styleInformation: bigPictureStyleInformation,
            icon: '@drawable/kcmit',
          ),
        );
      } else {
        notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/kcmit',
          ),
        );
      }

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('ALL');
      print("Subscribed to 'all' topic successfully!");
    } catch (e) {
      print("Failed to subscribe to 'all' topic: $e");
    }
  }

  // Future<List<String>> getRoleFromToken(String token) async {
  //   final parts = token.split('.');
  //   if (parts.length != 3) {
  //     throw Exception("Invalid token");
  //   }
  //
  //   final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  //   final payloadMap = json.decode(payload);
  //
  //   print("Decoded Payload in firebase:  $payload");
  //
  //   if (payloadMap is! Map<String, dynamic>) {
  //     throw Exception("Invalid payload");
  //   }
  //
  //   if (payloadMap.containsKey('role') && payloadMap['role'] is List) {
  //     print("Roles found in the token: ${payloadMap['role']}");
  //     return List<String>.from(payloadMap['role']);
  //   } else {
  //     print("No 'role' found in the token payload");
  //     return [];
  //   }
  // }



  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();

    print("FCM Token: $FCMToken");

    // if (FCMToken != null) {
    //   await subscribeToRoleBasedTopics(FCMToken);
    // }
    // await subscribeToTopics();
    await initPushNotifications();
    await initLocalNotifications();
  }
}
