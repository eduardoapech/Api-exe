import 'package:flutter/material.dart';

class AgeRangeFields extends StatelessWidget {
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final Function(String) onChanged;

  AgeRangeFields({required this.minAgeController, required this.maxAgeController, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minAgeController,
            decoration: InputDecoration(
              labelText: 'Idade Mínima',
              hintText: 'Ex: 20',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: maxAgeController,
            decoration: InputDecoration(
              labelText: 'Idade Máxima',
              hintText: 'Ex: 30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
