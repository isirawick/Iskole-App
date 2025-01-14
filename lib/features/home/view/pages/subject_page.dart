import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/CommonCard.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/subject.dart';
import 'package:iskole/features/home/view/widgets/EmptyWidget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'chapter_page.dart';

class SubjectPage extends StatelessWidget {
  final Subject subject;
  SubjectPage({
    super.key,
    required this.subject,
  });

  RxList<Chapter> chapterList = RxList();

  RxBool isLoading = true.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    void fetchSubjects() async {
      chapterList.clear();
      isLoading.value = true;
      QuerySnapshot querySnapshot =
      await _firestore.collection('chapters_v2').where('subject',isEqualTo: subject.ref).get();
      for (var chapter in querySnapshot.docs) {
        Map<String, dynamic> chapterData = chapter.data() as Map<String, dynamic>;
        chapterList.add(
          Chapter(
            image: chapterData['image'] ?? "",
            title: chapterData['title'] ?? "",
            subject: chapterData['subject'] ?? subject.ref,
            grade: chapterData['grade'] ?? subject.grade,
            ref: chapter.reference
          ),
        );
      }
      isLoading.value = false;
    }

    fetchSubjects();

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.title),
      ),
      body: Obx(
        () =>  isLoading.value || chapterList.isNotEmpty?GridView.count(
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.15,
          padding: EdgeInsets.all(20),
          children: List.generate(isLoading.value?10:chapterList.length, (index) {
            if (isLoading.value) {
              return Skeletonizer(
                enabled: true,
                ignoreContainers: true,
                child: PlaceHolderCard(),
              );
            }
            Chapter chapter = chapterList[index];
            return CommonCard(
                title: chapter.title,
                imageUrl: chapter.image,
                onPressed: () {
                  Get.to(ChapterPage(chapter: chapter));
                });
          }),
        ):EmptyWidget(itemName: "chapter"),
      ),
    );
  }
}
