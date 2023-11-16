import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/admin/admin_screens/barangay_screen.dart';
import 'package:try1/admin/admin_screens/risk_level_screen.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/screens/login_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  
  List<Widget> buildViews(BuildContext context) {
    return [
      const Scaffold(
        body: BarangayScreen()
      ),
      const Scaffold(
        body: RiskLevelScreen()
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
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const LoginPage()));
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
          color: Colors.black87
        ),
        child: Row(
          children: [
            SideNavigationBar(
              selectedIndex: selectedIndex, 
              items: const [
                SideNavigationBarItem(
                  icon: Icons.place, 
                  label: 'Barangay'
                ),
                SideNavigationBarItem(
                  icon: Icons.warning_amber, 
                  label: 'Risk Level'
                ),
                SideNavigationBarItem(
                  icon: Icons.settings, 
                  label: 'Settings'
                )
              ], 
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              }
            ),
            Expanded(
              child: buildViews(context).elementAt(selectedIndex)
            ),
          ],
        ),
      ),
    );
  }
}