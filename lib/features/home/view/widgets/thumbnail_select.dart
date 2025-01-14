import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iskole/core/theme/app_palette.dart';

class ThumbnailSelect extends StatelessWidget {
  final String label;
  final Function(File) onPick;
  final Function() clear;
  final RxBool isLoading;
  final RxBool isSuccess;
  final Rx<File?> selectedFile = Rx<File?>(null); // Use Rx for reactivity
  final String? previewUrl;

  ThumbnailSelect({
    Key? key,
    required this.label,
    required this.onPick,
    required this.clear,
    required this.isLoading,
    required this.isSuccess,
    this.previewUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Palette.authInputColor.withOpacity(0.1),
          ),
          child: Obx(
            () => isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _buildThumbnailContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailContent() {
    if (selectedFile.value != null ||
        (previewUrl != null && previewUrl!.isNotEmpty)) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: selectedFile.value != null
                ? Image.file(
                    selectedFile.value!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.network(
                    previewUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                      );
                    },
                  ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickImage,
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _pickImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click to select thumbnail',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final File imageFile = File(file.path);
      selectedFile.value = imageFile; // Update selected file
      onPick(imageFile);
      isSuccess.value = true;
    }
  }
}
