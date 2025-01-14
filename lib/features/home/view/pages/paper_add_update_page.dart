import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/Alert.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/components/ConfirmDialog.dart';
import 'package:iskole/core/functions.dart';
import 'package:iskole/core/instance/user_instance.dart';
import 'package:iskole/features/home/modal/chapter.dart';
import 'package:iskole/features/home/modal/paper.dart';
import 'package:iskole/features/home/view/widgets/file_select.dart';
import 'package:iskole/features/home/view/widgets/home_input.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:iskole/features/home/view/widgets/thumbnail_select.dart';
import 'package:iskole/core/services/notification_service.dart';

class AddPaperPage extends StatelessWidget {
  final Chapter chapter;
  final Paper? paper;
  AddPaperPage({super.key, required this.chapter, this.paper});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lessonNumberController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  File? thumbnail;
  RxBool thumbnailIsLoading = false.obs;
  RxBool thumbnailIsCompleted = false.obs;
  RxString thumbnailLink = "".obs;

  File? paperFile;
  RxBool paperIsLoading = false.obs;
  RxBool paperIsCompleted = false.obs;
  RxString paperLink = "".obs;

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? _validateLessonNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final RegExp format = RegExp(r'^\d+(\.\d+)*$');
    if (!format.hasMatch(value)) {
      showSnackBar(message: "Please enter a Valid Number");
      return 'Format should be like 1.2.3';
    }
    return null;
  }

  Future<void> _savePaper() async {
    if (_formKey.currentState!.validate()) {
      if (paper == null && (thumbnail == null || paperFile == null)) {
        showSnackBar(message: "Both Thumbnail and Paper file are required");
        return;
      }

      isLoading.value = true;
      _formKey.currentState!.save();
      try {
        late DocumentReference paperRef;

        // Upload thumbnail if new file selected
        if (thumbnail != null) {
          if (!thumbnail!.existsSync()) {
            showSnackBar(message: "Thumbnail file not found");
            isLoading.value = false;
            return;
          }
          Reference storageRef = _storage.ref().child(
              'paper_thumbnails/${DateTime.now().millisecondsSinceEpoch}${basename(thumbnail!.path)}');
          UploadTask uploadTask = storageRef.putFile(thumbnail!);
          await uploadTask.whenComplete(() async {
            thumbnailLink.value = await storageRef.getDownloadURL();
          });
        }

        // Upload paper if new file selected
        if (paperFile != null) {
          if (!paperFile!.existsSync()) {
            showSnackBar(message: "Paper file not found");
            isLoading.value = false;
            return;
          }
          Reference storageRef = _storage.ref().child(
              'papers/${DateTime.now().millisecondsSinceEpoch}${basename(paperFile!.path)}');
          UploadTask uploadTask = storageRef.putFile(paperFile!);
          await uploadTask.whenComplete(() async {
            paperLink.value = await storageRef.getDownloadURL();
          });
        }

        var data = {
          'thumbnail': thumbnailLink.value,
          'paper': paperLink.value,
          'chapter': chapter.ref,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'paperNumber': _lessonNumberController.text.trim(),
          'createdBy': UserInstance.appUser!.id,
        };

        if (paper != null) {
          paperRef = paper!.ref;
          await paperRef.update(data);
        } else {
          data['createdAt'] = FieldValue.serverTimestamp();
          paperRef = _firestore.collection('papers_v2').doc();
          await paperRef.set(data);
        }

        // Send notification after successful save
        if (paper == null) {
          // Only send notification for new papers
          await NotificationService.sendNotificationToTopic(
            topic: chapter.grade.id,
            title: 'New Paper Available',
            body: '${_titleController.text} has been added to ${chapter.title}',
            imageUrl: thumbnailLink.value,
            data: {
              'type': 'paper',
              'paperId': paperRef.id,
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
            text: paper == null
                ? "Paper added successfully"
                : "Paper updated successfully");
      } catch (e) {
        print(e);
        showSnackBar(message: "Error saving paper");
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _chapterController.text = chapter.title;
    if (paper != null) {
      _titleController.text = paper!.title;
      _descriptionController.text = paper!.description;
      _lessonNumberController.text = (paper!.lessonNumber ?? '').toString();
      thumbnailLink.value = paper!.thumbnail ?? "";
      thumbnailIsCompleted.value =
          !(paper!.thumbnail.isNull || paper!.thumbnail == "");
      paperLink.value = paper!.paperUrl ?? "";
      paperIsCompleted.value =
          !(paper!.paperUrl.isNull || paper!.paperUrl == "");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(paper.isNull ? 'Add New Paper' : 'Update Paper'),
        actions: [
          Visibility(
            visible: paper != null,
            child: IconButton(
                onPressed: () async {
                  bool? confirm =
                      await ConfirmDialog.ask(message: "Confirm Delete");
                  if (confirm != null && confirm) {
                    paper?.ref.delete();
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
                SizedBox(height: 16),
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
                        label: "Paper Title *",
                        controller: _titleController,
                        validator: _validateTitle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ThumbnailSelect(
                        label: "Thumbnail *",
                        onPick: (file) {
                          thumbnail = file;
                        },
                        clear: () {
                          thumbnailLink.value = "";
                          thumbnail = null;
                        },
                        isLoading: thumbnailIsLoading,
                        isSuccess: thumbnailIsCompleted,
                        previewUrl: thumbnailLink.value,
                        // selectedFile: thumbnail,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: FileSelect(
                        label: "Paper *",
                        onPick: (file) {
                          paperFile = file;
                        },
                        clear: () {
                          paperLink.value = "";
                          paperFile = null;
                        },
                        isLoading: paperIsLoading,
                        isSuccess: paperIsCompleted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                HomeInput(
                  label: "Description",
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
                SizedBox(height: 30),
                Obx(
                  () => Button.primary(
                    isLoading: isLoading.value,
                    onPressed: () {
                      _savePaper();
                    },
                    label: paper.isNull ? 'Add Paper' : 'Update Paper',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
