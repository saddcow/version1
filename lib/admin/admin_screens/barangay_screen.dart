import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:try1/admin/admin_screens/barangay_add_form.dart';

class BarangayScreen extends StatefulWidget {
  const BarangayScreen({Key? key});

  @override
  State<BarangayScreen> createState() => _BarangayScreenState();
}

class _BarangayScreenState extends State<BarangayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> dataList = [];

  Future<void> deleteDocument(String documentId) async {
    await FirebaseFirestore.instance
        .collection('Barangay')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Barangay in Naga City'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    DataColumn(label: Text('Barangay')),
                    DataColumn(label: Text('Options')),
                  ],
                  rows: dataList.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data['name'])),
                        DataCell(
                          TextButton(
                            onPressed: () {
                              deleteDocument(data['name']);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarangayForm(),
                    ),
                  );
                },
                label: const Text('Add Barangay'),
                icon: const Icon(Icons.add),
              ),
            )
          ),
        ],
      ),
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
          await _firestore.collection('Barangay').get();

      setState(() {
        dataList = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
