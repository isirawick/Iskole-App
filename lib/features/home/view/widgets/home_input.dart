import 'package:flutter/material.dart';
import 'package:iskole/core/theme/app_palette.dart';

class HomeInput extends StatelessWidget {
  final String label;
  final bool isObscured;
  final TextEditingController controller;
  final bool isEnabled;
  final bool readOnly;
  final bool isFocus;
  final VoidCallback? onPressed;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  HomeInput({
    super.key,
    required this.label,
    required this.controller,
    this.isObscured = false,
    this.isEnabled = true,
    this.readOnly = false,
    this.isFocus = false,
    this.onPressed,
    this.keyboardType,
    this.maxLength,
    this.maxLines,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Palette.gradient3,
              fontSize: 16),
        ),
        SizedBox(height: 4,),
        TextFormField(
          maxLines: maxLines??1,
          obscureText: isObscured,
          keyboardType: keyboardType,
          style: TextStyle(fontWeight: FontWeight.w400),
          maxLength: maxLength,
          controller: controller,
          validator: validator,
          onTap: onPressed,
          enabled: isEnabled,
          readOnly: readOnly,
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            fillColor: Palette.authInputColor.withOpacity(0.1),
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Palette.gradient3,
              ),
            ),

          ),
          textInputAction: TextInputAction.done,
          textAlignVertical: TextAlignVertical.top, // Start from top of the box
          scrollPhysics: BouncingScrollPhysics(),
        ),
      ],
    );
  }
}
