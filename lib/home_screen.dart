// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/aisiah/check_risk.dart';
import 'package:try1/aisiah/precipitation.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/markers/main_map.dart';
import 'package:try1/screens/login_screen.dart';
import 'package:try1/screens/manage_screen.dart';
import 'package:try1/screens/reports.dart';
import 'package:try1/weather.dart';
import 'package:try1/screens/login_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _dataList = [];
  bool showReports = false;
  bool showFloodReports = false;
  bool showRoadAccidentReports = false;
  bool showHazardAreas = false;


  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  // Fetch data from Firestore
  Future<void> _fetchDataFromFirestore() async {
    QuerySnapshot querySnapshot = await _firestore.collection('markers').get();

    setState(() {
      _dataList = querySnapshot.docs;
    });
  }

  // Format GeoPoint as a string
  String formatGeoPoint(GeoPoint geoPoint) {
    return 'Lat: ${geoPoint.latitude.toString()}, Lng: ${geoPoint.longitude.toString()}';
  }

  // Build views for different sections
  List<Widget> buildViews(BuildContext context) {
    return [
      // Monitoring View
      Scaffold(
        appBar: AppBar(
          title: const Text("Monitoring"),
        ),
        body: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Map and Sidebar
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 500,
                      child: Card(
                        child: Column(
                          children: [
                            const Text(
                              'Map Filters',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(
                              thickness: 2.0, 
                            ), 
                            CheckboxListTile(
                              title: const Text('Show Reports Marker'),
                              value: showReports,
                              onChanged: (value) {
                                setState(() {
                                  showReports = value!;
                                });
                              },
                            ),
                            if (showReports)
                              Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Show Flood Reports Marker'),
                                    value: showFloodReports,
                                    onChanged: (value) {
                                      setState(() {
                                        showFloodReports = value!;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Show Road Accident Reports Marker'),
                                    value: showRoadAccidentReports,
                                    onChanged: (value) {
                                      setState(() {
                                        showRoadAccidentReports = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            CheckboxListTile(
                              title: const Text('Show Hazard Areas'),
                              value: showHazardAreas,
                              onChanged: (value) {
                                setState(() {
                                  showHazardAreas = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(
                        height: 500,
                        width: 1000,
                        child: MainMap(),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200,
                              child: Padding(padding: EdgeInsets.all(16),
                                child: Card(
                                  color: Colors.lightBlueAccent,
                                  child: Padding(padding: EdgeInsetsDirectional.only(top: 30),
                                    child: WeatherForecastWidget(),
                                  ),
                                ),
                              ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 500,
                                height: 350,
                                child: Card(
                                  color: Colors.lightBlueAccent,
                                  elevation: 4,
                                  child: Column(
                                    children: <Widget> [
                                      Padding(
                                      padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Risk Level Description',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
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
                                        title: Text('Orange Marker', style: TextStyle(color: Colors.orange),),
                                        subtitle: (Text('15-30 mm rain observed in 1 hour and expected to continue in the next 2hours. Flooding is threatening.')),
                                      ),
                                      Divider(),
                                      ListTile(
                                        title: Text('Yellow Marker', style: TextStyle(color: Colors.yellow),),
                                        subtitle: Text('6.5-15 mm of rain observed in 1 hour and expected to continue in the next 2 hours. Flooding is possible '),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 500,
                                height: 350,
                                child: Card(
                                  elevation: 4,
                                  color: Colors.lightBlueAccent,
                                  child: Column(
                                    children: [
                                      Padding(
                                      padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Rain Volume for 3 hours',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 270,
                                        width: 500,
                                        child: Precipitation(),
                                      )
                                    ],
                                ),
                              )),
                              SizedBox(
                                width: 500,
                                height: 350,
                                child: Card(
                                  elevation: 4,
                                  color: Colors.lightBlueAccent,
                                  child: Column(
                                    children: <Widget> [
                                      Padding(
                                      padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Possible Flood Places',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 270,
                                        width: 500,
                                        child: Warning(),
                                      )
                                    ],
                                ),
                              )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.only(bottom: 50))
              ],
            ),
          ),
        ),
      ),
              
      // Manage View
      const Scaffold(
        body: Manage(),
      ),
      // Reports View
      const Scaffold(
        body: Reports(),
      ),
      // Settings View
      Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Card(
              elevation: 50,
              shadowColor: Colors.black26,
              color: Colors.white,
              child: SizedBox(
                width: 500,
                height: 300,
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(8.0)),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 50,
                      ),
                    ),
                    const Divider(),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
                    SizedBox(
                      width: 200,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            AuthService().signout();
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                          },
                          child: const Center(child: Text('Sign Out')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Row(
          children: [
            // Side Navigation Bar
            SideNavigationBar(
              selectedIndex: selectedIndex,
              items: const [
                SideNavigationBarItem(
                  icon: Icons.legend_toggle,
                  label: 'Monitoring',
                ),
                SideNavigationBarItem(
                  icon: Icons.edit_location_alt,
                  label: 'Manage',
                ),
                SideNavigationBarItem(
                  icon: Icons.report,
                  label: 'Reports',
                ),
                SideNavigationBarItem(
                  icon: Icons.settings,
                  label: 'Settings',
                ),
              ],
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
            // Expanded View for the Selected Index
            Expanded(
              child: buildViews(context).elementAt(selectedIndex),
            ),
          ],
        ),
      ),
    );
  }
}
