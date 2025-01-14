import 'package:cloud_firestore/cloud_firestore.dart';

class AppStream{
  final String title;
  final DocumentReference ref;

  AppStream({required this.title,required this.ref});

}