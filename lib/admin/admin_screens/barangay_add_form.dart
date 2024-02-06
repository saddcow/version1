// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/utils/color_utils.dart';

class BarangayForm extends StatefulWidget{
  const BarangayForm({Key? key}) : super(key: key);
  @override
  _BarangayFormState createState() => _BarangayFormState();
}

class _BarangayFormState extends State<BarangayForm> {
  final TextEditingController _barangayController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  void _saveBarangayToFirestore() async {
    String barangayName = _barangayController.text.trim();
    
    if (barangayName.isNotEmpty) {
      try {
        await _firestore.collection('Barangay').add({
          'name': barangayName,
        });

        //clear aft saving
        _barangayController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barangay saved to Firestore!'),
            duration: Duration(seconds: 2),
          )
        );
      } catch (a) {
        print ('Error saving to Firestore: $a');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Barangay name.'),
          duration: Duration(seconds: 3),
        )
      );
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Add Barangay',
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
              controller: _barangayController,
              decoration: const InputDecoration(labelText: 'Barangay Name'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveBarangayToFirestore();
                Navigator.pop(context);
                setState(() { });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                )
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      )
    );
  }
}