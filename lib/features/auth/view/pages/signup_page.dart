import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_gradients.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/auth/services/otp_service.dart';
import 'package:iskole/features/auth/view/pages/otp_page.dart';
import 'package:iskole/features/auth/view/pages/signin_page.dart';
import 'package:iskole/features/auth/view/widgets/DistrictDropdown.dart';
import 'package:iskole/features/auth/view/widgets/auth_input.dart';
import 'package:iskole/features/auth/view/widgets/selectable_button.dart';
import 'package:iskole/features/home/view/pages/home_page.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  RxString accountType = "STUDENT".obs;
  String selectedDistrict = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final OtpService _otpService = OtpService();

  RxBool isLoading = false.obs;
  RxBool passwordVisible = false.obs;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? _validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a district';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (value.length < 9) {
      return 'Phone number must be at least 9 digits';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    return null;
  }

  String? _validateSchool(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your school name';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    return null;
  }

  String? validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signup(context) async {
    isLoading.value = true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String phoneNumber = _phoneNumberController.text.trim();
        String firstName = _firstNameController.text.trim();
        String lastName = _lastNameController.text.trim();
        String birthday = _birthdayController.text.trim();
        String schoolName = _schoolNameController.text.trim();
        String password = _passwordController.text;
        String district = selectedDistrict;

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: "94${phoneNumber}@iskole.com",
          password: password,
        );
        User? user = userCredential.user;

        // If user is created successfully
        if (user != null) {
          // Save additional user data to Firestore
          DocumentReference userRef =
              _firestore.collection('users_v2').doc(user.uid);
          await userRef.set({
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': '94$phoneNumber',
            'birthday': birthday,
            'schoolName': schoolName,
            'district': district,
            'role': accountType.value,
            'isActivated': accountType.value == 'STUDENT',
            'createdAt': FieldValue.serverTimestamp(),
          });
          UserInstance.setUser(
            id: userRef,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: '94$phoneNumber',
            role: accountType.value,
            birthday: birthday,
            district: district,
            school: schoolName,
            isActivated: false,
          );
          final otpResult = await _otpService.generateOTP('+94$phoneNumber');

          if (otpResult['success']) {
            Get.offAll(() => OtpPage(
                  phoneNumber: '+94$phoneNumber',
                ));
            return;
          }
          Get.offAll(() => Home());
          Alert.success(
              title: "Welcome!",
              text:
                  "You have successfully registered to Iskoole. Welcome to Iskoole.");
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Something went wrong.";
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that phone number.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password provided.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The phone number is not valid.';
        }
        if (e.code == 'invalid-credential') {
          errorMessage = 'The phone number and password do not match.';
        }
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The phone number already in use.';
        } else {
          errorMessage = 'An unknown error occurred. Please try again.';
        }
        print(e.code);
        Alert.error(title: "Oooops!", text: errorMessage);
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
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
                        children: [
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: (Get.width / 2) - 30,
                                child: AuthInput(
                                  label: "First name",
                                  controller: _firstNameController,
                                  prefix: SvgPicture.asset(
                                    'assets/svg/people.svg',
                                    height: 18,
                                    width: 18,
                                  ),
                                  validator: _validateName,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: (Get.width / 2) - 30,
                                child: AuthInput(
                                  label: "Last name",
                                  controller: _lastNameController,
                                  prefix: SvgPicture.asset(
                                    'assets/svg/people.svg',
                                    height: 18,
                                    width: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
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
                          SizedBox(height: 5),
                          AuthInput(
                            label: "Birthday",
                            controller: _birthdayController,
                            validator: _validateDate,
                            prefix: SvgPicture.asset(
                              'assets/svg/calendar.svg',
                              height: 18,
                              width: 18,
                            ),
                            readOnly: true,
                            keyboardType: TextInputType.datetime,
                            onPressed: () {
                              DatePickerBdaya.showDatePicker(
                                context,
                                minTime: DateTime(1950),
                                maxTime: DateTime.now(),
                                currentTime: DateTime(2010),
                                onConfirm: (date) {
                                  _birthdayController.text =
                                      DateFormat("yyyy-MM-dd").format(date);
                                },
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          AuthInput(
                            label: "School",
                            validator: _validateSchool,
                            controller: _schoolNameController,
                            prefix: SvgPicture.asset(
                              'assets/svg/school.svg',
                              height: 18,
                              width: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          DistrictDropdown(
                              validator: _validateDistrict,
                              onChange: (district) {
                                selectedDistrict = district ?? "";
                              }),
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Account type',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.authInputColor),
                            ),
                          ),
                          SizedBox(height: 10),
                          Obx(
                            () => Row(
                              children: [
                                Container(
                                  width: (Get.width / 2) - 30,
                                  child: SelectableButton(
                                    text: "Student",
                                    selected: accountType.value == "STUDENT",
                                    onPressed: () {
                                      accountType.value = "STUDENT";
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: (Get.width / 2) - 30,
                                  child: SelectableButton(
                                    text: "Teacher",
                                    selected: accountType.value == "TEACHER",
                                    onPressed: () {
                                      accountType.value = "TEACHER";
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Obx(
                            () => AuthInput(
                                label: "Password",
                                controller: _passwordController,
                                validator: validatePassword,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                isObscured: !passwordVisible.value,
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
                          SizedBox(height: 10),
                          Obx(
                            () => AuthInput(
                                label: "Confirm password",
                                controller: _confirmPasswordController,
                                validator: validateConfirmPassword,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                isObscured: !passwordVisible.value,
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
                          SizedBox(height: 30),
                          Obx(
                            () => Button.primary(
                                isLoading: isLoading.value,
                                onPressed: () {
                                  _signup(context);
                                },
                                label: 'Sign Up'),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              // Left line
                              Expanded(
                                child: Divider(
                                  thickness: 1, // Adjust the thickness
                                  color:
                                      Palette.gradient3, // Set the line color
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Do you have an account?",
                                style: TextStyle(
                                    color: Palette.welcomeButtonTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Button.text(
                                  onPressed: () {
                                    Get.off(() => SigninPage());
                                  },
                                  label: "Sign In")
                            ],
                          )
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
