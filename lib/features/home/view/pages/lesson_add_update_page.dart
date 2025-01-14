import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/components/ConfirmDialog.dart';
import 'package:iskole/core/functions.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/lesson.dart';
import 'package:iskole/features/home/view/widgets/file_select.dart';
import 'package:iskole/features/home/view/widgets/home_input.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:iskole/core/services/notification_service.dart';

class AddLessonPage extends StatelessWidget {
  final Chapter chapter;
  final Lesson? lesson;
  AddLessonPage({super.key, required this.chapter, this.lesson});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _lessonNumberController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  File? reference;
  RxBool referenceIsLoading = false.obs;
  RxBool referenceIsCompleted = false.obs;
  File? activity;
  RxBool activityIsLoading = false.obs;
  RxBool activityIsCompleted = false.obs;

  RxString referenceLink = "".obs;
  RxString activityLink = "".obs;

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? _validateLink(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Lesson Link';
    } else if (checkLink(value) == "INVALID") {
      return 'Please enter a Valid Link';
    }
    return null;
  }

  String? _validateLessonNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }

    // Check if the format matches numbers separated by dots (e.g., 1.2.3)
    final RegExp format = RegExp(r'^\d+(\.\d+)*$');
    if (!format.hasMatch(value)) {
      showSnackBar(message: "Please enter a Valid Link");
      return 'Format should be like 1.2.3';
    }

    return null;
  }

  Future<void> _saveLesson() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        late DocumentReference lessonRef;

        if (reference != null) {
          Reference storageRef = _storage.ref().child(
              'references/${DateTime.now().millisecondsSinceEpoch}${basename(reference!.path)}');
          UploadTask uploadTask = storageRef.putFile(reference!);
          await uploadTask.whenComplete(() async {
            referenceLink.value = await storageRef.getDownloadURL();
          });
        }
        if (activity != null) {
          Reference storageRef = _storage.ref().child(
              'activities/${DateTime.now().millisecondsSinceEpoch}${basename(activity!.path)}');
          UploadTask uploadTask = storageRef.putFile(activity!);
          await uploadTask.whenComplete(() async {
            activityLink.value = await storageRef.getDownloadURL();
          });
        }
        var data = {
          'activity': activityLink.value,
          'reference': referenceLink.value,
          'chapter': chapter.ref,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'link': _linkController.text.trim(),
          'lessonNumber': _lessonNumberController.text.trim(),
          'createdBy': UserInstance.appUser!.id,
        };

        print(lesson?.reference);
        if (lesson != null) {
          lessonRef = lesson!.ref;

          await lessonRef.update(data);
        } else {
          data['createdAt'] = FieldValue.serverTimestamp();
          lessonRef = _firestore.collection('lessons_v2').doc();
          await lessonRef.set(data);
        }

        // Send notification after successful save
        if (lesson == null) {
          // Only send notification for new lessons
          await NotificationService.sendNotificationToTopic(
            topic: chapter.grade.id,
            title: 'New Lesson Available',
            body: '${_titleController.text} has been added to ${chapter.title}',
            data: {
              'type': 'lesson',
              'lessonId': lessonRef.id,
              'gradeId': chapter.grade.id,
              'subjectId': chapter.subject.id,
              'chapterId': chapter.ref.id,
              'chapterRef': chapter.ref.path,
            },
          );
        }

        Get.back();
        Alert.success(
            title: "Success!",
            text: lesson == null
                ? "Lesson added successfully"
                : "Lesson updated successfully");

        isLoading.value = false;
      } catch (e) {
        print(e);
        isLoading.value = false;
      }
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    _chapterController.text = chapter.title;
    if (lesson != null) {
      _titleController.text = lesson!.title;
      _descriptionController.text = lesson!.description;
      _linkController.text = lesson!.link;
      _lessonNumberController.text = (lesson!.lessonNumber ?? '').toString();
      referenceIsCompleted.value =
          !(lesson!.reference.isNull || lesson!.reference == "");
      referenceLink.value = lesson!.reference ?? "";
      activityLink.value = lesson!.activity ?? "";
      activityIsCompleted.value =
          !(lesson!.activity.isNull || lesson!.activity == "");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.isNull ? 'Add New Lesson' : 'Update Lesson'),
        actions: [
          Visibility(
            visible: lesson != null,
            child: IconButton(
                onPressed: () async {
                  bool? confirm =
                      await ConfirmDialog.ask(message: "Confirm Delete");
                  if (confirm != null && confirm) {
                    lesson?.ref.delete();
                    Get.back();
                  }
                },
                icon: Icon(Icons.delete_outline)),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                HomeInput(
                  label: "Chapter",
                  controller: _chapterController,
                  readOnly: true,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: HomeInput(
                        label: "No *",
                        controller: _lessonNumberController,
                        validator: _validateLessonNumber,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 8,
                      child: HomeInput(
                        label: "Lesson Title *",
                        controller: _titleController,
                        validator: _validateTitle,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                HomeInput(
                  label: "Attachment (Zoom or YouTube) *",
                  controller: _linkController,
                  validator: _validateLink,
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // isEnabled: false,
                ),
                SizedBox(
                  height: 16,
                ),
                HomeInput(
                  label: "Description",
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  // isEnabled: false,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FileSelect(
                        label: "Reference",
                        onPick: (file) {
                          reference = file;
                        },
                        clear: () {
                          referenceLink.value = "";
                        },
                        isLoading: referenceIsLoading,
                        isSuccess: referenceIsCompleted,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: FileSelect(
                      label: "Activity",
                      onPick: (file) {
                        activity = file;
                      },
                      clear: () {
                        activityLink.value = "";
                      },
                      isLoading: activityIsLoading,
                      isSuccess: activityIsCompleted,
                    )),
                  ],
                ),
                SizedBox(height: 30),
                Obx(
                  () => Button.primary(
                      isLoading: isLoading.value,
                      onPressed: () {
                        _saveLesson();
                      },
                      label: lesson.isNull ? 'Add Lesson' : 'Update Lesson'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
