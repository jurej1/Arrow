import 'package:flutter/material.dart';

//Login screen
import 'package:testing_application_1/screens/login%20screen/login_screen.dart';
//Home Screen
import '../screens/home screen/home_screen.dart';

//provider
import 'package:provider/provider.dart';
import '../services/authentication.dart' as auth;

// ignore: must_be_immutable
class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<auth.Auth>(context, listen: true).firebaseUser;

    // return StreamBuilder<fbauth.User>(
    //   stream: fbauth.FirebaseAuth.instance.authStateChanges(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Scaffold(
    //         backgroundColor: Theme.of(context).primaryColor,
    //       );
    //     } else {
    //       if (snapshot.hasData) {
    //         return HomeScreen();
    //       } else {
    //         return LoginScreen();
    //       }
    //     }
    //   },
    // );

    if (userData != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
