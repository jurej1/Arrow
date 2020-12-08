import 'package:flutter/material.dart';
import 'package:testing_application_1/screens/about%20page/aboutPageScreen.dart';

import 'package:testing_application_1/screens/settings%20screen/setting_screen.dart';
import '../screens/search screen/search_screen.dart';

import '../services/authentication.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          ListTile(
            onTap: () {
              // Goes to the search Page
              Navigator.of(context)
                  .pushReplacementNamed(SearchScreen.routeName);
            },
            leading: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            title: Text('Search'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Settings'),
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AboutPage.routeName,
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Log out'),
            onTap: () async {
              await Provider.of<Auth>(context, listen: false).signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
