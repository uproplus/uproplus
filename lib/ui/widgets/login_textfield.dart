import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  LoginTextField(this.controller, this.hint, this.obscure);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      height: 50.0,
      width: 300.0,
      alignment: Alignment.centerLeft,
//      decoration: BoxDecoration(
//          color: Colors.white
//      ),
      child: TextField(
          decoration: InputDecoration(
              hintText: hint
          ),
          controller: controller,
        obscureText: obscure,
      ),
    );
  }
}
