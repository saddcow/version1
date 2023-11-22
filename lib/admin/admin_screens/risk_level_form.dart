import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskLevelForm extends StatefulWidget {
  const RiskLevelForm({super.key});

  @override
  State<RiskLevelForm> createState() => _RiskLevelFormState();
}

class _RiskLevelFormState extends State<RiskLevelForm> {
  final TextEditingController _riskLevelController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveRiskLevelToFirestore() async {
    String riskLevelName = _riskLevelController.text.trim();

    if (riskLevelName.isNotEmpty) {
      try {
        await _firestore.collection('Risk_Level').add({
          'risk_level': riskLevelName,
        });

        //clear aft saving
        _riskLevelController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Risk Level saved to Firestore!'),
            duration: Duration(seconds: 3),
          )
        );
      } catch (b) {
        print('Error saving to Firestore: $b');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Risk Level.'),
          duration: Duration(seconds: 3),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Risk Level',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25
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