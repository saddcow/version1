// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class MyDropDownMenu extends StatefulWidget {
  const MyDropDownMenu({super.key});

  @override
  _MyDropDownMenuState createState() => _MyDropDownMenuState();
}

class _MyDropDownMenuState extends State<MyDropDownMenu> {
  String selectedValue = 'Yellow - Low chance of getting flooded. Greater than 30mm of rain per hour lasting for 3 hours';
  List<String> options = [
    'Green - Low chance of getting flooded. Greater than 30mm of rain per hour lasting for 3 hours', 
    'Yellowange - Medium chance of getting flooded. Around 15-30mm of rain per hour last for 3 hours.', 
    'Red - High chance of getting flooded. Around 6.5-15mm of rain per hour lasting for 3 hours',];

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