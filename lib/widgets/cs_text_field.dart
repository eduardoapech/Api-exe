import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CsTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CsTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters, required Null Function(dynamic value) onChanged,
  }) : super(key: key);

  InputDecoration _inputDecoration() {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
