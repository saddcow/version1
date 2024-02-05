import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:try1/admin/admin_screens/account_management.dart';
import 'package:try1/admin/admin_screens/barangay_screen.dart';
import 'package:try1/admin/admin_screens/risk_level_screen.dart';
import 'package:try1/auth_service.dart';
import 'package:try1/screens/login_screen.dart';
import 'package:try1/utils/color_utils.dart';

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
      const Scaffold(
        body: AccountScreen()
      ),
      Scaffold(
        body: Container(
          color: Colors.blueGrey,
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
                        child: 
                          ElevatedButton(onPressed: () {
                            AuthService().signout();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                          }, 
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            )
                          ),
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
                  icon: Icons.person, 
                  label: 'User Accounts'
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