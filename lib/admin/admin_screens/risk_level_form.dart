import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/utils/color_utils.dart';

class RiskLevelForm extends StatefulWidget {
  const RiskLevelForm({super.key});

  @override
  State<RiskLevelForm> createState() => _RiskLevelFormState();
}

class _RiskLevelFormState extends State<RiskLevelForm> {
  final TextEditingController _riskLevelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxMMController = TextEditingController();
  final TextEditingController _minMMController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _numberRankController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  void _saveRiskLevelToFirestore() async {
    String hazardLevelName = _riskLevelController.text.trim();
    String description = _descriptionController.text.trim();
    double? max_mm = double.tryParse(_maxMMController.text);
    double? min_mm = double.tryParse(_minMMController.text);
    String riskLevelColor = _colorController.text.trim();
    int? number = int.tryParse(_numberRankController.text);
    String first = "HVL";
    var rng = Random();
    var code = rng.nextInt(90000) + 10000;
    String uniqueID = first + code.toString();

    if (hazardLevelName.isNotEmpty &&
        description.isNotEmpty &&
        min_mm != null &&
        max_mm != null &&
        riskLevelColor.isNotEmpty ) {
      try {
        await _firestore.collection('Flood_Risk_Level').doc(uniqueID).set({
          'Hazard_level': hazardLevelName,
          'Description' : description,
          'Min_mm' : min_mm,
          'Max_mm' : max_mm,
          'Hazard_Level_ID' : uniqueID,
          'Risk_level_color' : riskLevelColor,
          'Number': number
        });

        if (mounted) {
        // Clear fields after saving.
        _riskLevelController.clear();
        _descriptionController.clear();
        _maxMMController.clear();
        _minMMController.clear();
        _colorController.clear();
        _numberRankController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Risk Level saved to Firestore!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (b) {
      // Check if the widget is still mounted before updating the state.
      if (mounted) {
        print('Error saving to Firestore: $b');
      }
    }
  } else {
    // Check if the widget is still mounted before updating the state.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Add Risk Level',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
            color: Colors.white
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _riskLevelController,
              decoration: const InputDecoration(labelText: 'Risk Level Name'),
            ),
            const SizedBox(height: 16.0,),
            TextField(
              controller: _minMMController,
              decoration: const InputDecoration(labelText: 'Minimum mm of Rain'),
            ),
            const SizedBox(height: 16.0,),
            TextField(
              controller: _maxMMController,
              decoration: const InputDecoration(labelText: 'Maximum mm of Rain'),
            ),
            const SizedBox(height: 16.0,),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16.0,),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color Level'),
            ),
            const SizedBox(height: 16.0,),
            TextField(
              controller: _numberRankController,
              decoration: const InputDecoration(labelText: 'Rank Number'),
            ),
            const SizedBox(height: 16.0,),
            ElevatedButton(
              onPressed: () {
                _saveRiskLevelToFirestore();
                Navigator.pop(context);
                setState(() { });
              }, 
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                )
              ),
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}