import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iskole/core/config/api_config.dart';

class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  Future<Map<String, dynamic>> generateOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/generate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': '$phoneNumber',
        }),
      );

      final responseData = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phoneNumber,
          'otp': otp,
        }),
      );

      final responseData = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred',
        'tempToken': responseData['tempToken'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String phoneNumber, String newPassword, String tempToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phoneNumber,
          'newPassword': newPassword,
          'tempToken': tempToken,
        }),
      );

      final responseData = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> verifyPhoneNumber(
      String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify-phone'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phoneNumber,
          'otp': otp,
        }),
      );

      final responseData = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }
}
