import 'package:flutter/material.dart';

class AuthFooterWidget extends StatelessWidget {
  final String questionText;
  final String linkText;
  final VoidCallback onTap;

  const AuthFooterWidget({
    super.key,
    required this.questionText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(questionText),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
