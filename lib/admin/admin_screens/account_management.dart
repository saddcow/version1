// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> selectedUserTypes = ['All']; // Initialize with 'All'
  late List<DocumentSnapshot> dataList; // Added dataList

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
                dataList = snapshot.data!.docs;

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
                      columns: [
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('User Type')),
                        DataColumn(label: Text('Email Address')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Duplicate Account')),
                        DataColumn(label: Text('Full Details')),
                        DataColumn(label: Text('Verification Status')),
                        DataColumn(label: Text('Verification Options')),
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
                            DataCell(ElevatedButton(
                              onPressed: () {
                                _showDetailsDialog(context, data);
                              },
                              child: const Text('View all details here'),
                            )),
                            DataCell(Text(data['Verification_Status'])),
                            DataCell(DropdownCell(user_ID: data.id)),
                            DataCell(TextButton(
                              onPressed: () {
                                deleteDocument(data.id, data['Email']);
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

  Future<void> deleteDocument(String documentId, String userEmail) async {
    await _firestore.collection('User').doc(documentId).delete();
  }

  void _showDetailsDialog(BuildContext context, DocumentSnapshot data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Account Details",
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
                Text(
                  "Verification Status: ${data['Verification_Status']}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  "FullName: ${data['First_Name']} ${data['Last_Name'] ?? 'N/A'}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  "User Type: ${data['User_Type'] ?? 'N/A'}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Email Address: ${data['Email'] ?? 'N/A'}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Phone Number: ${data['Phone_Number'] ?? 'N/A'}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  'ID Photo:',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                FutureBuilder<List<String>>(
                  future: getImageUrlFromIdImage(data['User_ID']),
                  builder: (context, imageUrlSnapshot) {
                    if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (imageUrlSnapshot.hasError) {
                      return Text('Error: ${imageUrlSnapshot.error}');
                    } else {
                      List<String> urls = imageUrlSnapshot.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.all(5)),
                          Text(
                            'URLs of ID Image:',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          for (String url in urls)
                            GestureDetector(
                              onTap: () {
                                _launchURL(url);
                              },
                              child: Text(
                                '- $url (Click to Open)',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
                Text(
                  "Duplicate Account: ${checkForDuplicates(dataList, data) ? 'Yes' : 'No'}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  'Change Account Status:',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                DropdownCell(user_ID: data.id),
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
}

Future<List<String>> getImageUrlFromIdImage(String userId) async {
  print("User ID: $userId");
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('UploadedID')
        .where('User_ID', isEqualTo: userId)
        .get();

    List<String> urls = [];

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        var url = doc['Url_from_storage'];
        urls.add(url);
      }

      return urls;
    } else {
      return ['N/A'];
    }
  } catch (e) {
    return ['Error: $e'];
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class DropdownCell extends StatefulWidget {
  const DropdownCell({Key? key, required this.user_ID}) : super(key: key);

  final String user_ID;

  @override
  _DropdownCellState createState() => _DropdownCellState();
}

class _DropdownCellState extends State<DropdownCell> {
  String selectedValue = 'Pending';
  final CollectionReference users =
      FirebaseFirestore.instance.collection('User');

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
            items: ['Pending', 'Verified', 'Not Verified']
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
          .collection('User')
          .doc(user)
          .update({'Verification_Status': selectedValue});
      print('Document updated successfully.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }
}
