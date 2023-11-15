import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:try1/admin/admin_screens/risk_level_form.dart';

class RiskLevelScreen extends StatefulWidget {
  const RiskLevelScreen({Key? key});

  @override
  State<RiskLevelScreen> createState() => _RiskLevelScreenState();
}

class _RiskLevelScreenState extends State<RiskLevelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> dataList = [];

  Future<void> deleteDocument(String documentId) async {
    await FirebaseFirestore.instance
        .collection('Risk_Level')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Risk Level'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 30,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => Colors.black,
            ),
            showBottomBorder: true,
            dividerThickness: 3,
            columns: const [
              DataColumn(label: Text('Risk Level')),
              DataColumn(label: Text('Options')),
            ],
            rows: dataList.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(data['risk_level'])),
                  DataCell(
                      TextButton(
                        onPressed: () {
                          deleteDocument(data['risk_level']);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                  )
                ]
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiskLevelForm(),
              ),
            );
          },
          label: const Text('Add Risk Level'),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    dataList = [];
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('Risk_Level').get();

      setState(() {
        dataList = querySnapshot.docs;
      });
    } catch (c) {
      print('Error fetching data: $c');
    }
  }
}
