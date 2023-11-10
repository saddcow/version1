// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class MyDropDownMenu extends StatefulWidget {
  const MyDropDownMenu({super.key});

  @override
  _MyDropDownMenuState createState() => _MyDropDownMenuState();
}

class _MyDropDownMenuState extends State<MyDropDownMenu> {
  String selectedValue = 'Yellow - Low chance of getting flooded. Aroung 30mm of rain per hour for 10 hours';
  List<String> options = [
    'Yellow - Low chance of getting flooded. Aroung 30mm of rain per hour for 10 hours', 
    'Orange - Medium chance of getting flooded. Around 14mm of rain per hour for 10 hours.', 
    'Red - High chance of getting flooded. Around 5mm of rain per hour for 2 hours',];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Menu Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Value: $selectedValue',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}