import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    reportsStream = FirebaseFirestore.instance.collection('Report').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            child: Column(
              children: [
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
              ]
          ),
          ),
        );
      },
    );
  }

  List applyFilter(List data) {
    // Apply filter based on report hazard type and timestamp
    return data.where((item) {
      bool hazardTypeFilter = item['Report_Hazard_Type'] == filterType || filterType == 'All';

      if (startDate != null && endDate != null) {
        // Apply date range filter
        DateTime timestamp = (item['Timestamp'] as Timestamp).toDate();
        bool dateRangeFilter = timestamp.isAfter(startDate!) && timestamp.isBefore(endDate!);
        return hazardTypeFilter && dateRangeFilter;
      }

      return hazardTypeFilter;
    }).toList();
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
        DataColumn(label: Text('Report Hazard Type')),
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
            DataCell(Text(data['Report_Hazard_Type'])),
            DataCell(Text(data['Hazard_Status'])),
            DataCell(
              DropdownCell(user_ID: data['Report_ID']),
            )
          ],
        );
      }).toList(),
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
  final CollectionReference users = FirebaseFirestore.instance.collection('Report');

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
      FirebaseFirestore.instance.collection('Report').doc(user).update({'Hazard_Status': selectedValue});
      print('Document updated successfully.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }
}
