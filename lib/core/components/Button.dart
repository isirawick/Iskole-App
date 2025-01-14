import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/theme/app_palette.dart';

class Button {
  static Widget primary(
      {required VoidCallback onPressed,
      required String label,
      double? width,
      double? height,
      bool isLoading = false}) {
    return Material(
      color: Colors.transparent, // Make sure material color is transparent
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.gradient1, Palette.gradient3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: InkWell(
          onTap: isLoading?(){}:onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: height ?? 48,
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Center(
                child: isLoading
                    ? SizedBox(
                  height: height??24,
                        width: height??24,
                        child: CircularProgressIndicator(color: Colors.white.withOpacity(0.8),strokeWidth: 3,),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
            width: width ?? Get.width - 80,
          ),
        ),
      ),
    );
  }
  static Widget secondary(
      {required VoidCallback onPressed,
      required String label,
      double? width,
      double? height,
        EdgeInsetsGeometry? padding,
        double? fontSize,
      bool isLoading = false,
        Color? color,
        Color? background,
      }) {
    return Material(
      color: Colors.transparent, // Make sure material color is transparent
      child: Ink(
        decoration: BoxDecoration(
          color: background??Palette.authInputColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: InkWell(
          onTap: isLoading?(){}:onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: height ?? 48,
            padding: padding?? EdgeInsets.symmetric(horizontal: 32),
            child: Center(
                child: isLoading
                    ? SizedBox(
                  height: height??24,
                        width: height??24,
                        child: CircularProgressIndicator(color: Colors.white.withOpacity(0.8),strokeWidth: 3,),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                            fontSize: fontSize??18,
                            fontWeight: FontWeight.bold,
                            color: color??Colors.white),
                      )),
            width: width==null?Get.width - 80:width ==0 ?null:width ,
          ),
        ),
      ),
    );
  }

  static Widget text(
      {required onPressed,
      required label,
      bool underline = true,
      double fontSize = 18,
  EdgeInsetsGeometry padding = const EdgeInsets.all(10.0),
      }) {
    return InkWell(
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: TextStyle(
                fontSize: fontSize,
                color: Palette.gradient3,
                decoration: underline ? TextDecoration.underline : null,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}
