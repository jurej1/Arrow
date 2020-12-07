import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:testing_application_1/shared/circular_loading_indicator.dart';
import '../../../services/database.dart';

import '../../profile screen/profile_screen.dart';

class UserProfileListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<Database>(context, listen: true).appUser;
    final size = MediaQuery.of(context).size;

    print(userData);

    return FlatButton(
      onPressed: () {
        //Takes us to the profile screen
        Navigator.of(context).pushNamed(
          ProfileScreen.routeName,
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        height: size.width * 0.25,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // color: Colors.red,
        child: Row(
          children: [
            Hero(
              tag: 'userPhoto',
              child: Container(
                width: size.width * 0.25,
                // height: size.width * 0.25,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: userData != null
                      ? DecorationImage(
                          image: NetworkImage(userData.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),

                child: userData == null ? circularProgerssIndicator() : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userData.nickname,
                    style: TextStyle(fontSize: size.height * 0.036),
                  ),
                  Text(
                    userData.userBio,
                    style: TextStyle(fontSize: (size.height * 0.036) * 0.6),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            Icon(Icons.qr_code),
          ],
        ),
      ),
    );
  }
}
