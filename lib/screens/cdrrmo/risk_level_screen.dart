import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskLvlCard extends StatefulWidget {
  const RiskLvlCard({Key? key});

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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<DocumentSnapshot> dataList = snapshot.data!.docs;
          List<ListTile> riskTiles = dataList.map((document) {
            String riskLevel = document['Hazard_level'].toString().toUpperCase();
            String description = document['Description'].toString();
            String riskColorName = document['Risk_level_color'].toString();

            // Set the text color directly from the color name
            Color riskColor = getColorFromName(riskColorName);

            return ListTile(
              title: Text(
                riskLevel,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: riskColor,
                ),
              ),
              subtitle: Text(description),
            );
          }).toList();

          return SingleChildScrollView(
            child: Card(
              color: Colors.blue, // Set the card color
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: riskTiles,
              ),
            ),
          );
        },
      ),
    );
  }

  Color getColorFromName(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'pink':
      return Colors.pink;
    case 'brown':
      return Colors.brown;
    case 'grey':
      return Colors.grey;
    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    case 'amber':
      return Colors.amber;
    case 'lime':
      return Colors.lime;
    default:
      return Colors.black;
  }
}
}