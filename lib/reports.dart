// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:try1/database_manager.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List dataList = [];
  String userID = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FireStoreDataBase().getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Something went wrong",
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            dataList = snapshot.data as List;
            return SizedBox(
              width: double.infinity,
              child: buildDataTable(dataList),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
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
        DataColumn(label: Text('Baranggay')),
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
            DataCell(Text(data['Baranggay'])),
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
            DataCell(Text(data['Report_Status'])),
            DataCell(
              DropdownCell(user_ID: data['Document_ID']),
            )
          ],
        );
      }).toList(),
    );
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
      FirebaseFirestore.instance.collection('Report').doc(user).update({'Report_Status': selectedValue});
      print('Document updated successfully.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }
}