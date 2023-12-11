// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> selectedUserTypes = ['All']; // Initialize with 'All'

  @override
  void initState() {
    super.initState();
    // Fetch any additional data or perform initializations here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List of User Accounts',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _showFilterModal(context);
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('User').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> dataList = snapshot.data!.docs;

                // Apply user type filter
                if (!selectedUserTypes.contains('All')) {
                  dataList = dataList
                      .where((data) => selectedUserTypes.contains(data['User_Type']))
                      .toList();
                }

                dataList.sort((a, b) => a['Email'].compareTo(b['Email']));

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
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('User Type')),
                        DataColumn(label: Text('Email Address')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Duplicate Account')),
                        DataColumn(label: Text('Options')),
                      ],
                      rows: dataList.map((data) {
                        bool isDuplicate = checkForDuplicates(dataList, data);
                        return DataRow(
                          cells: [
                            DataCell(Text(data['First_Name'] + ' ' + data['Last_Name'] ?? 'N/A')),
                            DataCell(Text(data['User_Type'] ?? 'N/A')),
                            DataCell(Text(data['Email'] ?? 'N/A')),
                            DataCell(Text(data['Phone_Number'] ?? 'N/A')),
                            DataCell(Text(isDuplicate ? 'Duplicate' : 'Unique')),
                            DataCell(TextButton(
                              onPressed: () {
                                deleteDocument(data.id);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            )),
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
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              CheckboxListTile(
                title: const Text('All'),
                value: selectedUserTypes.contains('All'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUserTypes = ['All'];
                    } else {
                      selectedUserTypes = [];
                    }
                  });
                  Navigator.pop(context); // Close the modal
                },
              ),
              CheckboxListTile(
                title: const Text('PUBLIC'),
                value: selectedUserTypes.contains('PUBLIC'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUserTypes.add('PUBLIC');
                    } else {
                      selectedUserTypes.remove('PUBLIC');
                    }
                  });
                  Navigator.pop(context); // Close the modal
                },
              ),
              CheckboxListTile(
                title: const Text('ADMIN'),
                value: selectedUserTypes.contains('ADMIN'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUserTypes.add('ADMIN');
                    } else {
                      selectedUserTypes.remove('ADMIN');
                    }
                  });
                  Navigator.pop(context); // Close the modal
                },
              ),
              CheckboxListTile(
                title: const Text('COMCEN'),
                value: selectedUserTypes.contains('COMCEN'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUserTypes.add('COMCEN');
                    } else {
                      selectedUserTypes.remove('COMCEN');
                    }
                  });
                  Navigator.pop(context); // Close the modal
                },
              ),
              CheckboxListTile(
                title: const Text('DRR'),
                value: selectedUserTypes.contains('DRR'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedUserTypes.add('DRR');
                    } else {
                      selectedUserTypes.remove('DRR');
                    }
                  });
                  Navigator.pop(context); // Close the modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool checkForDuplicates(List<DocumentSnapshot> dataList, DocumentSnapshot data) {
    return dataList.any((item) =>
        item.id != data.id &&
        (item['Email'] == data['Email'] ||
            item['Phone_Number'] == data['Phone_Number'] ||
            ((item['First_Name'] + item['Last_Name']) == (data['First_Name'] + data['Last_Name']))));
  }

  Future<void> deleteDocument(String documentId) async {
    await _firestore.collection('User').doc(documentId).delete();
  }
}
