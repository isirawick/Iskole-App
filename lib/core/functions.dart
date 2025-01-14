import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void showSnackBar({title = "Alert", required message}) {
  Get.snackbar(
    title, // title
    message, // message
    snackPosition: SnackPosition.TOP,
    backgroundColor: Palette.appBarShadow.withOpacity(0.8),
    colorText: Colors.white,
    margin: EdgeInsets.all(10),
    duration: Duration(seconds: 3),
  );
}

Future<File?> selectDocument() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg']);

  if (result != null) {
    return File(result.files.single.path!);
  }
  return null;
}

String checkLink(String url) {
  final youtubePattern = RegExp(
    r'^(https?\:\/\/)?(www\.)?(youtube|youtu|youtube-nocookie)\.(com|be)\/(watch\?v=|[^\/]+)([a-zA-Z0-9_-]+)(\?[\S]*)?$',
    caseSensitive: false,
  );

  final zoomPattern = RegExp(
    r'^(https?\:\/\/)?(www\.)?([a-zA-Z0-9\-]+\.)?zoom\.(us|com)\/(j|wc|s|u)\/[0-9a-zA-Z]+.*$',
    caseSensitive: false,
  );

  if (youtubePattern.hasMatch(url)) {
    return 'YOUTUBE';
  } else if (zoomPattern.hasMatch(url)) {
    return 'ZOOM';
  } else {
    return 'INVALID';
  }
}

String getImageByLink(String url) {
  final regex = RegExp(
      r'(https?://(?:www\.)?youtube\.com(?:/[^/]+)*/(?:v|e(?:mbed)?)?/|(?:youtu\.be/))([a-zA-Z0-9_-]{11})');
  final match = regex.firstMatch(url);

  if (match != null) {
    final videoId = match.group(2);
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
  return 'https://firebasestorage.googleapis.com/v0/b/elearning-5f0a1.appspot.com/o/organic-flat-online-medical-conference-illustration_23-2148887379.jpg?alt=media&token=50230312-e2b2-498a-8da8-203887ea1ce3';
}

String removeDomain(String email) {
  List<String> parts = email.split('@');
  return parts[0];
}
