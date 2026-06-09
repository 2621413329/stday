import 'package:flutter/material.dart';

/// 带可见性切换的密码输入框。
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    this.labelText = '密码',
    this.hintText,
    this.fillColor,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Color? fillColor;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        filled: true,
        fillColor: widget.fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        suffixIcon: IconButton(
          tooltip: _obscured ? '显示密码' : '隐藏密码',
          onPressed: () => setState(() => _obscured = !_obscured),
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}
