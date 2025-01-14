import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  final DocumentReference id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String birthday;
  final String district;
  final String school;
  final bool isActivated;

  AppUser({required this.id, required this.firstName,required this.phoneNumber,  this.lastName="", required this.role, required this.birthday, required this.district, required this.school,required this.isActivated});
}