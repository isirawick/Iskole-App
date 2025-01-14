import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iskole/core/config/api_config.dart';

class NotificationService {
  static const String _topicKey = 'subscribed_topics';

  // Subscribe to topic and save locally
  static Future<bool> subscribeTopic(String grade) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(grade);

      final prefs = await SharedPreferences.getInstance();
      final topics = prefs.getStringList(_topicKey) ?? [];

      if (!topics.contains(grade)) {
        topics.add(grade);
        await prefs.setStringList(_topicKey, topics);
      }
      print("subscribed to topic $grade");

      return true;
    } catch (e) {
      print('Failed to subscribe to topic: $e');
      return false;
    }
  }

  // Unsubscribe from topic and remove from local storage
  static Future<bool> unsubscribeTopic(String grade) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(grade);

      final prefs = await SharedPreferences.getInstance();
      final topics = prefs.getStringList(_topicKey) ?? [];

      topics.remove(grade);
      await prefs.setStringList(_topicKey, topics);

      return true;
    } catch (e) {
      print('Failed to unsubscribe from topic: $e');
      return false;
    }
  }

  // Check if topic is subscribed
  static Future<bool> isTopicSubscribed(String grade) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = prefs.getStringList(_topicKey) ?? [];
    return topics.contains(grade);
  }

  // Send notification to topic
  static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/send-to-topic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'imageUrl': imageUrl,
          },
          if (data != null) 'data': data,
        }),
      );
      print("response ${response.body}");
      print("$topic $title $body $imageUrl $data");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Failed to send notification: $e');
      return false;
    }
  }
}
