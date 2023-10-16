// ignore_for_file: prefer_const_constructors, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:try1/home_screen.dart';
import 'package:try1/login_screen.dart';

class AuthService {
  
  //Handle Authentication

  handleAuth(){
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (snapshot.hasData){
          return HomePage();
        } else {
          return LoginPage();
        }
      },
      );    
  }

  //signout
  signout(){
    FirebaseAuth.instance.signOut();
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