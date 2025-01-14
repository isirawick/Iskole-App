import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter{
  final String image;
  final String title;
  final DocumentReference grade;
  final DocumentReference subject;
  final DocumentReference ref;

  Chapter({required this.image, required this.title,required this.grade,required this.subject,required this.ref,});
}