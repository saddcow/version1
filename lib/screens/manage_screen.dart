// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/aisiah/marker_update.dart';
import 'package:try1/maps4.dart';

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

  // Future<void> deleteDocument(String documentId) async {
  //   await FirebaseFirestore.instance
  //       .collection('markers')
  //       .doc(documentId)
  //       .delete();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Managing Risk Area'),
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
                        DataColumn(label: Text("Street")),
                        DataColumn(label: Text("Options")),
                      ],
                      rows: _dataList
                          .where((document) =>
                              filterRiskLevel == 'All' ||
                              document['risk_level'] == filterRiskLevel)
                          .map(
                            (DocumentSnapshot document) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    document["risk_level"],
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                DataCell(Text(document["address"] ?? 'N/A')),
                                DataCell(Text(document["barangay"])),
                                DataCell(Text(document["street"])),
                                // DataCell(
                                //   TextButton(
                                //       onPressed: () {
                                //         deleteDocument(document["uniqueID"]);
                                //       },
                                //       child: const Text("Delete")),
                                // ),
                                DataCell(TextButton(
                                    onPressed: () {
                                      pass = document["uniqueID"];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MappUpdate(myString: pass)));
                                    },
                                    child: const Text("Edit"))),
                              ],
                            ),
                          )
                          .toList(),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Mapp()));
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

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  Future<void> _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await _firestore.collection('markers').get();

    setState(() {
      _dataList = querySnapshot.docs;
    });
  }

  String formatGeoPoint(GeoPoint geoPoint) {
    return 'Lat: ${geoPoint.latitude.toString()}, Lng: ${geoPoint.longitude.toString()}';
  }

  // Function to show the filter dialog
  Future<void> _showFilterDialog() async {
    String? newFilter = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Risk Level'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'All');
                },
                child: const Text('All'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'High');
                },
                child: const Text('High'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'Medium');
                },
                child: const Text('Medium'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'Low');
                },
                child: const Text('Low'),
              ),
            ],
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
