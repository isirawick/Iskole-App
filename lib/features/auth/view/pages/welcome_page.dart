import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/ConfirmDialog.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/view/pages/signin_page.dart';
import 'package:iskole/features/auth/view/pages/signup_page.dart';
import 'package:iskole/features/auth/view/widgets/welcome_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop:false,
        onPopInvoked: (didPop) async{
          if( didPop) return;
          bool? confirm = await ConfirmDialog.ask(message: "Confirm Exit");
          if(confirm!=null && confirm){
            SystemNavigator.pop(animated: true);
          }
        },
        child: Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 95,
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/welcome.png',
                  height: Get.height / 3,
                ),
                const SizedBox(height: 30),
                WelcomeButton(
                  text: 'Sign In',
                  onPressed: () {
                    Get.to(SigninPage());
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'or',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                WelcomeButton(
                  text: 'Sign Up',
                  onPressed: () {
                    Get.to(SignupPage());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
