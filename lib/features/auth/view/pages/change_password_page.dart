import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/features/auth/view/pages/signin_page.dart';
import 'package:iskole/features/auth/view/widgets/auth_input.dart';

class ChangePasswordPage extends StatelessWidget {
  final String phoneNumber;
  final String tempToken;

  ChangePasswordPage({
    required this.phoneNumber,
    required this.tempToken,
  });

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final OtpService _otpService = OtpService();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final result = await _otpService.changePassword(
        phoneNumber,
        _passwordController.text,
        tempToken,
      );

      if (result['success']) {
        Get.offAll(() => SigninPage());
        Alert.success(
          title: "Success!",
          text: "Your password has been changed successfully",
        );
      } else {
        Alert.error(
          title: "Error",
          text: result['message'] ?? 'Failed to change password',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 80,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "Create New Password",
                              style: TextStyle(
                                fontSize: 24,
                                color: Palette.welcomeButtonTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Your new password must be different\nfrom previously used passwords",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 40),
                            Obx(() => AuthInput(
                                  prefix: Icon(Icons.lock_outline,
                                      color: Palette.authInputColor),
                                  suffix: IconButton(
                                    icon: Icon(
                                      isPasswordVisible.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Palette.authInputColor,
                                    ),
                                    onPressed: () => isPasswordVisible.toggle(),
                                  ),
                                  label: "New Password",
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  isObscured: !isPasswordVisible.value,
                                )),
                            SizedBox(height: 20),
                            Obx(() => AuthInput(
                                  prefix: Icon(Icons.lock_outline,
                                      color: Palette.authInputColor),
                                  suffix: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Palette.authInputColor,
                                    ),
                                    onPressed: () =>
                                        isConfirmPasswordVisible.toggle(),
                                  ),
                                  label: "Confirm Password",
                                  controller: _confirmPasswordController,
                                  validator: _validateConfirmPassword,
                                  isObscured: !isConfirmPasswordVisible.value,
                                )),
                            SizedBox(height: 40),
                            Obx(() => Button.primary(
                                  onPressed: _changePassword,
                                  isLoading: isLoading.value,
                                  label: 'Reset Password',
                                )),
                            SizedBox(height: 20),
                            Text(
                              "Make sure your new password is strong and\neasy to remember",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
