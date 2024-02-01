import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/screens/comcen/comcen_mark.dart';
import 'package:try1/screens/comcen/comcen_report.dart';
import 'package:try1/screens/comcen/main_map_comcen.dart';
import 'package:try1/screens/comcen/manage_comcen_screen.dart';
import 'package:try1/screens/login_screen.dart';
import 'package:try1/screens/weather_src/current_weather.dart';
import 'package:try1/utils/color_utils.dart';
import 'package:try1/screens/weather_src/weather.dart';

class ComcenHome extends StatefulWidget {
  const ComcenHome({super.key});

  @override
  State<ComcenHome> createState() => _ComcenHomeState();
}

class _ComcenHomeState extends State<ComcenHome> {
  bool showReports = false;
  bool showFloodReports = false;
  bool showRoadAccidentReports = false;
  bool showHazardAreas = false;

  //format geopoint as string
  String formatGeoPoint(GeoPoint geoPoint) {
    return 'Lat: ${geoPoint.latitude.toString()}, Lng: ${geoPoint.longitude.toString()}';
  }

  //buildViews for different sections
  List<Widget> buildViews(BuildContext context) {
    return [
      //Monitoring view
      Scaffold(
        appBar: AppBar(
          backgroundColor: hexStringToColor("#3c7f9"),
          title: Text(
            "COMCEN Road Risk Monitoring",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25,
              color: Colors.white
            )
          ),
        ),
        body: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //map and sidebar
                const Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 620,
                        width: 1000,
                        child: MainMapComcen(),
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
                                child: Row(
                                  children: [
                                    Card(
                                      color: hexStringToColor('#F26419'),
                                      child: const Padding(padding: EdgeInsets.only(top: 10),
                                        child: CurrentWeatherCard(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: hexStringToColor("#F6AE2D"),
                                        child: const Padding(padding: EdgeInsetsDirectional.only(top: 30),
                                          child: WeatherForecastWidget(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const comcenMark()));
                      },
                      label: const Text('Add Road Accident Area'),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //manage view
      const Scaffold(
        body: RoadRiskManage(),
      ),
      //reports view
      const Scaffold(
        body: ReportsCom(),
      ),
      Scaffold(
        body: Container(
          color: hexStringToColor("#33658A"),
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
                          onPressed: () {
                            AuthService().signout();
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const LoginPage()));
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
      )
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
            //side nav bar
            SideNavigationBar(
              selectedIndex: selectedIndex, 
              items: const [
                SideNavigationBarItem(
                  icon: Icons.legend_toggle, 
                  label: "Monitoring",
                ),
                SideNavigationBarItem(
                  icon: Icons.edit_location_alt, 
                  label: "Manage"
                ),
                SideNavigationBarItem(
                  icon: Icons.report, 
                  label: "Reports"
                ),
                SideNavigationBarItem(
                  icon: Icons.settings, 
                  label: "Settings"
                ),
              ], 
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
            // expanded view for the selected index
            Expanded(
              child: buildViews(context).elementAt(selectedIndex),
            ),
          ],
        ),
      ),
    );
  }
}