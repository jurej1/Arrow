import 'package:flutter/cupertino.dart';

class User {
  String uid;
  String email;
  String joinedOn;
  String nickname;
  String phoneNumber;
  String photoUrl;
  String userBio;

  User({
    @required this.email,
    this.joinedOn,
    @required this.nickname,
    @required this.phoneNumber,
    @required this.photoUrl,
    @required this.uid,
    @required this.userBio,
  });
}
