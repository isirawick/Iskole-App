import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/features/auth/view/pages/otp_page.dart';
import 'package:iskole/features/auth/view/pages/welcome_page.dart';
import 'package:iskole/features/home/view/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OtpService _otpService = OtpService();

  String removeDomain(String email) {
    List<String> parts = email.split('@');
    return parts[0];
  }

  @override
  Widget build(BuildContext context) {
    void checkAuth() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users_v2');
        QuerySnapshot querySnapshot = await users
            .where('phoneNumber', isEqualTo: removeDomain(user.email!))
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Map userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;

          // Set user instance
          UserInstance.setUser(
            id: querySnapshot.docs.first.reference,
            firstName: userData['firstName'],
            lastName: userData['lastName'],
            phoneNumber: userData['phoneNumber'],
            role: userData['role'],
            birthday: userData['birthday'],
            district: userData['district'],
            school: userData['schoolName'],
            isActivated: userData['isActivated'],
          );

          print(querySnapshot.docs.first.reference.id);

          // Check phone verification status
          bool isPhoneVerified = userData['phone_number_verified'] ?? false;

          if (!isPhoneVerified) {
            // Generate OTP and navigate to verification
            final otpResult =
                await _otpService.generateOTP('+${userData['phoneNumber']}');

            if (otpResult['success']) {
              Get.offAll(() => OtpPage(
                    phoneNumber: '+${userData['phoneNumber']}',
                  ));
              return;
            }
          }

          // If phone is verified or OTP generation failed, proceed to home
          Get.offAll(Home(), transition: Transition.fade);
          return;
        }
      }
      Get.offAll(const WelcomePage(), transition: Transition.fade);
    }

    void goToNext() async {
      await Future.delayed(Duration(seconds: 1), checkAuth);
    }

    goToNext();
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        padding: EdgeInsets.all(100),
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png'),
            SizedBox(height: 30),
            LinearProgressIndicator(
              color: Palette.authInputColor,
            ),
          ],
        ),
      ),
    );
  }
}
