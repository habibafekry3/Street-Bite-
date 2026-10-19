import 'package:flutter/material.dart';
import 'auth_text_field_widget.dart';

class PasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextFieldWidget(
      controller: widget.controller,
      label: widget.label,
      obscureText: _obscure,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
