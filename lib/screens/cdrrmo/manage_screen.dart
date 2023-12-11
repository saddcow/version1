import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/aisiah/marker_update.dart';
import 'package:try1/screens/cdrrmo/maps4.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  String uuid = '';
  String pass = '123';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Marker> myMarker = [];
  List<DocumentSnapshot> _dataList = [];
  String filterRiskLevel = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Managing Flood Risk Area',
            style:
                GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 25)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('markers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                _dataList = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: 10,
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.black),
                      showBottomBorder: true,
                      dividerThickness: 3,
                      columns: const [
                        DataColumn(label: Text("Risk Level")),
                        DataColumn(label: Text("Address")),
                        DataColumn(label: Text("Barangay")),
                        DataColumn(label: Text("Landmark/Street")),
                        DataColumn(label: Text("Options")),
                        // DataColumn(label: Text('')),
                      ],
                      rows: _dataList.where((document) => filterRiskLevel == 'All' || document['risk_level'] == filterRiskLevel).map(
                            (DocumentSnapshot document) => DataRow(
                              cells: [
                                DataCell(Text(document["risk_level"])),
                                DataCell(Text(document["address"] ?? 'N/A')),
                                DataCell(Text(document["barangay"])),
                                DataCell(Text(document["street_landmark"])),
                                //DataCell(
                                //  TextButton(
                                //       onPressed: () {
                                //         deleteDocument(document["uniqueID"]);
                                //       },
                                //       child: const Text("Delete")),
                               // ),
                                DataCell(TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MappUpdate(myString: document['uniqueID'])));
                                    },
                                    child: const Text("Edit"))),
                              ],
                            ),
                          ).toList(),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Mapp()));
                },
                label: const Text('Add Hazard Area'),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to delete a document from the Firestore collection
  Future<void> deleteDocument(String documentID) async {
    try {
      await _firestore.collection('markers').doc(documentID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete document'),
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await _firestore.collection('markers').orderBy('timestamp', descending: true).get();

    setState(() {
      _dataList = querySnapshot.docs;
    });
  }

  String formatGeoPoint(GeoPoint geoPoint) {
    return 'Lat: ${geoPoint.latitude.toString()}, Lng: ${geoPoint.longitude.toString()}';
  }

  // Function to show the filter 
  Future<void> _showFilterDialog() async {
    QuerySnapshot riskLevelSnapshot = await _firestore.collection('Flood_Risk_Level').get();

    List riskLevels = riskLevelSnapshot.docs.map((doc) => doc['Hazard_level']).toList();

    // ignore: use_build_context_synchronously
    String? newFilter = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Risk Level'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'All');
                      },
                      child: const Text('All'),
                    ),
                    const Divider(),
                    // Dynamically generate buttons based on risk levels
                    for (String riskLevel in riskLevels)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, riskLevel);
                          },
                          child: Text(riskLevel),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (newFilter != null) {
      setState(() {
        filterRiskLevel = newFilter;
      });
    }
  }
}
