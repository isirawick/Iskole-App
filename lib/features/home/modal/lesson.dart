import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String image;
  final String? lessonNumber;
  final String title;
  final String description;
  final String link;
  final DocumentReference grade;
  final DocumentReference subject;
  final DocumentReference chapter;
  final DocumentReference ref;
  final String? reference;
  final String? activity;

  Lesson(
      {required this.image,
      required this.title,
      required this.link,
      required this.description,
      required this.grade,
      required this.subject,
      required this.chapter,
      required this.ref,
      this.lessonNumber,
      this.activity,
      this.reference});
}
