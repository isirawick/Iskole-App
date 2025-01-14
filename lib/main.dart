import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/grade.dart';
import 'package:iskole/features/home/modal/subject.dart';
import 'package:iskole/features/splash_screen.dart';
import 'core/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iskole/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iskole/features/home/view/pages/chapter_page.dart';

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

// Initialize the Flutter Local Notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Get FCM token for debugging
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Device Token: $token');

  // Restore subscriptions from local storage
  final prefs = await SharedPreferences.getInstance();
  final topics = prefs.getStringList('subscribed_topics') ?? [];
  for (String grade in topics) {
    await FirebaseMessaging.instance.subscribeToTopic('GRADE_$grade');
    print('Restored subscription to GRADE_$grade');
  }

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tap
      print('Notification tapped: ${response.payload}');
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!);
          if (data['chapterId'] != null) {
            final gradeRef = FirebaseFirestore.instance
                .collection('grades_v2')
                .doc(data['gradeId']);
            final subjectRef = FirebaseFirestore.instance
                .collection('subjects_v2')
                .doc(data['subjectId']);
            final chapterRef = FirebaseFirestore.instance
                .collection('chapters_v2')
                .doc(data['chapterId']);

            final gradeSnapshot = await gradeRef.get();
            final subjectSnapshot = await subjectRef.get();
            final chapterSnapshot = await chapterRef.get();
            final chapter = Chapter(
                image: chapterSnapshot['image'] ?? "",
                title: chapterSnapshot['title'] ?? "",
                subject: subjectSnapshot.reference,
                grade: gradeSnapshot.reference,
                ref: chapterSnapshot.reference);
            if (chapterSnapshot.exists) {
              Get.to(() => ChapterPage(
                    chapter: chapter,
                  ));
            }
          }
        } catch (e) {
          print('Error handling notification tap: $e');
        }
      }
    },
  );

  // Listen to messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  });

  // Add background message click handler
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data['chapterId'] != null) {
      try {
        final gradeRef = FirebaseFirestore.instance
            .collection('grades_v2')
            .doc(message.data['gradeId']);
        final subjectRef = FirebaseFirestore.instance
            .collection('subjects_v2')
            .doc(message.data['subjectId']);
        final chapterRef = FirebaseFirestore.instance
            .collection('chapters_v2')
            .doc(message.data['chapterId']);

        final gradeSnapshot = await gradeRef.get();
        final subjectSnapshot = await subjectRef.get();
        final chapterSnapshot = await chapterRef.get();
        final chapter = Chapter(
            image: chapterSnapshot['image'] ?? "",
            title: chapterSnapshot['title'] ?? "",
            subject: subjectSnapshot.reference,
            grade: gradeSnapshot.reference,
            ref: chapterSnapshot.reference);
        if (chapterSnapshot.exists) {
          Get.to(() => ChapterPage(
                chapter: chapter,
              ));
        }
      } catch (e) {
        print('Error handling background notification tap: $e');
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Iskoole',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
      home: const SplashScreen(),
    );
  }
}
