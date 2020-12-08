import 'package:flutter/material.dart';
import 'package:testing_application_1/widgets/appdrawer.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/About_page';

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          splashRadius: kToolbarHeight * 0.4,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      body: Center(
        child: Text('This is the About Page'),
      ),
    );
  }
}
