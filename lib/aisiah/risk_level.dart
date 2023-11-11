// ignore_for_file: no_logic_in_create_state, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Risklevel extends StatefulWidget {
  const Risklevel({super.key});
  
  @override
  _RisklevelState createState() => _RisklevelState();
}

class _RisklevelState extends State<Risklevel>{
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: 500,
          height: 350,
          child: Card(
            color: Colors.lightBlueAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Divider(),
                ListTile(
                  title: Text(
                    'Red Marker',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: (Text('If More than 30 mm rain observed in 1 hour and expected to continue in the next 2 hours then serious flooding is expected in these low-lying areas.')),
                ),
                Divider(),
                ListTile(
                  title: Text('Yellow Marker', style: TextStyle(color: Colors.yellow),),
                  subtitle: (Text('15-30 mm rain observed in 1 hour and expected to continue in the next 2hours. Flooding is threatening.')),
                ),
                Divider(),
                ListTile(
                  title: Text('Green Marker', style: TextStyle(color: Colors.green),),
                  subtitle: Text('6.5-15 mm of rain observed in 1 hour and expected to continue in the next 2 hours. Flooding is possible '),
                ),
              ],
            ),
          ),
        ),
        ),
    );
  }

}