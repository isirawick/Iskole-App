import 'package:cloud_firestore/cloud_firestore.dart';

class Subject{
  final String image;
  final String title;
  final DocumentReference grade;
  final DocumentReference ref;

  Subject({required this.image, required this.title,required this.grade, required this.ref});
}