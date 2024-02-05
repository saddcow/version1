import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:try1/admin/admin_screens/risk_level_form.dart';
import 'package:try1/admin/admin_screens/updateDoc.dart';
import 'package:try1/utils/color_utils.dart';

class RiskLevelScreen extends StatefulWidget {
  const RiskLevelScreen({Key? key});

  @override
  State<RiskLevelScreen> createState() => _RiskLevelScreenState();
}

class _RiskLevelScreenState extends State<RiskLevelScreen> {
  String FloodAreaID = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteDocument(String documentId) async {
    try {
      return await _firestore
          .collection('Flood_Risk_Level')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> deleteFloodHazardAreas(String hazardLevel) async {
    try {
      // Query the 'markers' collection for documents where 'risk_level' field contains hazardLevel
      QuerySnapshot querySnapshot = await _firestore
          .collection('markers')
          .where('risk_level', isEqualTo: hazardLevel)
          .get();

      // Check if there are any documents in the query result
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through the documents and delete them
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          await document.reference.delete();
        }

        // Print a message or perform additional actions if needed
        return print(
            'Documents with risk_level $hazardLevel deleted successfully');
      } else {
        print('No documents found with risk_level $hazardLevel');
      }
    } catch (e) {
      // Handle errors here
      print('Error deleting documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("#3c7f9"),
        title: Text(
          'List of Risk Level',
          style:GoogleFonts.roboto(
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
              stream: _firestore.collection('Flood_Risk_Level').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> dataList = snapshot.data!.docs;
                //sort ascending order of minMm
                dataList.sort((a, b) {
                  double numberA = a['Number'] ?? 0.0;
                  double numberB = b['Number'] ?? 0.0;
                  return numberA.compareTo(numberB);
                });
                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: 10,
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
                        DataColumn(label: Text('Number Rank')),
                        DataColumn(label: Text('Minnimum mm of rain')),
                        DataColumn(label: Text('Maximum mm of rain')),
                        DataColumn(label: Text('Color Level')),
                        DataColumn(label: Text('Risk Level')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Options')),
                        // DataColumn(label: Text(' ')),
                      ],
                      rows: dataList.map((data) {
                        double minMm = data['Min_mm'] ?? 0.0;
                        double maxMm = data['Max_mm'] ?? 0.0;
                        int numRank = data['Number'] ?? 0;
                        return DataRow(
                          cells: [
                            DataCell(Text(numRank.toString())),
                            DataCell(Text(minMm.toString())),
                            DataCell(Text(maxMm.toString())),
                            DataCell(Text(data['Risk_level_color'])),
                            DataCell(Text(data['Hazard_level'])),
                            DataCell(Text(data['Description'])),
                            // DataCell(
                            //   TextButton(
                            //     onPressed: () {
                            //       FloodAreaID = data['Hazard_level'];

                            //       deleteFloodHazardAreas(FloodAreaID);

                            //       deleteDocument(data.id);
                            //     },
                            //     child: const Text(
                            //       'Delete',
                            //       style: TextStyle(color: Colors.red),
                            //     ),
                            //   ),
                            // ),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  updateDoc(risk: data['Hazard_level'],documentID: data.id)));
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
        ],
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
}
