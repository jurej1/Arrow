import 'package:flutter/material.dart';

//Firebase Plugins
import 'package:firebase_core/firebase_core.dart' as fbcore;

import 'package:provider/provider.dart';
import 'package:testing_application_1/screens/about%20page/aboutPageScreen.dart';
import 'package:testing_application_1/services/authentication.dart' as auth;
import 'package:testing_application_1/services/database.dart';

//my plugins
import './widgets/wrapper.dart';

//Screens
import './screens/settings screen/setting_screen.dart';
import 'package:testing_application_1/screens/profile%20screen/profile_screen.dart';
import './screens/search screen/search_screen.dart';

void main() {
  runApp(CoreApp());
}

class CoreApp extends StatefulWidget {
  @override
  _CoreAppState createState() => _CoreAppState();
}

class _CoreAppState extends State<CoreApp> {
  bool _isInit = false;
  bool _isError = false;
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  void initializeApp() async {
    try {
      await fbcore.Firebase.initializeApp();

      setState(() {
        _isInit = true;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isError = true;
      });
    }
  }

  Widget get mainScreen {
    print('Is error: $_isError');
    print('Is init: $_isInit');

    if (_isInit) {
      return MyApp();
    } else if (_isError == true) {
      return SomethingWentWrong();
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return auth.Auth();
        }),
        ChangeNotifierProvider(create: (context) {
          return Database();
        })
      ],
      child: MaterialApp(
        title: 'Testing app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.lightBlueAccent,
          accentColor: Colors.blueAccent,
          errorColor: Colors.deepOrange,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: mainScreen,
        routes: {
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          AboutPage.routeName: (ctx) => AboutPage(),
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrapper();
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).errorColor,
    );
  }
}
