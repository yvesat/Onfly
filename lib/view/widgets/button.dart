import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function()? onTap;
  final String label;
  final Color? buttonColor;
  final Color? textColor;

  const Button({
    required this.label,
    required this.onTap,
    this.buttonColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buttonColor != null ? ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(buttonColor!)) : null,
      onPressed: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
