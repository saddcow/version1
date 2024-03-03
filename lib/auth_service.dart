import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:try1/admin/admin_home.dart';
import 'package:try1/screens/cdrrmo/home_screen.dart';
import 'package:try1/screens/comcen/comcen_home.dart';
import 'package:try1/screens/login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Handle Authentication

  Widget handleAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return checkUserType(context, user);
          } else {
            return LoginPage();
          }
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget checkUserType(BuildContext context, User user) {
    FirebaseFirestore.instance.collection('User').doc(user.uid).get().then((doc) {
      String userType = doc['User_Type'];
      if (userType == 'ADMIN') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminHome()));
      } else if (userType == 'CDRRMO') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      } else if (userType == 'COMCEN') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ComcenHome()));
      } else if (userType == 'PUBLIC') {
        // Show an error message instead of signing out
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('You are not authorized to access this app.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await AuthService().signout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  //signout
  Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('Signed out');
    } catch (err) {
      print('Error signing out: $err');
    }
  }

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print('Signed in');
    } on FirebaseAuthException catch (e) {
      // specific FirebaseAuthException instances
      String errorMessage = 'Error signing in';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      }
      // Displays error in the SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // other errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
