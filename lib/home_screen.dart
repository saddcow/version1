// ignore_for_file: unused_field, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/aisiah/check_risk.dart';
import 'package:try1/aisiah/precipitation.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/markers/main_map.dart';
import 'package:try1/screens/login_screen.dart';
import 'package:try1/screens/manage_screen.dart';
import 'package:try1/screens/reports.dart';
import 'package:try1/utils/color_utils.dart';
import 'package:try1/weather.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
          title: Text(
            "Monitoring",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25
            )
          ),
        ),
        body: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //google map
                const Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 500,
                        width: 1000,
                        child: MainMap(),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 250,
                              child: Padding(padding: const EdgeInsets.all(16),
                                child: Card(
                                  color: hexStringToColor("#F6AE2D"),
                                  child: const Padding(padding: EdgeInsetsDirectional.only(top: 20),
                                    child: WeatherForecastWidget(),
                                  ),
                                ),
                              ),
                          ),
                          Padding(padding: const EdgeInsets.all(16),
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 500,
                                height: 350,
                                child: Card(
                                  color: hexStringToColor("#86BBD8"),
                                  elevation: 4,
                                  child: Column(
                                    children: <Widget> [
                                      Padding(
                                      padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Risk Level Description',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: Text(
                                          'Red Marker',
                                          style: GoogleFonts.roboto(
                                            color: Colors.red,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400
                                          ),
                                        ),
                                        subtitle: (
                                          Text(
                                            'More than 30 mm rain observed in 1 hour and expected to continue. Serious flooding is expected in these low-lying areas.',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal
                                            ),
                                          )
                                        ),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: Text(
                                          'Orange Marker', 
                                          style: GoogleFonts.roboto(
                                            color: Colors.orange,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400
                                          ),
                                        ),
                                        subtitle: (
                                          Text(
                                            '15-30 mm rain observed in 1 hour and expected to continue. Flooding is threatening.',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal
                                            ),
                                          )
                                        ),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: Text(
                                          'Yellow Marker', 
                                          style:GoogleFonts.roboto(
                                            color: Colors.yellow,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400
                                          ),
                                        ),
                                        subtitle: Text(
                                          '6.5-15 mm of rain observed in 1 hour and expected to continue. Flooding is possible.',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal
                                          ),
                                        ),
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
                                  color: hexStringToColor("#86BBD8"),
                                  child: Column(
                                    children: [
                                      Padding(
                                      padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Rain Volume for 3 hours',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20
                                          ),
                                        ),
                                      ),
                                      const  Divider(),
                                      const SizedBox(
                                        height: 270,
                                        width: 500,
                                        child: Precipitation(),
                                      )
                                    ],
                                  ),
                                )
                              ),
                              SizedBox(
                                width: 500,
                                height: 350,
                                child: Card(
                                  elevation: 4,
                                  color: hexStringToColor("#86BBD8"),
                                  child: Column(
                                    children: <Widget> [
                                      Padding(
                                      padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Possible Flood Places',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 270,
                                        width: 500,
                                        child: Warning(),
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
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
                height: 250,
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(8.0)),
                    Text(
                      'Settings',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 25
                      )
                    ),
                    const Divider(),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
                    SizedBox(
                      width: 200,
                      child: Center(
                       child: ElevatedButton(
                          onPressed: () async {
                            await AuthService().signout(); // Ensure signout is completed before navigating
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()),);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            )
                          ),
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
