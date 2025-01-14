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
import 'package:iskole/features/home/modal/paper.dart';
import 'package:iskole/features/home/view/pages/lesson_add_update_page.dart';
import 'package:iskole/features/home/view/pages/paper_add_update_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  final Chapter chapter;
  final VoidCallback fetchData;
  PaperCard(
      {super.key,
      required this.paper,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              paper.lessonNumber != null
                  ? "${paper.lessonNumber}. ${paper.title}"
                  : paper.title,
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
                    Get.to(AddPaperPage(
                      chapter: chapter,
                      paper: paper,
                    ))?.then((value) {
                      fetchData();
                    });
                  },
                  child: Visibility(
                    visible: UserInstance.appUser!.role == "TEACHER" &&
                        UserInstance.appUser!.isActivated &&
                        paper.createdBy == UserInstance.appUser!.id,
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
              imageUrl: paper.thumbnail ?? "",
              placeholder: (context, text) {
                return Image.asset(
                  "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          paper.description,
          style: TextStyle(color: Palette.welcomeButtonTextColor),
        ),
        SizedBox(
          height: 10,
        ),
        Button.secondary(
            onPressed: () {
              _launchURL(paper.paperUrl);
            },
            label: "Download Paper",
            width: 160,
            height: 36,
            fontSize: 14,
            padding: EdgeInsets.symmetric(horizontal: 20)),
        Divider(
          color: Palette.welcomeButtonTextColor.withOpacity(0.05),
          height: 40,
        )
      ],
    );
  }
}

//
class PlaceHolderPaperCard {
  static Widget get(ref) {
    Paper paper = Paper(
        thumbnail:
            "https://firebasestorage.googleapis.com/v0/b/elearning-5f0a1.appspot.com/o/organic-flat-online-medical-conference-illustration_23-2148887379.jpg?alt=media&token=50230312-e2b2-498a-8da8-203887ea1ce3",
        title: "Place Holder Title",
        description:
            "Place Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder TitlePlace Holder Title",
        chapter: ref,
        createdAt: Timestamp.now(),
        createdBy: ref,
        ref: ref);
    Chapter chapter = Chapter(
        image: "",
        title: "Place Holder Title",
        grade: ref,
        subject: ref,
        ref: ref);
    return PaperCard(
      paper: paper,
      chapter: chapter,
      fetchData: () {},
    );
  }
}
