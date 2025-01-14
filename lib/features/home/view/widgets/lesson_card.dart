import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/functions.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/lesson.dart';
import 'package:iskole/features/home/view/pages/lesson_add_update_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Chapter chapter;
  final VoidCallback fetchData;
  LessonCard(
      {super.key,
      required this.lesson,
      required this.chapter,
      required this.fetchData});
  final GlobalKey _textKey = GlobalKey();
  RxBool isOverflow = false.obs;

  @override
  Widget build(BuildContext context) {
    void _launchURL(url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    bool isZoomLink = checkLink(lesson.link) == "ZOOM";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              lesson.lessonNumber != null
                  ? "${lesson.lessonNumber}. ${lesson.title}"
                  : lesson.title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Palette.welcomeButtonTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Ink(
              decoration: BoxDecoration(
                // color: Palette.authInputColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    Get.to(AddLessonPage(
                      chapter: chapter,
                      lesson: lesson,
                    ))?.then((value) {
                      fetchData();
                    });
                  },
                  child: Visibility(
                    visible: UserInstance.appUser!.role == "TEACHER" &&
                        UserInstance.appUser!.isActivated,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.edit,
                        color: Palette.welcomeButtonTextColor,
                      ),
                    ),
                  )),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Stack(
          children: [
            CachedNetworkImage(
              width: Get.width,
              height: Get.width / 2,
              fit: BoxFit.cover,
              imageUrl: lesson.image,
              placeholder: (context, text) {
                return Image.asset(
                  "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Button.secondary(
                onPressed: () {
                  _launchURL(lesson.link);
                },
                background: isZoomLink
                    ? Colors.blue.withOpacity(0.8)
                    : Colors.red.withOpacity(0.8),
                label: isZoomLink ? "Open In Zoom" : "Open In YouTube",
                width: 150,
                height: 36,
                fontSize: 14,
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          lesson.description,
          style: TextStyle(color: Palette.welcomeButtonTextColor),
        ),
        SizedBox(
          height: 10,
        ),
        Wrap(
          spacing: !lesson.activity.isNull &&
                  !lesson.reference.isNull &&
                  lesson.reference != "" &&
                  lesson.reference != ""
              ? 10
              : 0,
          children: [
            Visibility(
              visible: !lesson.reference.isNull && lesson.reference != "",
              child: Button.secondary(
                  onPressed: () {
                    _launchURL(lesson.reference);
                  },
                  label: "Download Reference",
                  width: 175,
                  height: 36,
                  fontSize: 14,
                  padding: EdgeInsets.symmetric(horizontal: 20)),
            ),
            Visibility(
              visible: !lesson.activity.isNull && lesson.activity != "",
              child: Button.secondary(
                  onPressed: () {
                    _launchURL(lesson.activity);
                  },
                  label: "Download Activity",
                  width: 160,
                  height: 36,
                  fontSize: 14,
                  padding: EdgeInsets.symmetric(horizontal: 20)),
            ),
          ],
        ),
        Divider(
          color: Palette.welcomeButtonTextColor.withOpacity(0.05),
          height: 40,
        )
      ],
    );
  }
}

//
class PlaceHolderLessonCard {
  static Widget get(ref) {
    Lesson lesson = Lesson(
        image:
            "https://firebasestorage.googleapis.com/v0/b/elearning-5f0a1.appspot.com/o/organic-flat-online-medical-conference-illustration_23-2148887379.jpg?alt=media&token=50230312-e2b2-498a-8da8-203887ea1ce3",
        title: "Place Holder Title",
        link: "",
        description:
            "Place Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder Title",
        grade: ref,
        subject: ref,
        chapter: ref,
        ref: ref);
    Chapter chapter = Chapter(
        image: "",
        title: "Place Holder Title",
        grade: ref,
        subject: ref,
        ref: ref);
    return LessonCard(
      lesson: lesson,
      chapter: chapter,
      fetchData: () {},
    );
  }
}
