import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/features/auth/view/pages/change_password_page.dart';
import 'package:iskole/features/auth/view/pages/signin_page.dart';
import 'package:iskole/features/home/view/pages/home_page.dart';

class OtpController extends GetxController {
  final OtpService _otpService = OtpService();
  final RxBool isLoading = false.obs;
  final RxBool passwordChange = false.obs;
  final RxString otp = ''.obs;
  String? tempToken;

  Future<void> verifyOTP(String phoneNumber) async {
    if (otp.value.length != 6) {
      Alert.error(
          title: "Invalid OTP", text: "Please enter a valid 6-digit code");
      return;
    }

    try {
      isLoading.value = true;
      final result = await _otpService.verifyOTP(phoneNumber, otp.value);

      if (result['success']) {
        tempToken = result['tempToken'];
        if (passwordChange.value) {
          Get.to(() => ChangePasswordPage(
                phoneNumber: phoneNumber,
                tempToken: tempToken!,
              ));
        } else {
          Get.offAll(() => Home());
        }
        Alert.success(
          title: "Success!",
          text: "Phone number verified successfully",
        );
      } else {
        Alert.error(title: "Verification Failed", text: result['message']);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    try {
      isLoading.value = true;
      final result = await _otpService.generateOTP(phoneNumber);
      print(phoneNumber);
      if (result['success']) {
        Alert.success(
            title: "OTP Sent", text: "A new verification code has been sent");
      } else {
        Alert.error(title: "Failed to Send", text: result['message']);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    if (otp.value.length != 6) {
      Alert.error(
          title: "Invalid OTP", text: "Please enter a valid 6-digit code");
      return;
    }

    try {
      isLoading.value = true;
      final result =
          await _otpService.verifyPhoneNumber(phoneNumber, otp.value);

      if (result['success']) {
        Alert.success(
          title: "Success!",
          text: "Phone number verified successfully",
        );
        Get.offAll(() => SigninPage()); // Redirect to login after verification
      } else {
        Alert.error(title: "Verification Failed", text: result['message']);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
