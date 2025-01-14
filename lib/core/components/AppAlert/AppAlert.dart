import 'dart:ui';

import 'package:flutter/material.dart';

class AppAlert extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Duration autoCloseDuration;
  final Color iconColor;
  final Color borderColor;

  const AppAlert({super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    this.autoCloseDuration = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      child: _AnimatedAlertDialogContent(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: Colors.white,
        iconColor: iconColor,
        autoCloseDuration: autoCloseDuration,
        borderColor:borderColor
      ),
    );
  }
}

class _AnimatedAlertDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;
  final Duration autoCloseDuration;

  const _AnimatedAlertDialogContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.borderColor,
    required this.autoCloseDuration,
  });

  @override
  _AnimatedAlertDialogContentState createState() =>
      _AnimatedAlertDialogContentState();
}

class _AnimatedAlertDialogContentState extends State<_AnimatedAlertDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                        color: widget.borderColor,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Icon(
                      widget.icon,
                      size: 48,
                      color: widget.iconColor,
                    ),

                    SizedBox(height: 8,),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: widget.iconColor.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 0,),Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: widget.borderColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF949494),
                    fontWeight: FontWeight.w500
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }
}