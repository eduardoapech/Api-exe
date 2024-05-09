import 'package:flutter/material.dart';

class NationalityDropdown extends StatelessWidget {
  final String? selectedNationality;
  final Function(String?) onChanged;

  NationalityDropdown({this.selectedNationality, required this.onChanged});
  
  List<String> nationalities = ['AU', 'BR', 'CA', 'CH', 'DE', 'ES', 'FR', 'GB', 'IE', 'IR', 'NO', 'NL', 'NZ', 'TR', 'US'];


  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedNationality,
      hint: Text('Select Nationality'),
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

