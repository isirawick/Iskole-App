import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/components/AppAlert/AppAlert.dart';

enum AppAlertType{
  success,
  error,
  warning,
  loading,
  info
}

class Alert {
  static void _show({required String title, required String text, required AppAlertType type}) {
    bool closed = false;
    Future.delayed(const Duration(seconds: 5),(){
      if(!closed){
        Get.back();
      }
    });
    Get.dialog(
      WillPopScope(
        onWillPop: ()async{
          closed = true;
          return true;
        },
        child: AppAlert(
          title: title,
          message: text,
          icon: type == AppAlertType.success?Icons.check_circle_outline:Icons.error_outline,
          iconColor: type == AppAlertType.success?Color(0xFF00B7FF):Color(0xFFFF004D),
          borderColor: type == AppAlertType.success?Color(0xFFDAF4FF):Color(0xFFFFD9D9),
        ),
      ),
      barrierDismissible: true,
    );
    // CoolAlert(
    //   context: context,
    //   type: type,
    //   text: text,
    //   title: title,
    //   barrierDismissible: true,
    //   onConfirmBtnTap: (){
    //     closed = true;
    //   }
    // );
  }

  static void error({required String title, required String text}) {
    _show(title: title, text: text, type: AppAlertType.error);
  }

  static void success({required String title, required String text}) {
    _show(title: title, text: text, type: AppAlertType.success);
  }
}
