import 'package:flutter/material.dart';
import 'package:api_dados/models/filter_model.dart';

class FilterPage extends StatefulWidget {
  final FilterModel filter;

  const FilterPage({super.key, required this.filter});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _gender;
  int? _minAge;
  int? _maxAge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Gender'),
                onSaved: (value) {
                  _gender = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Min Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _minAge = int.tryParse(value ?? '');
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Max Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _maxAge = int.tryParse(value ?? '');
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  widget.filter.name = _name;
                  widget.filter.gender = _gender;
                  widget.filter.minAge = _minAge;
                  widget.filter.maxAge = _maxAge;
                  Navigator.pop(context, widget.filter);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
