import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//google sign in
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:shared_preferences/shared_preferences.dart' as sp;

//firebase
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:cloud_firestore/cloud_firestore.dart' as fbcloud;

//sahred
import '../shared/flutterToast.dart';

class Auth extends ChangeNotifier {
  fbauth.User _fbUser = fbauth.FirebaseAuth.instance.currentUser;

  fbauth.User get firebaseUser {
    return _fbUser;
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      google.GoogleSignInAccount _googleSignInAccount =
          await google.GoogleSignIn.standard().signIn();

      google.GoogleSignInAuthentication _googleAuth =
          await _googleSignInAccount.authentication;

      fbauth.OAuthCredential _authCredentials =
          fbauth.GoogleAuthProvider.credential(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken,
      );

      fbauth.User _userCredentials = (await fbauth.FirebaseAuth.instance
              .signInWithCredential(_authCredentials))
          .user;

      var userData = await fbcloud.FirebaseFirestore.instance
          .collection('users')
          .doc(_userCredentials.uid)
          .get();

      if (userData.exists) {
        //Just saving the user data localy
        await writtingLocalData(
          email: userData['email'],
          nickname: userData['nickname'],
          phoneNumber: userData['phoneNumber'],
          photoUrl: userData['photoUrl'],
          uid: userData['id'],
          userBio: userData['userBio'],
        );
        // _user = fbauth.FirebaseAuth.instance.currentUser;
        // notifyListeners();
      } else {
        //Creating the user first in the firebase
        await fbcloud.FirebaseFirestore.instance
            .collection('users')
            .doc(userData.id)
            .set({
          'contacts': [],
          'email': _userCredentials.email,
          'nickname': _userCredentials.displayName,
          'id': _userCredentials.uid,
          'phoneNumber': _userCredentials.phoneNumber,
          'photoUrl': _userCredentials.photoURL,
          'userBio': 'Hey I am using Arrow',
          'joinedOn': fbcloud.Timestamp.now(),
        });

        await writtingLocalData(
          email: _userCredentials.email,
          nickname: _userCredentials.displayName,
          phoneNumber: _userCredentials.phoneNumber,
          photoUrl: _userCredentials.photoURL,
          uid: _userCredentials.uid,
        );
      }
    } on fbauth.FirebaseAuthException catch (error) {
      String msg = 'Ops something went wrong';

      if (error
          .toString()
          .contains('account-exists-with-different-credential')) {
        msg = 'User allready exists';
      } else if (error.toString().contains('invalid-credential')) {
        msg = 'The credentials have expired, please try again';
      } else if (error.toString().contains('operation-not-allowed')) {
        msg = 'Sorry but this operation is not allowed at the moment';
      } else if (error.toString().contains('user-disabled')) {
        msg = 'The user was disabled.';
      } else if (error.toString().contains('')) {
        msg = 'Sorry but the user was not found. Please try registering.';
      } else if (error.toString().contains('wrong-password:')) {
        msg = 'Wrong password';
      }

      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: msg,
        textColor: Colors.white,
      );
    } catch (error) {
      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: 'Oops something went wrong. Please try again.',
        textColor: Colors.white,
      );
    }
  }

  Future<void> signInEmailAndPassword({
    String email,
    String password,
    BuildContext context,
  }) async {
    try {
      fbauth.UserCredential userCredential =
          await fbauth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      fbcloud.DocumentSnapshot userData = await fbcloud
          .FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user.uid)
          .get();

      await writtingLocalData(
        email: userData['email'],
        nickname: userData['nickname'],
        phoneNumber: userData['phoneNumber'],
        photoUrl: userData['photoUrl'],
        uid: userData['id'],
        userBio: userData['userBio'],
      );

      _fbUser = fbauth.FirebaseAuth.instance.currentUser;
      notifyListeners();
    } on fbauth.FirebaseAuthException catch (error) {
      String msg = 'Oops something went wrong';

      if (error.toString().contains('invalid-email')) {
        msg = 'Invalid email';
      } else if (error.toString().contains('user-disabled')) {
        msg = 'The user is disabled';
      } else if (error.toString().contains('wrong-password')) {
        msg = 'Wrong password';
      }

      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: msg,
        textColor: Colors.white,
      );
    } catch (error) {
      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: 'Oops something went wrong.',
        textColor: Colors.white,
      );
    }
  }

  Future<void> creatingUserEmailAndPassword({
    String email,
    String password,
    String nickname,
    BuildContext context,
  }) async {
    try {
      fbauth.UserCredential userCredentials =
          await fbauth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await fbcloud.FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user.uid)
          .set({
        'contacts': [],
        'id': userCredentials.user.uid,
        'email': userCredentials.user.email,
        'joinedOn': fbcloud.Timestamp.now(),
        'nickname': nickname,
        'phoneNumber': null,
        'photoUrl': userCredentials.user.photoURL ??
            'https://djraphaelschlosser.de/wp-content/uploads/2017/09/profile.jpg',
        'userBio': 'Hey I am using Arrow.',
      });

      fbcloud.DocumentSnapshot userData = await fbcloud
          .FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user.uid)
          .get();

      await writtingLocalData(
        email: userData['email'],
        nickname: userData['nickname'],
        phoneNumber: userData['phoneNumber'],
        photoUrl: userData['photoUrl'],
        uid: userData['id'],
        userBio: userData['userBio'],
      );

      _fbUser = fbauth.FirebaseAuth.instance.currentUser;

      notifyListeners();
    } on fbcloud.FirebaseFirestore catch (e) {
      String msg = 'Oops something went wrong';
      if (e.toString().contains('email-already-in-use')) {
        msg = 'This user allready exists.';
      } else if (e.toString().contains('invalid-email')) {
        msg = 'Invalid email';
      } else if (e.toString().contains('weak-password')) {
        msg = 'Weak passowrd';
      }
      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: msg,
        textColor: Colors.white,
      );
    } catch (error) {
      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: 'Oops something went wrong',
        textColor: Colors.white,
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    fbauth.User oldUser = _fbUser;
    try {
      await fbauth.FirebaseAuth.instance.signOut();

      sp.SharedPreferences preferences =
          await sp.SharedPreferences.getInstance();

      await preferences.clear();

      _fbUser = null;
      flutterToast(
        backgroundColor: Theme.of(context).primaryColor,
        msg: 'Sign out successful',
        textColor: Colors.white,
      );
      notifyListeners();
    } catch (e) {
      flutterToast(
        backgroundColor: Theme.of(context).errorColor,
        msg: 'Sorry something went wrong',
        textColor: Colors.white,
      );

      _fbUser = oldUser;
      notifyListeners();
    }
  }

  Future<void> writtingLocalData({
    String uid,
    String email,
    String photoUrl,
    String nickname,
    String userBio = 'Hey I am using Arrow',
    String phoneNumber,
  }) async {
    sp.SharedPreferences preferences = await sp.SharedPreferences.getInstance();

    await preferences.setString('id', uid);
    await preferences.setString('email', email);
    await preferences.setString('photoUrl', photoUrl);
    await preferences.setString('nickname', nickname);
    await preferences.setString('userBio', userBio);
    await preferences.setString('phoneNumber', phoneNumber);
  }
}
