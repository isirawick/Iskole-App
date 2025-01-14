import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/Button.dart';
import 'package:iskole/core/theme/app_palette.dart';

class ConfirmDialog {
  const ConfirmDialog();

  static Future<bool?> ask({required message})async{
    return await Get.dialog(
      AlertDialog(
        title: Text(message,style: TextStyle(fontSize: 20),),
        content: Text('Are you sure you want to proceed?',style: TextStyle(fontSize: 16),),
        backgroundColor: Colors.white,
        shape:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        actions: <Widget>[
          Button.secondary(
              onPressed: () {
                Get.back(result: false);
              },
              label: "Cancel",
              width: 80,
              height: 36,
              fontSize: 14,
              background: Colors.white,
              color:Palette.authInputColor,

              padding: EdgeInsets.symmetric(horizontal: 10)
          ),
          Button.secondary(
              onPressed: () {
                Get.back(result: true);
              },
              label: "Yes",
              width: 80,
              height: 36,
              fontSize: 14,
              background: Palette.gradient3.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 10)
          ),
        ],
      ),
    );
  }
}
