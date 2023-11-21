import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/admin/admin_screens/risk_level_form.dart';

class RiskLevelScreen extends StatefulWidget {
  const RiskLevelScreen({Key? key});

  @override
  State<RiskLevelScreen> createState() => _RiskLevelScreenState();
}

class _RiskLevelScreenState extends State<RiskLevelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List of Risk Level',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25
          )
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Risk_Level').snapshots(),
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
                            deleteDocument(data.id); // Use 'id' instead of 'risk_level'
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

  Future<void> deleteDocument(String documentId) async {
    await _firestore.collection('Risk_Level').doc(documentId).delete();
  }
}
