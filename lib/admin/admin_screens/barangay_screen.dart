import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/admin/admin_screens/barangay_add_form.dart';
import 'package:try1/admin/admin_screens/barangay_update_form.dart';
import 'package:try1/utils/color_utils.dart';

class BarangayScreen extends StatefulWidget {
  const BarangayScreen({Key? key});

  @override
  State<BarangayScreen> createState() => _BarangayScreenState();
}

class _BarangayScreenState extends State<BarangayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String brgyName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'List of Barangay in Naga City',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
            color: Colors.white
          )
        ),
        automaticallyImplyLeading: false,
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
                dataList.sort((a, b) => a['name'].compareTo(b['name']));

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
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  updateBarangayForm(barangay: data['name'],id: data.id)));
                                },
                                child: const Text(
                                  'Update',
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
