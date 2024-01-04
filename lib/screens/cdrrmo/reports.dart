import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:try1/utils/color_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late Stream<QuerySnapshot> reportsStream;
  String filterType = 'All';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = null;
    endDate = null;

    reportsStream = FirebaseFirestore.instance
        .collection('Report')
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flood Reports',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Flood reports on the current day
            //Header for current day
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Today',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: hexStringToColor('#F26419')
                  )
                ],
              )
            ),
            StreamBuilder<QuerySnapshot>(
              stream: reportsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List dataList = snapshot.data!.docs;
                List filteredData =
                    applyFilterOnCurrentDayAndType(dataList, 'Flood');

                return SizedBox(
                  width: double.infinity,
                  child: filteredData.isEmpty
                      ? const Center(
                          child: Text('No Flood report today'),
                        )
                      : buildDataTable(filteredData),
                );
              },
            ),
            // Heading for Archive
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Archives',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: hexStringToColor('#F6AE2D'),
                  )
                ],
              )
            ),
            // All reports
            StreamBuilder<QuerySnapshot>(
              stream: reportsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List dataList = snapshot.data!.docs;
                List filteredData = applyFilter(dataList);

                return SizedBox(
                  width: double.infinity,
                  child: buildDataTable(filteredData),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: SizedBox(
            height: 100,
            width: 100,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Date:'),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != startDate) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                    child: Text(startDate != null
                        ? DateFormat('MM-dd-yyyy').format(startDate!)
                        : 'Select'),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('End Date:'),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != endDate) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                    child: Text(endDate != null
                        ? DateFormat('MM-dd-yyyy').format(endDate!)
                        : 'Select'),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  List applyFilter(List data) {
    // Apply filter based on report hazard type and timestamp
    return data.where((item) {
      bool hazardTypeFilter = item['Report_Hazard_Type'] == 'Flood';

      if (startDate != null && endDate != null) {
        // Apply date range filter
        DateTime timestamp = (item['Timestamp'] as Timestamp).toDate();
        bool dateRangeFilter =
            timestamp.isAfter(startDate!) && timestamp.isBefore(endDate!);

        // Check if the report's date is not equal to the current date
        bool notOnCurrentDate = !isSameDay(timestamp, DateTime.now());

        return hazardTypeFilter && dateRangeFilter && notOnCurrentDate;
      }

      return hazardTypeFilter;
    }).toList();
  }

  List applyFilterOnCurrentDayAndType(List data, String hazardType) {
    return data.where((item) {
      bool hazardTypeFilter = item['Report_Hazard_Type'] == hazardType;

      DateTime timestamp = (item['Timestamp'] as Timestamp).toDate();
      bool isOnCurrentDay = isSameDay(timestamp, DateTime.now());

      return hazardTypeFilter && isOnCurrentDay;
    }).toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget buildDataTable(List dataList) {
    return DataTable(
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
      columns: [
        _buildDataColumn('Date and Time', 120),
        _buildDataColumn('Barangay', 100),
        _buildDataColumn('Landmark or Street', 100),
        _buildDataColumn('User', 120),
        _buildDataColumn('Report Description', 150),
        _buildDataColumn('Full Details', 150),
        _buildDataColumn('Report Status', 120),
        _buildDataColumn('Verification Options', 150),
      ],
      rows: dataList.map((data) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                formatTimestamp(data['Timestamp']),
              ),
            ),
            DataCell(Text(data['Barangay'])),
            DataCell(Text(data['street_landmark'])),
            DataCell(
              FutureBuilder<String>(
                future: getUsername(data['User_ID']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(snapshot.data ?? 'N/A');
                  }
                },
              ),
            ),
            DataCell(Text(data['Report_Description'])),
            DataCell( ElevatedButton(
                onPressed: () {
                  _showDetailsDialog(context, data);
                },
                child: const Text('View all details here'),
              ),),
            DataCell(Text(data['Hazard_Status'])),
            DataCell(
              DropdownCell(user_ID: data['Report_ID']),
            )
          ],
        );
      }).toList(),
    );
  }

void _showDetailsDialog(BuildContext context, QueryDocumentSnapshot data){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Report Details - Status: ${data['Hazard_Status']}',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width, 
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                thickness: 3,
                color: Colors.black,
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              FutureBuilder<String>(
                future: getUsername(data['User_ID']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('User: Error - ${snapshot.error}');
                  } else {
                    return Text(
                      snapshot.data ?? 'N/A', 
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w400
                      ),
                    );
                  }
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Text(formatTimestamp(data['Timestamp']),
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 15
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                'Location: ${data['Barangay'] + ', ' + data['street_landmark']}',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 20
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Text(
                'Report Description: ${data['Report_Description']}',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
                  Text(
                    'Hazard Status: ${data['Hazard_Status']}',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 20
                    ),
                  ),
              const Padding(padding: EdgeInsets.all(10)),
              const Text('List of Photos: '),
              FutureBuilder<String>(
                future: getImageUrlFromReportImage(data['Report_ID']),
                builder: (context, imageUrlSnapshot) {
                  if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (imageUrlSnapshot.hasError) {
                    return Text('Error: ${imageUrlSnapshot.error}');
                  } else {
                    return GestureDetector(
                      onTap: () {
                        _launchURL(imageUrlSnapshot.data);
                      },
                      child: Text(
                        'URL from Report_Image: ${imageUrlSnapshot.data ?? 'N/A'} (Click to Open)',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }
                },
              ),
            
              const Text('Change Hazard Status:'),
              const Padding(padding: EdgeInsets.all(5)),
              DropdownCell(user_ID: data['Report_ID']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<String> getImageUrlFromReportImage(String reportId) async {
  try {
    // Query the 'Report_Image' collection to find documents with matching 'Report_ID'
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Report_Image')
        .where('Report_ID', isEqualTo: reportId)
        .get();

    // If there are matching documents, return the 'Url_from_storage' from the first one
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0]['Url_from_storage'];
    } else {
      return 'N/A'; // No matching documents found
    }
  } catch (e) {
    return 'Error: $e';
  }
}

void _launchURL(String? url) async {
  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}



  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MM-dd-yyyy HH:mm').format(dateTime);
  }

  Future<String> getUsername(String userId) async {
    String first = '';
    String last = '';
    try {
      var userSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userSnapshot.exists) {
        first = userSnapshot['First_Name'];
        last = userSnapshot['Last_Name'];
        return "$first " " $last";
      } else {
        return 'User not found';
      }
    } catch (error) {
      print('Error fetching username: $error');
      return 'Error';
    }
  }
}

class DropdownCell extends StatefulWidget {
  const DropdownCell({Key? key, required this.user_ID}) : super(key: key);

  final String user_ID;

  @override
  _DropdownCellState createState() => _DropdownCellState();
}

class _DropdownCellState extends State<DropdownCell> {
  String selectedValue = 'Ongoing';
  final CollectionReference users =
      FirebaseFirestore.instance.collection('Report');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedValue = newValue;
                });

                updateUser(selectedValue);
                
              }
            },
            items: ['Ongoing', 'Resolved', 'Spam']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> updateUser(String selectedValue) async {
    String user = widget.user_ID;

    try {
      FirebaseFirestore.instance
          .collection('Report')
          .doc(user)
          .update({'Hazard_Status': selectedValue});
      print('Document updated successfully.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }
}

DataColumn _buildDataColumn(String label, double width) {
  return DataColumn(
    label: SizedBox(
      width: width,
      child: Text(label),
    ),
  );
}