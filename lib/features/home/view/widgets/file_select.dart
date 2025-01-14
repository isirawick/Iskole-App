import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/functions.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:path/path.dart';

class FileSelect extends StatelessWidget {
  final String label;
  final Function(File?) onPick;
  final RxBool isLoading;
  final RxBool isSuccess;
  final VoidCallback clear;
  FileSelect({super.key,required this.label,required this.onPick,required this.isLoading,required this.isSuccess, required  this.clear});

  RxBool fileSelected = false.obs;
  RxString fileName = "".obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Palette.gradient3,
              fontSize: 16),
          label,
        ),
        const SizedBox(height: 5,),
        Stack(
          children: [
            InkWell(
              onTap: ()async{
                File? newFile = await selectDocument();
                if(newFile!=null){
                  onPick(newFile);
                  fileSelected.value = true;
                  fileName.value = basename(newFile.path);
                }
              },
              child: Obx(()=> Container(
                padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Palette.authInputColor.withOpacity(0.1),),
                  height: 120,
                  width: Get.width,
                  child: isSuccess.value?Center(child: Text('Uploaded Attachment')):fileSelected.value?Center(child: Text(fileName.value,textAlign: TextAlign.center,)):Icon(Icons.upload_file,size: 40,color: Palette.welcomeButtonTextColor.withOpacity(0.3),),
                ),
              ),
            ),

            Obx(()=> Visibility(
              visible: fileSelected.value || isSuccess.value,
              child: Positioned(
                    right: -7,
                    top: -3,
                    child: IconButton(onPressed: (){
                      onPick(null);
                      fileSelected.value = false;
                      isSuccess.value = false;
                      clear();
                    }, icon: Icon(Icons.delete,color: Palette.welcomeButtonTextColor.withOpacity(0.5),)
                    )),
            ),
            ),
          ],
        ),
      ],
    );
  }
}
