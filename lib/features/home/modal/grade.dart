import 'package:cloud_firestore/cloud_firestore.dart';

class Grade{
  final String image;
  final String title;
  final bool hasStream;
  final DocumentReference ref;

  Grade({required this.image, required this.title, required this.hasStream, required this.ref});

}