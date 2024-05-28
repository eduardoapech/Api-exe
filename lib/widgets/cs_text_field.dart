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
    this.inputFormatters,
    required Null Function(dynamic value) onChanged,
  }) : super(key: key);

  InputDecoration _inputDecoration({
    required String labelText,
    required Object border,
    required EdgeInsets contentPadding,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 16),

      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      // Define o estilo do texto de entrada
      // Aqui, definimos o tamanho da fonte para 16
      // Você pode ajustar o valor conforme necessário
      // para manter o tamanho de todas as fontes iguais.
      // Por exemplo, se você deseja que todas as fontes tenham tamanho 16,
      // você pode definir isso aqui.
      // Você também pode usar um estilo global de tema para definir isso.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(
          labelText: labelText,
          border: OutlineInputBorder( 
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
          contentPadding: EdgeInsets.all(15.0),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
