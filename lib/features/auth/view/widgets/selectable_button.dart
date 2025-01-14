import 'package:flutter/material.dart';
import 'package:iskole/core/theme/app_palette.dart';

class SelectableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool selected;
  const SelectableButton(
      {super.key, this.onPressed, required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: selected ? Colors.white : Palette.authInputColor,
        backgroundColor: selected ? Palette.authInputColor : Colors.white,
        side: BorderSide(
            width: 1,
            color: selected ? Colors.transparent : Palette.authInputColor),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
