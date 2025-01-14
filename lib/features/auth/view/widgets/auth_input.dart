import 'package:flutter/material.dart';
import 'package:iskole/core/theme/app_palette.dart';

class AuthInput extends StatelessWidget {
  final String label;
  final Widget prefix;
  final String prefixText;
  final bool isObscured;
  final TextEditingController controller;
  final bool isEnabled;
  final bool readOnly;
  final bool isFocus;
  final VoidCallback? onPressed;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffix;
  AuthInput({
    super.key,
    required this.label,
    required this.prefix,
    required this.controller,
    this.suffix,
    this.prefixText = "",
    this.isObscured = false,
    this.isEnabled = true,
    this.readOnly = false,
    this.isFocus = false,
    this.onPressed,
    this.keyboardType,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscured,
      keyboardType: keyboardType,
      style: TextStyle(fontWeight: FontWeight.w400),
      maxLength: maxLength,
      controller: controller,
      validator: validator,
      onTap: onPressed,
      enabled: isEnabled,
      readOnly: readOnly,
      autovalidateMode:autovalidateMode,
      decoration: InputDecoration(
        prefix: Text(prefixText),
        suffixIcon: suffix,
        prefixIcon: prefix,
        prefixIconConstraints: BoxConstraints(maxHeight: 16, minWidth: 40),
        prefixIconColor: Palette.errorColor,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Palette.authInputColor,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Palette.gradient3,
          ),
        ),
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Palette.authInputColor,
        ),
        floatingLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Palette.gradient3,
        ),
      ),
    );
  }
}
