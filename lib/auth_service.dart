// ignore_for_file: prefer_const_constructors, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:try1/admin/admin_home.dart';
import 'package:try1/home_screen.dart';
import 'package:try1/screens/login_screen.dart';

class AuthService {
  
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
      } else if (userType == 'AUTHORITY') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      } else {
        AuthService().signout();
        return LoginPage();
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
    } catch (err){
      print('Error signing out: $err');
    }
  } 

  signIn(email, password) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
      print('Signed in');
    }).catchError((e) {
      print(e);
    });
  }
}