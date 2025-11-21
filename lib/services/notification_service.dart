import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:carehub/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Get FCM token and save to caregiver profile
    await _saveFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for shift assignment notifications
    _listenForShiftNotifications();
  }

  Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && _authService.currentUser != null) {
        await _firestore.collection('caregivers').doc(_authService.currentUserId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> updateFCMToken() async {
    await _saveFCMToken();
  }

  Future<void> removeFCMToken() async {
    if (_authService.currentUser != null) {
      await _firestore.collection('caregivers').doc(_authService.currentUserId).update({
        'fcmToken': FieldValue.delete(),
      });
    }
  }

  void _listenForShiftNotifications() {
    final userId = _authService.currentUserId;
    if (userId != null) {
      _firestore.collection('shifts')
          .where('caregiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final shiftData = change.doc.data() as Map<String, dynamic>;
                final startTime = (shiftData['startTime'] as Timestamp).toDate();
                _showLocalNotification(
                  'New Shift Assigned',
                  'You have a new shift scheduled for ${startTime.toString()}',
                );
              }
            }
          });
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'shift_notifications',
      'Shift Notifications',
      channelDescription: 'Notifications for shift assignments and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
