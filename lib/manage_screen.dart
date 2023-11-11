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

  Future<void> deleteDocument(String documentId) async {
  await FirebaseFirestore.instance
      .collection('markers') // Replace with your collection name
      .doc(documentId)
      .delete();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 30,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.black
              ),
              showBottomBorder: true,
              dividerThickness: 3,
              columns: const[
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Risk Level")),
                DataColumn(label: Text("Address")),
                DataColumn(label: Text("Barangay")),
                DataColumn(label: Text("Street")),
                DataColumn(label: Text("Coordinates")),
                DataColumn(label: Text("Options"),),
                DataColumn(label: Text(''))                    
              ], 
              rows: _dataList
                  .map(
                    (DocumentSnapshot document) => DataRow(
                      cells: [
                        DataCell(Text(uuid = document["uniqueID"]),),
                        DataCell(Text(document["risk_level"], style: const TextStyle(color: Colors.red),)),
                        DataCell(Text(document["address"] ?? 'N/A')),
                        DataCell(Text(document["barangay"])),
                        DataCell(Text(document["street"])),
                        DataCell(Text(formatGeoPoint(document["coordinates"] as GeoPoint))),
                        DataCell(
                            TextButton(onPressed: (){
                                deleteDocument(uuid);
                            }, child: const Text("Delete")),
                          ),
                        DataCell(
                          TextButton(onPressed: (){
                            pass = document["uniqueID"];
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MappUpdate(myString: pass,)));
                          }, child: const Text("Edit"))
                        ),  
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),

          const Padding(padding: EdgeInsets.only(top: 30.0)),

          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Mapp()));
            }, 
            label: const Text('Add Hazard Area'),
            icon: const Icon(Icons.add),
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
    QuerySnapshot querySnapshot =
        await _firestore.collection('markers').get();

    setState(() {
      _dataList = querySnapshot.docs;
    });
  }

  String formatGeoPoint(GeoPoint geoPoint) {
    return 'Lat: ${geoPoint.latitude.toString()}, Lng: ${geoPoint.longitude.toString()}';
  }
}
