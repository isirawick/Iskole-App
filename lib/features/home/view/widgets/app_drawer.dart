import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/view/pages/account_update.dart';
import 'package:iskole/features/auth/view/pages/welcome_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    print(UserInstance.appUser?.lastName);
    return Drawer(
      backgroundColor: Colors.white,
      width: Get.width - 80,
      shape: OutlineInputBorder(borderSide: BorderSide.none),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              width: 10,
            ),
            CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                  "https://firebasestorage.googleapis.com/v0/b/elearning-5f0a1.appspot.com/o/boy_avatar_icon_148455.webp?alt=media&token=20b3577a-2c3c-4394-8d4a-8659abb1b60d"),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "${UserInstance.appUser?.firstName} ${UserInstance.appUser?.lastName}",
              style: TextStyle(
                  color: Palette.welcomeButtonTextColor, fontSize: 20),
            ),
            Text(
              "${UserInstance.appUser?.phoneNumber}",
              style: TextStyle(
                  color: Palette.welcomeButtonTextColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline),
            ),
            Text(
              "${UserInstance.appUser?.role}".capitalizeFirst.toString(),
              style: TextStyle(
                  color: Palette.welcomeButtonTextColor, fontSize: 15),
            ),
            Divider(
              height: 40,
              color: Palette.welcomeButtonTextColor.withOpacity(0.1),
            ),
            Text(
              'Welcome to Iskoole!',
              style: TextStyle(
                fontSize: 24,
                color: Palette.welcomeButtonTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              UserInstance.appUser!.role == "STUDENT"
                  ? 'Your learning journey begins here.'
                  : 'Your journey in shaping minds begins here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.welcomeButtonTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Spacer(),
            Button.secondary(
                color: Palette.welcomeButtonTextColor.withOpacity(0.7),
                background: Palette.welcomeButtonTextColor.withOpacity(0.1),
                onPressed: () {
                  Get.back();
                  Get.to(ProfilePage());
                },
                label: "Edit Profile"),
            SizedBox(
              height: 12,
            ),
            Button.secondary(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  UserInstance.clear();
                  Get.offAll(WelcomePage());
                },
                label: "Logout")
          ]),
        ),
      ),
    );
  }
}
