import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hint, help, label;
  final IconData icon;
  final TextEditingController controller;
  final int max;
  final IconButton copy;
  MyTextField(this.controller,
      {Key key,
      this.hint,
      this.help,
      this.label,
      this.icon,
      this.max,
      this.copy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
          controller: controller,
          maxLines: max,
          keyboardType: TextInputType.multiline,
          decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: hint,
            helperText: help,
            labelText: label,
            suffixIcon: copy,
            prefixIcon: Icon(
              icon,
              color: Colors.brown,
            ),
          )),
    );
  }
}
