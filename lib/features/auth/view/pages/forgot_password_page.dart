import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/view/pages/otp_page.dart';
import 'package:iskole/features/auth/view/widgets/auth_input.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final RxBool isLoading = false.obs;
  final OtpService _otpService = OtpService();

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (value.length < 9) {
      return 'Phone number must be at least 9 digits';
    }
    return null;
  }

  Future<void> generateOTP(String phoneNumber) async {
    try {
      isLoading.value = true;
      final result = await _otpService.generateOTP('+94$phoneNumber');

      if (result['success']) {
        Get.to(
            () => OtpPage(phoneNumber: '+94$phoneNumber', passwordReset: true));
      } else {
        Alert.error(title: "Oooops...", text: result['message']);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SvgPicture.asset(
                "assets/svg/lock-full.svg",
                color: Palette.welcomeButtonTextColor,
                width: 60,
              ),
              SizedBox(height: 10),
              Text(
                "Forgot Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Palette.welcomeButtonTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                child: AuthInput(
                  label: "Phone Number",
                  prefixText: "+94",
                  controller: _phoneNumberController,
                  validator: _validatePhoneNumber,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  prefix: SvgPicture.asset(
                    'assets/svg/phone.svg',
                    height: 18,
                    width: 18,
                    color: Palette.authInputColor,
                  ),
                ),
              ),
              Obx(() => Button.primary(
                  isLoading: isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      generateOTP(_phoneNumberController.text.trim());
                    }
                  },
                  label: "Send OTP"))
            ],
          ),
        ),
      ),
    );
  }
}
