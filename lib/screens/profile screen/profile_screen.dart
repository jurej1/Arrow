import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:testing_application_1/services/database.dart';
import 'package:testing_application_1/shared/flutterToast.dart';

import '../../models/user.dart';

import '../../shared/text_field_decoration.dart';
import '../../shared/circular_loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> updateImage() async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<Database>(context, listen: false).updatingUserPhoto();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updatingProfile(User user) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print(formUserData['nickname']);
    print(formUserData['userBio']);
    print(formUserData['email']);
    print(formUserData['phoneNumber']);

    bool anyChange = false;

    if (formUserData['nickname'].trim() != user.nickname) {
      anyChange = true;
    } else if (formUserData['userBio'].trim() != user.userBio) {
      anyChange = true;
    } else if (formUserData['email'].trim() != user.email) {
      anyChange = true;
    } else if (formUserData['phoneNumber'].trim() != user.phoneNumber) {
      anyChange = true;
    }

    if (anyChange == true) {
      await Provider.of<Database>(context, listen: false).updatingUserProfile(
        formUserData['nickname'].trim(),
        formUserData['userBio'].trim(),
        formUserData['email'].trim(),
        formUserData['phoneNumber'].trim(),
      );
    } else {
      flutterToast(
        backgroundColor: Theme.of(context).primaryColor,
        msg: 'There is nothing to save',
        textColor: Colors.white,
      );
    }
  }

  Map<String, String> formUserData = {
    'nickname': '',
    'userBio': '',
    'email': '',
    'phoneNumber': '',
  };
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    User userData = Provider.of<Database>(context).appUser;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.save),
            label: Text('Save'),
            onPressed: () => updatingProfile(userData),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textColor: Colors.white,
          )
        ],
      ),
      body: Container(
        height: size.height,
        width: size.height,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          physics: BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'userPhoto',
                  child: GestureDetector(
                    onTap: updateImage,
                    child: Container(
                      height: size.height * 0.23,
                      width: size.height * 0.23,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: _isLoading
                            ? null
                            : DecorationImage(
                                image: NetworkImage(
                                  userData.photoUrl,
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: _isLoading ? circularProgerssIndicator() : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                TextFormField(
                  key: ValueKey('Nickname'),
                  autocorrect: false,
                  keyboardType: TextInputType.name,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Username',
                  ),
                  initialValue: userData.nickname,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value.trim().length < 4 || value.isEmpty) {
                      return 'Username is to short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    formUserData['nickname'] = value;
                  },
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                TextFormField(
                  key: ValueKey('Userbio'),
                  autocorrect: false,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Bio:',
                  ),
                  initialValue: userData.userBio,
                  maxLength: 100,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  onSaved: (value) {
                    formUserData['userBio'] = value;
                  },
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                TextFormField(
                  key: ValueKey('Email'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Email:',
                  ),
                  initialValue: userData.email,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value.trim().isEmpty || !value.contains('@')) {
                      return 'Please provide a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    formUserData['email'] = value;
                  },
                ),
                SizedBox(
                  height: size.height * 0.025,
                ),
                TextFormField(
                  key: ValueKey('Phone number'),
                  keyboardType: TextInputType.phone,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Phone Number:',
                  ),
                  initialValue: userData.phoneNumber,
                  textInputAction: TextInputAction.done,
                  onSaved: (value) {
                    formUserData['phoneNumber'] = value;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
