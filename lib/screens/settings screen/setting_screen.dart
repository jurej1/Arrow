import 'package:flutter/material.dart';

import '../../shared/circular_loading_indicator.dart';
import './widgets/user_profile_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/app_settings';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: circularProgerssIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : Container(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    UserProfileListTile(),
                    Divider(),
                  ],
                ),
              ),
            ),
    );
  }
}
