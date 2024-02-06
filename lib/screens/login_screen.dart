// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:try1/auth_service.dart';
import 'package:characters/characters.dart';
import 'package:try1/utils/color_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password;

  final formKey =  GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  checkFields() {
    final form = formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  validator (value) {
  if (value != null || value.isNotEmpty) {
  final RegExp regex =
    RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!regex.hasMatch(value!)) {
      return 'Enter a valid email';
    } else {
      return null;
    }
  } else {
    return 'Enter a valid email';
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              hexStringToColor('#86BBD8'),
              hexStringToColor('#2F4858'),
              hexStringToColor('#33658A')
            ]
          )
        ),
        child: Center(
          child: SizedBox(
            height: 500, 
            width: 500,
            
            child: Card(
              color: Colors.white,
              shadowColor: Colors.black,
              elevation: 2,
              child: Column(
                children: <Widget>[
                  const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  SizedBox(
                    width: 300,
                    height: 150,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo.png'), fit: BoxFit.cover
                        )
                      ),
                    ),
                  ),
                  const Text('Login', style: TextStyle(fontSize: 20),),
                  Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(left: 25.0,right: 25.0,top: 20.0,bottom: 5.0),
                              child: SizedBox(
                                height: 50.0,
                                child: TextFormField(
                                  controller: emailController,
                                  decoration:
                                    InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      labelText: 'Email'
                                    ),
                                  validator: (value) => value!.isEmpty
                                    ? 'Email is required'
                                    : validator(value.trim()),
                                  onChanged: (value) {
                                    email = value;
                                  },
                                ),
                              )),
                          Padding(
                              padding: const EdgeInsets.only(left: 25.0,right: 25.0,top: 20.0,bottom: 5.0),
                              child: SizedBox(
                                height: 50.0,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration:  
                                    InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      labelText: 'Password'
                                   ),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Password is required' : null,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                ),
                              )),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 30)),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                if (checkFields()) {
                                  AuthService().signIn(email, password, context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hexStringToColor('#2b6484'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)
                                )
                              ),
                              child: const Center(child: Text('Sign in', style: TextStyle(color: Colors.white),)),
                            ),
                          ),
                        ],
                      )
                    )
                ],
              )
            ),
          )
        ),
      ),
    );
  }
}