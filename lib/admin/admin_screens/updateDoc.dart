// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables, file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class updateDoc extends StatefulWidget {
  final documentID;
  final risk;

  const updateDoc({Key? key, required this.documentID, required this.risk}) : super(key: key);

  @override
  State<updateDoc> createState() => _updateDocState();
}

class _updateDocState extends State<updateDoc> {
  String risk_name = '';
  String docID = '';

  @override
  void initState() {
    super.initState();
    docID = widget.documentID;
    risk_name = widget.risk;
  }

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

    if (hazardLevelName.isNotEmpty &&
        description.isNotEmpty &&
        min_mm != null &&
        max_mm != null &&
        riskLevelColor.isNotEmpty ) {
      try {
        await _firestore.collection('Flood_Risk_Level').doc(docID).update({
          'Hazard_level': hazardLevelName,
          'Description' : description,
          'Min_mm' : min_mm,
          'Max_mm' : max_mm,
          'Risk_level_color' : riskLevelColor,
          'Number': number
        });

        print('Update Success');

        await updateMarkersCollection(risk_name);

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

  Future<void> updateMarkersCollection(String updatedRiskLevel) async {
    String riskUpdate = _riskLevelController.text.trim();
    try {
      // Query the 'markers' collection for documents where 'risk_level' field is equal to updatedRiskLevel
      QuerySnapshot querySnapshot = await _firestore
          .collection('markers')
          .where('risk_level', isEqualTo: updatedRiskLevel)
          .get();

      // Check if there are any documents in the query result
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through the documents and update the 'risk_level' field
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          await document.reference.update({'risk_level': riskUpdate});
        }

        // Print a message or perform additional actions if needed
        print('Documents with risk_level $updatedRiskLevel updated successfully in markers collection');
      } else {
        print('No documents found with risk_level $updatedRiskLevel in markers collection');
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
        backgroundColor: Colors.black,
        title: Text(
          'Update Risk Level: $risk_name',
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
            ),
          ],
        ),
      ),
    );
  }
}