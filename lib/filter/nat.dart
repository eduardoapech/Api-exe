// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NationalityDropdown extends StatelessWidget {
  final String? selectedNationality;
  final Function(String?) onChanged;

  NationalityDropdown({
    super.key,
    this.selectedNationality,
    required this.onChanged,
  });
  
  List<String> nationalities = ['AU', 'BR', 'CA', 'CH', 'DE', 'ES', 'FR', 'GB', 'IE', 'IR', 'NO', 'NL', 'NZ', 'TR', 'US'];


  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedNationality,
      hint: const Text('Select Nationality'),
      onChanged: onChanged,
      items: nationalities.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

