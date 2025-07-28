import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsets? contentPadding;
  final Color? cursorColor;
  const TextFormFieldWidget({
    super.key,
    required this.cursorColor,
    required this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    required this.labelText,
    this.controller,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      //controller: _useremailController,
      cursorColor: cursorColor,
      decoration: InputDecoration(
          //iconColor: Colors.blue,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            prefixIconColor: Theme.of(context).colorScheme.onPrimary,
            fillColor: Theme.of(context).colorScheme.onPrimary,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary
                )
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),

          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          labelText: labelText,
          hintText: hintText,
          contentPadding: contentPadding,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your email';
        }
        //return null;
      },
    );
  }
}
