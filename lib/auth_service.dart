// ignore_for_file: prefer_const_constructors, unused_import, use_build_context_synchronously

import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:try1/admin/admin_home.dart';
import 'package:try1/home_screen.dart';
import 'package:try1/screens/comcen/comcen_home.dart';
import 'package:try1/screens/login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  //Handle Authentication

  Widget handleAuth(){
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.active){
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
    } catch (err){
      print('Error signing out: $err');
    }
  } 

  signIn(email, password) {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((user) {
      print('Signed in');
    }).catchError((e) {
      print(e);
    });
  }
}