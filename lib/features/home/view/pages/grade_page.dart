import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/CommonCard.dart';
import 'package:iskole/features/home/modal/grade.dart';
import 'package:iskole/features/home/modal/stream.dart';
import 'package:iskole/features/home/modal/subject.dart';
import 'package:iskole/features/home/view/pages/subject_page.dart';
import 'package:iskole/features/home/view/widgets/EmptyWidget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GradePage extends StatelessWidget {
  final Grade grade;
  final AppStream? stream;
  GradePage({
    super.key,
    required this.grade,
    this.stream,
  });

  RxBool isLoading = true.obs;
  RxList<Subject> subjectList = RxList();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    void fetchSubjects() async {
      subjectList.clear();
      isLoading.value = true;
      late QuerySnapshot querySnapshot;

      if (stream != null) {
        querySnapshot = await _firestore
            .collection('subjects_v2')
            .where('streams', arrayContains: stream!.ref)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('subjects_v2')
            .where('grade', isEqualTo: grade.ref)
            .get();
      }
      for (var sub in querySnapshot.docs) {
        Map<String, dynamic> subjectData = sub.data() as Map<String, dynamic>;
        subjectList.add(
          Subject(
              image: subjectData['image'] ?? "",
              title: subjectData['title'] ?? "",
              grade: subjectData['grade'] ?? grade.ref,
              ref: sub.reference),
        );
      }
      isLoading.value = false;
    }

    fetchSubjects();

    return Scaffold(
      appBar: AppBar(
        title: Text(stream!=null? stream!.title:grade.title),
      ),
      body: Obx(
        () => isLoading.value || subjectList.isNotEmpty?GridView.count(
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.15,
          padding: EdgeInsets.all(20),
          children:
              List.generate(isLoading.value ? 10 : subjectList.length, (index) {
            if (isLoading.value) {
              return Skeletonizer(
                enabled: true,
                ignoreContainers: true,
                child: PlaceHolderCard(),
              );
            }
            Subject subject = subjectList[index];
            return CommonCard(
                title: subject.title,
                imageUrl: subject.image,
                onPressed: () {
                  Get.to(SubjectPage(subject: subject));
                });
          }),
        ):EmptyWidget(itemName: "Subject"),
      ),
    );
  }
}
