import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String reportId;
  final String timestamp;
  final String barangay;
  final String street;
  final String userId;
  final String reportDescription;
  final String numberOfPersonsInvolved;
  final List<dynamic> typesOfVehicleInvolved;
  final String hazardStatus;

  DetailsPage({
    required this.reportId,
    required this.timestamp,
    required this.barangay,
    required this.street,
    required this.userId,
    required this.reportDescription,
    required this.numberOfPersonsInvolved,
    required this.typesOfVehicleInvolved,
    required this.hazardStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report ID: $reportId'),
            Text('Date and Time: $timestamp'),
            Text('Barangay: $barangay'),
            Text('Street: $street'),
            FutureBuilder<String>(
                future: getUsername(userId),
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
            Text('Report Description: $reportDescription'),
            Text('Number of Persons Involved: $numberOfPersonsInvolved'),
            Text('Type/s of Vehicle Involved: ${typesOfVehicleInvolved.join(', ')}'),
            Text('Report Status: $hazardStatus'),
            DropdownCell(user_ID: reportId),
            SizedBox(height: 16.0),
            Text('Images:'),
          ],
        ),
      ),
    );
  }

  
    Future<String> getUsername(String userId) async {
    String first = '';
    String last = '';
    try {
      var userSnapshot = await FirebaseFirestore.instance.collection('User').doc(userId).get();

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


