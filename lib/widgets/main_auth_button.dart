import 'package:flutter/material.dart';

class MainAuthButton extends StatelessWidget {
  const MainAuthButton({
    super.key,
    required this.lable,
    required this.onPressed,
    required this.fontSize,
  });

  final String lable;
  final Function() onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Colors.blue,
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.infinity,
        child: Text(
          lable,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
