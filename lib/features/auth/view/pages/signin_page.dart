import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/features/auth/view/pages/forgot_password_page.dart';
import 'package:iskole/features/auth/view/pages/otp_page.dart';
import 'package:iskole/features/auth/view/pages/signup_page.dart';
import 'package:iskole/features/auth/view/widgets/auth_input.dart';
import 'package:iskole/features/auth/view/widgets/selectable_button.dart';
import 'package:iskole/features/home/view/pages/home_page.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RxBool passwordVisible = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final OtpService _otpService = OtpService();

  RxBool isLoading = false.obs;
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (value.length < 9) {
      return 'Phone number must be at least 9 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String removeDomain(String email) {
    List<String> parts = email.split('@');
    return parts[0];
  }

  Future<void> _signin() async {
    isLoading.value = true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String phoneNumber = _phoneNumberController.text.trim();
        String password = _passwordController.text;

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: "94$phoneNumber@iskole.com", password: password);
        User? user = userCredential.user;

        // If user is created successfully
        if (user != null) {
          CollectionReference users =
              FirebaseFirestore.instance.collection('users_v2');
          QuerySnapshot querySnapshot = await users
              .where('phoneNumber', isEqualTo: removeDomain(user.email!))
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            Map userData =
                querySnapshot.docs.first.data() as Map<String, dynamic>;
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
            Get.offAll(Home(), transition: Transition.fade);
            return;
          }
          Alert.error(
              title: "Oooops!",
              text:
                  "Your account has been banned or something has occurred. Please contact an administrator.");
          // Get.offAll(() => Home());
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        String _errorMessage = "Something went wrong.";
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that phone number.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Incorrect password provided.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'The phone number is not valid.';
        }
        if (e.code == 'invalid-credential') {
          _errorMessage = 'The phone number and password do not match.';
        } else {
          _errorMessage = 'An unknown error occurred. Please try again.';
        }
        print(e.code);
        Alert.error(title: "Oooops!", text: _errorMessage);
        isLoading.value = false;
      } catch (e) {
        print(e);
        isLoading.value = false;
      }
    }
    isLoading.value = false;
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // SizedBox(
                //   height: 20,
                // ),
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
                        topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                      fontSize: 36,
                                      color: Palette.welcomeButtonTextColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  child: Image.asset(
                                    'assets/images/child.png',
                                    width: 180,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          AuthInput(
                            label: "Phone Number",
                            prefixText: "+94",
                            controller: _phoneNumberController,
                            validator: _validatePhoneNumber,
                            keyboardType:
                                TextInputType.numberWithOptions(signed: true),
                            maxLength: 9,
                            prefix: SvgPicture.asset(
                              'assets/svg/phone.svg',
                              height: 18,
                              width: 18,
                              color: Palette.authInputColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Obx(
                            () => AuthInput(
                                label: "Password",
                                controller: _passwordController,
                                isObscured: !passwordVisible.value,
                                validator: _validatePassword,
                                prefix: SvgPicture.asset(
                                  'assets/svg/lock.svg',
                                  height: 18,
                                  width: 18,
                                ),
                                suffix: IconButton(
                                    onPressed: () {
                                      passwordVisible.value =
                                          !passwordVisible.value;
                                    },
                                    icon: Icon(!passwordVisible.value
                                        ? Icons.visibility_off
                                        : Icons.visibility))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Button.text(
                                underline: false,
                                onPressed: () {
                                  Get.off(() => ForgotPasswordPage());
                                },
                                fontSize: 16,
                                label: "Forgot Password?"),
                          ),
                          SizedBox(height: 30),
                          Obx(
                            () => Button.primary(
                              isLoading: isLoading.value,
                              onPressed: () async {
                                await _signin();
                              },
                              label: 'Login',
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              // Left line
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Palette.gradient3,
                                ),
                              ),
                              // "OR" text
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Palette.gradient3, // Set the text color
                                    fontSize: 16, // Adjust the font size
                                  ),
                                ),
                              ),
                              // Right line
                              Expanded(
                                child: Divider(
                                  thickness: 1, // Adjust the thickness
                                  color:
                                      Palette.gradient3, // Set the line color
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't you have an account?",
                                style: TextStyle(
                                    color: Palette.welcomeButtonTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Button.text(
                                  onPressed: () {
                                    Get.off(() => SignupPage());
                                  },
                                  label: "Sign Up")
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
