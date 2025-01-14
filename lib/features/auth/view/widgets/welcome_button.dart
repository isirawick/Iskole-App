import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/theme/app_palette.dart';

class WelcomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  WelcomeButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          Get.width - 80,
          54,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Palette.welcomeButtonTextColor,
        ),
      ),
    );
  }
}
