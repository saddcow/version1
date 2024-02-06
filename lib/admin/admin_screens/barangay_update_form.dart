// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, camel_case_types

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/utils/color_utils.dart';

class updateBarangayForm extends StatefulWidget{
  final id;
  final barangay;

  const updateBarangayForm({Key? key, required this.id, required this.barangay}) : super(key: key);
  @override
  _updateBarangayFormState createState() => _updateBarangayFormState();
}

class _updateBarangayFormState extends State<updateBarangayForm> {
  String docID = '';
  String barangayName = '';

  final TextEditingController _barangayController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    docID = widget.id;
    barangayName = widget.barangay;
  }
  
  void _saveBarangayToFirestore() async {
    String barangayName = _barangayController.text.trim();
    
    if (barangayName.isNotEmpty) {
      try {
        await _firestore.collection('Barangay').doc(docID).update({
          'name': barangayName,
        });

        await updateBarangay(barangayName);

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

  Future<void> updateBarangay(String updateBarangayName) async {
    try {
      // Query the 'markers' collection for documents where 'risk_level' field is equal to updatedRiskLevel
      QuerySnapshot querySnapshot = await _firestore
          .collection('markers')
          .where('barangay', isEqualTo: barangayName)
          .get();

      // Check if there are any documents in the query result
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through the documents and update the 'risk_level' field
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          await document.reference.update({'barangay': updateBarangayName});
        }

        // Print a message or perform additional actions if needed
        print('Documents with risk_level $barangayName updated successfully in markers collection');
      } else {
        print('No documents found with risk_level $barangayName in markers collection');
      }
    } catch (e) {
      // Handle errors here
      print('Error updating documents in markers collection: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Update Barangay $barangayName',
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