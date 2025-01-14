import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/view/pages/signup_page.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:iskole/features/auth/controllers/otp_controller.dart';

class OtpPage extends StatelessWidget {
  final String phoneNumber;
  final bool passwordReset;
  OtpPage({super.key, required this.phoneNumber, this.passwordReset = false});

  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();
  final OtpController controller = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    controller.passwordChange.value = passwordReset;
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Verify Your Phone Number",
                            style: TextStyle(
                              fontSize: 24,
                              color: Palette.welcomeButtonTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "We've sent a verification code to",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.welcomeButtonTextColor,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Enter 6-digit verification code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 16),
                          OtpPinField(
                            key: _otpPinFieldController,
                            maxLength: 6,
                            fieldWidth: 45,
                            fieldHeight: 45,
                            keyboardType: TextInputType.number,
                            autoFillEnable: true,
                            onSubmit: (text) {
                              controller.otp.value = text;
                              controller.verifyOTP(phoneNumber);
                            },
                            onChange: (text) {
                              controller.otp.value = text;
                            },
                            // decoration: BoxDecoration(
                            //   color: Colors.grey[100],
                            //   borderRadius: BorderRadius.circular(8),
                            //   border: Border.all(color: Colors.grey[300]!),
                            // ),
                          ),
                          SizedBox(height: 40),
                          Obx(() => Button.primary(
                                onPressed: () =>
                                    controller.verifyOTP(phoneNumber),
                                isLoading: controller.isLoading.value,
                                label: 'Verify',
                              )),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              Button.text(
                                fontSize: 16,
                                onPressed: () =>
                                    controller.resendOTP(phoneNumber),
                                label: "Resend",
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Please check your SMS messages.\nThe code will expire in 10 minutes.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
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
