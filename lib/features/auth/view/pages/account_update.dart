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
import 'package:iskole/core/modal/user.dart';
import 'package:iskole/features/auth/view/widgets/DistrictDropdown.dart';
import 'package:iskole/features/auth/view/widgets/auth_input.dart';
import 'package:iskole/features/home/view/pages/home_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  RxString accountType = "STUDENT".obs;
  String selectedDistrict = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

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

  Future<void> _update(AppUser user) async {
    isLoading.value = true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String firstName = _firstNameController.text.trim();
        String lastName = _lastNameController.text.trim();
        String birthday = _birthdayController.text.trim();
        String schoolName = _schoolNameController.text.trim();
        String district = selectedDistrict;

        await user.id.update({
          'firstName': firstName,
          'lastName': lastName,
          'birthday': birthday,
          'schoolName': schoolName,
          'district': district,
        });

        UserInstance.setUser(
          id: user.id,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: user.phoneNumber,
          role: user.role,
          birthday: birthday,
          district: district,
          school: user.school,
          isActivated: user.isActivated,
        );
        Get.back();
        Alert.success(title: "Success!", text: "Successfully updated profile.");

        isLoading.value = false;
      } catch (e) {
        print(e);
        isLoading.value = false;
      }

      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppUser? user = UserInstance.appUser;
    if (user != null) {
      _birthdayController.text = user.birthday;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _schoolNameController.text = user.school;
      selectedDistrict = user.district;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
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
                          value: selectedDistrict,
                          validator: _validateDistrict,
                          onChange: (district) {
                            selectedDistrict = district ?? "";
                          }),
                      SizedBox(height: 30),
                      Obx(
                        () => Button.primary(
                            isLoading: isLoading.value,
                            onPressed: () {
                              _update(user!);
                            },
                            label: 'Update'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
