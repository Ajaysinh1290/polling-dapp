import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  TextEditingController? controller;
  String? hintText;
  String? labelText;
  String? Function(String?)? validator;
  AppTextField({Key? key,this.controller,this.hintText,this.labelText,this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
