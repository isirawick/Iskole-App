import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/components/CommonCard.dart';
import 'package:iskole/core/components/ConfirmDialog.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/features/home/modal/grade.dart';
import 'package:iskole/features/home/view/pages/grade_page.dart';
import 'package:iskole/features/home/view/pages/stream_page.dart';
import 'package:iskole/features/home/view/widgets/app_drawer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Grade> gradeList = RxList<Grade>();

  RxBool IsLoading = true.obs;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    void getDeviceToken() async {
      String? token = await FirebaseMessaging.instance.getToken();

      print('FCM Device Token: $token');
    }

    void fetchGrades() async {
      IsLoading.value = true;
      gradeList.clear();
      QuerySnapshot querySnapshot =
          await _firestore.collection('grades_v2').orderBy('order').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> gradeData = doc.data() as Map<String, dynamic>;
        gradeList.add(
          Grade(
            ref: doc.reference,
            image: gradeData['image'],
            title: gradeData['title'],
            hasStream: gradeData['hasStream'],
          ),
        );
      }

      IsLoading.value = false;
    }

    getDeviceToken();
    fetchGrades();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 80,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset("assets/logo.png"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              padding: EdgeInsets.all(16),
              icon: SvgPicture.asset("assets/svg/menu.svg"),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          bool? confirm = await ConfirmDialog.ask(message: "Confirm Exit");
          if (confirm != null && confirm) {
            SystemNavigator.pop(animated: true);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: UserInstance.appUser!.role == "TEACHER" &&
                          !UserInstance.appUser!.isActivated
                      ? 100
                      : 0),
              child: Obx(
                () => GridView.count(
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.15,
                  padding: EdgeInsets.all(20),
                  children: List.generate(
                      IsLoading.value ? 10 : gradeList.length, (index) {
                    if (IsLoading.value) {
                      return Skeletonizer(
                        enabled: true,
                        ignoreContainers: true,
                        child: PlaceHolderCard(),
                      );
                    }
                    Grade grade = gradeList[index];
                    return CommonCard(
                        title: grade.title,
                        imageUrl: grade.image,
                        notificationTopic: grade.ref.id,
                        onPressed: () {
                          if (grade.hasStream) {
                            Get.to(StreamPage(grade: grade));
                          } else {
                            Get.to(GradePage(grade: grade));
                          }
                        });
                  }),
                ),
              ),
            ),
            Visibility(
                visible: UserInstance.appUser!.role == "TEACHER" &&
                    !UserInstance.appUser!.isActivated,
                child: Container(
                  color: Colors.red.withOpacity(0.1),
                  height: 100,
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.withOpacity(0.6),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Your account is pending approval.\n You can add lessons once approved.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Button.text(
                          onPressed: () async {
                            CollectionReference users = FirebaseFirestore
                                .instance
                                .collection('users_v2');
                            QuerySnapshot querySnapshot = await users
                                .where('phoneNumber',
                                    isEqualTo:
                                        UserInstance.appUser?.phoneNumber)
                                .get();
                            if (querySnapshot.docs.isNotEmpty) {
                              Map userData = querySnapshot.docs.first.data()
                                  as Map<String, dynamic>;
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
                              if (userData['isActivated'] == true) {
                                Alert.success(
                                    title: "Account Activated!",
                                    text:
                                        "Your account has been approved by an admin.");
                                setState(() {});
                              } else {
                                Alert.error(
                                    title: "Oooops!",
                                    text: "Your account is still pending.");
                              }
                            }
                          },
                          label: "Check Again",
                          fontSize: 12,
                          padding: EdgeInsets.zero),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
