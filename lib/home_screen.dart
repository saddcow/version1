import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/maps.dart';
import 'package:try1/src/features/weather/presentation/current_weather.dart';
import 'package:try1/src/features/weather/presentation/hourly_weather.dart';
import 'package:try1/src/features/weather/presentation/weather_page.dart';
import 'package:try1/utils/color_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final List<Marker> _markers = [];

  bool showmaps = true;

  @override
  void initState(){
    super.initState();
    _markers.add(const Marker(
      markerId: MarkerId("myLocation"),
      position: LatLng(59.948680, 11.010630),
      
      ),
    );
    if (_markers.isNotEmpty){
    setState(() {
      showmaps = true;
    });
  }
  } 

  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
  }

  double custFontSize = 20;

  void changeFontSize() async{
    setState(() {
      custFontSize+=2;
    });
  }


  List<Widget> buildViews(BuildContext context) {
    return  [
      Scaffold(
        appBar: AppBar(
          title: const Text("Monitoring"),
        ),
        body:const  SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: maps(),
                ),  
                Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Card(
                          surfaceTintColor: Colors.black26,
                          child: Text('hello'),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child:SizedBox(
                        width: 300,
                        height: 300,
                        child: Card(
                          color: Colors.lightBlueAccent,
                          child: CurrentWeather(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      Scaffold(
        appBar: AppBar(
          title: const Text('Managing Risk Areas'),
        ),
        body: Container(
          color: Colors.white,
        ),
      ),

      Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black38,
        ),
        body: Container(
          color: Colors.white,
          child: const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 1000,
                    height: 2000,
                  
                  )
                ],
              ),
            ),
          ),
        ),
      ),
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
                        child: 
                          ElevatedButton(onPressed: () {
                            AuthService().signout();
                          }, 
                        child: const Center(child: Text('Sign Out'),),
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
        decoration: BoxDecoration(
          color: hexStringToColor("023047"),
        ),
        child: Row(
          children: [
            /// Pretty similar to the BottomNavigationBar!
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

            /// Make it take the rest of the available width
            Expanded(
              child: buildViews(context).elementAt(selectedIndex),
            )
          ],
        ),
      ),
    );
  }

}


Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You are logged in'),
          const SizedBox(height: 10.0,),
          ElevatedButton(onPressed: () {
            AuthService().signout();
          }, 
          child: const Center(child: Text('Sign Out'),),
          )
        ],
      ),
    );
  }
