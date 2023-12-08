import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/screens/comcen/comcen_add_road_accident_prone_areas.dart';
import 'package:try1/screens/comcen/comcen_map_form_update.dart';

class RoadRiskManage extends StatefulWidget {
  const RoadRiskManage({super.key});

  @override
  State<RoadRiskManage> createState() => _RoadRiskManageState();
}

class _RoadRiskManageState extends State<RoadRiskManage> {
  String uuid = '';
  String pass = '123';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Marker> myMarker = [];
  List<DocumentSnapshot> _dataList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Managing Road Risk Area',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25
          )
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Road_Accident_Areas').orderBy('timestamp', descending: true).snapshots(),
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
                      columnSpacing: 2,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black),
                      showBottomBorder: true,
                      dividerThickness: 3,
                      columns: const [
                        DataColumn(label: Text("Address")),
                        DataColumn(label: Text("Barangay")),
                        DataColumn(label: Text("Street")),
                        DataColumn(label: Text("Landmark")),
                        DataColumn(label: Text("Coordinates")),
                        DataColumn(label: Text("Description")),
                        DataColumn(label: Text("Options")),
                      ],
                      rows: _dataList.map(
                        (DocumentSnapshot document) => DataRow(
                          cells: [
                            DataCell(Text(document["address"] ?? 'N/A')),
                            DataCell(Text(document["barangay"])),
                            DataCell(Text(document["street"])),
                            DataCell(Text(document["landmark"])),
                            DataCell(Text(
                              "${document["coordinates"].latitude}, ${document["coordinates"].longitude}"
                            )
                            ),
                            DataCell(Text(document["description"])),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  pass = document["uniqueID"];
                                  Navigator.push(
                                    context, MaterialPageRoute(
                                      builder: ((context) => 
                                      ComcenMarkerUpdate(myString: pass))
                                    )
                                  );
                                },
                                child: const Text("Edit"),
                              )
                            )
                          ]
                        )
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MappCom()));
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
}