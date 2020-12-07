import 'package:flutter/material.dart';

//Firebase plugins
import 'package:provider/provider.dart';
import 'package:testing_application_1/services/database.dart';

//Shared preferences

import '../../widgets/appdrawer.dart';

import '../../models/user.dart' as app;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  app.User _userData;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    settingAndFetchingUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> settingAndFetchingUser() async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<Database>(context, listen: false).settingUpAppUser();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    _userData = Provider.of<Database>(context, listen: true).appUser;
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Arrow',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Container()
          : Container(
              child: Text('Hello there ${_userData.nickname}'),
            ),
    );
  }
}
