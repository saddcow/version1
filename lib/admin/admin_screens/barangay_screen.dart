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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Barangay in Naga City'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Barangay').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> dataList = snapshot.data!.docs;

                return SingleChildScrollView(
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
                                  deleteDocument(data.id);
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
                );
              },
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    await _firestore.collection('Barangay').doc(documentId).delete();
  }
}