import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarangayForm extends StatefulWidget{
  const BarangayForm({Key? key}) : super(key: key);
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
          SnackBar(
            content: Text('Barangay saved to Firestore!'),
            duration: Duration(seconds: 2),
          )
        );
      } catch (a) {
        print ('Error saving to Firestore: $a');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        title: const Text('Add Barangay'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _barangayController,
              decoration: InputDecoration(labelText: 'Barangay Name'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveBarangayToFirestore();
                Navigator.pop(context);
                setState(() { });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      )
    );
  }
}