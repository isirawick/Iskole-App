import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/components/CommonCard.dart';
import 'package:iskole/core/functions.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/grade.dart';
import 'package:iskole/features/home/modal/lesson.dart';
import 'package:iskole/features/home/modal/paper.dart';
import 'package:iskole/features/home/modal/subject.dart';
import 'package:iskole/features/home/view/pages/lesson_add_update_page.dart';
import 'package:iskole/features/home/view/pages/paper_add_update_page.dart';
import 'package:iskole/features/home/view/widgets/EmptyWidget.dart';
import 'package:iskole/features/home/view/widgets/lesson_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:iskole/features/home/view/widgets/add_content_dialog.dart';
import 'package:iskole/features/home/view/widgets/paper_card.dart';

// First, create a mixin class to handle both types
class ContentItem {
  final String number;
  final dynamic item;

  ContentItem(this.number, this.item);
}

class ChapterPage extends StatelessWidget {
  final Chapter chapter;
  ChapterPage({
    super.key,
    required this.chapter,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ContentItem> contentList = RxList();
  RxBool isLoading = true.obs;

  // Helper method to parse lesson/paper number
  double _parseNumber(String? number) {
    if (number == null || number.isEmpty) return double.infinity;
    try {
      return number
          .split('.')
          .map(int.parse)
          .reduce((a, b) => a * 1000 + b)
          .toDouble();
    } catch (e) {
      return double.infinity;
    }
  }

  void fetchLessonData() async {
    isLoading.value = true;
    contentList.clear();

    // Fetch lessons
    QuerySnapshot lessonSnapshot = await _firestore
        .collection('lessons_v2')
        .where('chapter', isEqualTo: chapter.ref)
        .get();

    // Fetch papers
    QuerySnapshot paperSnapshot = await _firestore
        .collection('papers_v2')
        .where('chapter', isEqualTo: chapter.ref)
        .get();

    // Add lessons to content list
    for (var lesson in lessonSnapshot.docs) {
      Map<String, dynamic> lessonData = lesson.data() as Map<String, dynamic>;
      Lesson lessonItem = Lesson(
        image: getImageByLink(lessonData['link']),
        title: lessonData['title'] ?? "",
        description: lessonData['description'] ?? "",
        subject: lessonData['subject'] ?? chapter.ref,
        grade: lessonData['grade'] ?? chapter.grade,
        chapter: chapter.ref,
        reference: lessonData['reference'],
        activity: lessonData['activity'],
        link: lessonData['link'],
        lessonNumber: lessonData['lessonNumber'],
        ref: lesson.reference,
      );
      contentList
          .add(ContentItem(lessonData['lessonNumber'] ?? '', lessonItem));
    }

    // Add papers to content list
    for (var paper in paperSnapshot.docs) {
      Map<String, dynamic> paperData = paper.data() as Map<String, dynamic>;
      Paper paperItem = Paper(
        title: paperData['title'] ?? "",
        lessonNumber: paperData['paperNumber'] ?? "",
        description: paperData['description'] ?? "",
        thumbnail: paperData['thumbnail'] ?? "",
        paperUrl: paperData['paper'] ?? "",
        chapter: chapter.ref,
        ref: paper.reference,
        createdAt: paperData['createdAt'],
        createdBy: paperData['createdBy'],
      );
      contentList.add(ContentItem(paperData['paperNumber'] ?? '', paperItem));
    }

    // Sort the combined list
    contentList.sort(
        (a, b) => _parseNumber(a.number).compareTo(_parseNumber(b.number)));

    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    fetchLessonData();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: Obx(
        () => isLoading.value || contentList.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ListView.builder(
                  itemCount: isLoading.value ? 3 : contentList.length,
                  padding: EdgeInsets.all(20),
                  itemBuilder: (BuildContext context, int index) {
                    if (isLoading.value) {
                      return Skeletonizer(
                          ignoreContainers: true,
                          child: PlaceHolderLessonCard.get(chapter.ref));
                    }

                    final content = contentList[index];
                    if (content.item is Lesson) {
                      return LessonCard(
                        lesson: content.item,
                        chapter: chapter,
                        fetchData: fetchLessonData,
                      );
                    } else {
                      return PaperCard(
                        paper: content.item,
                        chapter: chapter,
                        fetchData: fetchLessonData,
                      );
                    }
                  },
                ),
              )
            : EmptyWidget(itemName: "content"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: UserInstance.appUser!.role == "TEACHER" &&
            UserInstance.appUser!.isActivated,
        child: Container(
            child: Button.primary(
                onPressed: () {
                  Get.dialog(
                    AddContentDialog(
                      onLessonTap: () {
                        Get.back();
                        Get.to(AddLessonPage(
                          chapter: chapter,
                        ))?.then((value) {
                          fetchLessonData();
                        });
                      },
                      onPaperTap: () {
                        Get.back();
                        Get.to(AddPaperPage(
                          chapter: chapter,
                        ))?.then((value) {
                          fetchLessonData();
                        });
                      },
                    ),
                  );
                },
                label: "Add New")),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Button.primary(onPressed: (){}, label: "Add Lesson"),
      // ),
    );
  }
}
