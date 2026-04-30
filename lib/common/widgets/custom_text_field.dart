import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isError;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool readOnly;


  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isError = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength = 10,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).cardColor;
    Color borderColor = isError ? Colors.red : primaryColor;
    Color focusedBorderColor = isError ? Colors.red : primaryColor;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
    readOnly:readOnly ,
    //  maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: label,
        prefixIcon: prefixIcon, // Add the prefix icon here
        suffixIcon: suffixIcon, // Add the prefix icon here
        labelStyle: TextStyle(
          color: isError ? Colors.red : Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: borderColor, // Default border color
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: focusedBorderColor, // Focused border color
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.red, // Error border color
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.red, // Error border when focused
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
