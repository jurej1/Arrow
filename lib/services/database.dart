import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:testing_application_1/shared/flutterToast.dart';
import '../models/user.dart' as app;

import 'package:cloud_firestore/cloud_firestore.dart' as fbcloud;
import './authentication.dart' as auth;

import 'package:firebase_storage/firebase_storage.dart' as fbstorage;
import 'package:image_picker/image_picker.dart' as imgPick;

class Database extends ChangeNotifier {
  app.User _appUser;

  app.User get appUser {
    return _appUser;
  }

  Future<void> settingUpAppUser() async {
    sp.SharedPreferences preferences = await sp.SharedPreferences.getInstance();

    _appUser = app.User(
      email: preferences.getString('email'),
      nickname: preferences.getString('nickname'),
      phoneNumber: preferences.getString('phoneNumber'),
      photoUrl: preferences.getString('photoUrl'),
      uid: preferences.getString('id'),
      userBio: preferences.getString('userBio'),
    );
    notifyListeners();
  }

  Future<void> updatingUserProfile(
    String username,
    String userBio,
    String email,
    String phoneNumber,
  ) async {
    await fbcloud.FirebaseFirestore.instance
        .collection('users')
        .doc(_appUser.uid)
        .update({
      'nickname': username,
      'email': email,
      'userBio': userBio,
      'phoneNumber': phoneNumber,
    });

    await auth.Auth().writtingLocalData(
      email: email,
      nickname: username,
      phoneNumber: phoneNumber,
      uid: _appUser.uid,
      userBio: userBio,
      photoUrl: _appUser.photoUrl,
    );

    sp.SharedPreferences preferences = await sp.SharedPreferences.getInstance();

    await settingUpAppUser();
  }

  Future<void> updatingUserPhoto() async {
    imgPick.PickedFile pickedFile =
        await imgPick.ImagePicker.platform.pickImage(
      source: imgPick.ImageSource.camera,
      maxHeight: 250,
      maxWidth: 250,
    );

    String oldUserUrl = _appUser.photoUrl;
    sp.SharedPreferences preferences = await sp.SharedPreferences.getInstance();

    if (pickedFile == null) {
      flutterToast(
          backgroundColor: Colors.lightBlueAccent,
          msg: 'Action canceled',
          textColor: Colors.white);
      return;
    } else {
      try {
        File file = File(pickedFile.path);

        fbstorage.Reference ref = fbstorage.FirebaseStorage.instance
            .ref()
            .child('user images')
            .child('${_appUser.uid}.jpg');

        await ref.putFile(file);

        String photoUrl = await ref.getDownloadURL();

        await fbcloud.FirebaseFirestore.instance
            .collection('users')
            .doc(_appUser.uid)
            .update({'photoUrl': photoUrl});

        await preferences.setString('photoUrl', photoUrl);

        _appUser = app.User(
          email: _appUser.email,
          nickname: _appUser.nickname,
          phoneNumber: _appUser.phoneNumber,
          photoUrl: photoUrl,
          uid: _appUser.uid,
          userBio: _appUser.userBio,
        );
        notifyListeners();
      } catch (e) {
        flutterToast(
          backgroundColor: Colors.deepOrange,
          msg: 'Sorry but something went wrong',
          textColor: Colors.white,
        );

        _appUser = app.User(
          email: _appUser.email,
          nickname: _appUser.nickname,
          phoneNumber: _appUser.phoneNumber,
          photoUrl: oldUserUrl,
          uid: _appUser.uid,
          userBio: _appUser.userBio,
        );
        await preferences.setString('photoUrl', oldUserUrl);
        notifyListeners();
      }
    }
  }
}
