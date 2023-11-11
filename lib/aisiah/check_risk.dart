import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCheck extends StatelessWidget {
  final String searchString = 'High'; // Set the search string here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('markers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              List<String> matchingDocumentIds = [];

              for (QueryDocumentSnapshot document in querySnapshot.docs) {
                String fieldValue = document['risk_level'];

                if (searchString == 'High' ) {
                  matchingDocumentIds.add(document.id);
                } else if (searchString == 'Medium' && fieldValue == 'Medium') {
                  matchingDocumentIds.add('${document.id}: $fieldValue');
                } else if (searchString == 'Low' && fieldValue == 'High') {
                  matchingDocumentIds.add('${document.id}: $fieldValue');
                }
              }

              if (matchingDocumentIds.isNotEmpty) {
                // Print or display the matching document IDs
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Matching documents for $searchString:'),
                      for (String docInfo in matchingDocumentIds)
                        Text(docInfo),
                    ],
                  ),
                );
              } else {
                // If no matches found
                return Center(
                  child: Text('No matching documents found'),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(FirestoreCheck());
}
