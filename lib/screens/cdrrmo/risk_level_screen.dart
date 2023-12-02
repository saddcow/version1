import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try1/utils/color_utils.dart';

class RiskLvlCard extends StatefulWidget {
  const RiskLvlCard({super.key});

  @override
  State<RiskLvlCard> createState() => _RiskLvlCardState();
}

class _RiskLvlCardState extends State<RiskLvlCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Flood_Risk_Level').snapshots(), 
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center( child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<DocumentSnapshot>dataList = snapshot.data!.docs;
          List<ListTile> riskTiles = dataList.map((document){
            String riskLevel = document['Hazard_level'].toString().toUpperCase();
            String description = document['Description'].toString();

            return ListTile(
              title: Text(riskLevel),
              subtitle: Text(description),
            );
          }).toList();

          return SingleChildScrollView(
            child: Card(
              color: hexStringToColor("#86BBD8"),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: riskTiles,
              ),
            ),
          );
        }
      ),
    );
  }
}

