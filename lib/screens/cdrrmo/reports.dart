import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:try1/utils/color_utils.dart';

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
    // Initialize date range to null (no filter)
    startDate = null;
    endDate = null;

    // Retrieve all reports initially
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
      columns: const [
        DataColumn(label: Text('Date and Time')),
        DataColumn(label: Text('Barangay')),
        DataColumn(label: Text('Street')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Report Description')),
        DataColumn(label: Text('Full Details')),
        DataColumn(label: Text('Report Status')),
        DataColumn(label: Text('Verification Options')),
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
            DataCell(Text(data['Street'])),
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
                  _showDetailsDialog(data);
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

Future<void> _showDetailsDialog(QueryDocumentSnapshot document) async {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder<String>(
        stream: getUsername(data['User_ID']).asStream(),
        builder: (context, snapshot) {
          return AlertDialog(
            title: Text('Report Details - Status: ${data['Hazard_Status']}'),
            content: Container(
              width: 500, // Set your desired width
              height: 500, // Set your desired height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                future: getUsername(data['User_ID']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('User: Error - ${snapshot.error}');
                  } else {
                    return Text('${snapshot.data ?? 'N/A'}');
                  }
                },
              ),
                  Text(formatTimestamp(data['Timestamp']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w100,
                  ),
                  ),
                  Row(
                    children: [
                    const Icon(Icons.location_pin),
                    Text('Location: ${data['Barangay'] + ', ' + data['Street']}'),
                    const Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Hazard Status: ${data['Hazard_Status']}'),
                    ],
                  ),
                  Text('Report Description: ${data['Report_Description']}'),
                  Text('Hazard Status: ${data['Hazard_Status']}'),
                  const Text('Photos: '),
                  const Padding(padding: EdgeInsets.all(10)),
                  const Text('Change Hazard Status:'),
                  DropdownCell(user_ID: data['Report_ID']),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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