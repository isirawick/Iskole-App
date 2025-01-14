import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/CommonCard.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/home/modal/grade.dart';
import 'package:iskole/features/home/modal/stream.dart';
import 'package:iskole/features/home/modal/subject.dart';
import 'package:iskole/features/home/view/pages/grade_page.dart';
import 'package:iskole/features/home/view/pages/subject_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StreamPage extends StatelessWidget {
  final Grade grade;
  StreamPage({
    super.key,
    required this.grade,
  });

  RxBool isLoading = true.obs;
  RxList<AppStream> streamList = RxList();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    void fetchSubjects() async {
      streamList.clear();
      isLoading.value = true;
      QuerySnapshot querySnapshot =
      await _firestore.collection('streams_v2').where('grade',isEqualTo: grade.ref).get();
      for (var stream in querySnapshot.docs) {
        Map<String, dynamic> streamData = stream.data() as Map<String, dynamic>;
        streamList.add(
          AppStream(
              title: streamData['title'] ?? "",
              ref: stream.reference),
        );
      }
      isLoading.value = false;
    }

    fetchSubjects();

    return Scaffold(
      appBar: AppBar(
        title: Text(grade.title),
      ),
      backgroundColor: Colors.white,
      body: Obx(
        () => GridView.count(
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          crossAxisCount: 1,
          childAspectRatio: 6/1,
          padding: EdgeInsets.all(20),
          children: List.generate(isLoading.value?5:streamList.length, (index) {
            if (isLoading.value) {
              return Skeletonizer(
                enabled: true,
                ignoreContainers: false,
                containersColor: Colors.grey.withOpacity(0.1),
                child: Container(
                    decoration: BoxDecoration(
                        color: Palette.gradient3,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: Text("Stream Title",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),))
                ),
              );
            }
            AppStream stream = streamList[index];
            return InkWell(
              child: Container(
                decoration: BoxDecoration(
                  color: Palette.authInputColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                  child: Center(child: Text(stream.title,style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),))
              ),
                onTap: () {
                  Get.to(GradePage(grade:grade,stream: stream));
                });
          }),
        ),
      ),
    );
  }
}
