import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'
    as mt;

import '../../shared/text_field_decoration.dart';
import '../../services/authentication.dart' as auth;

import 'package:provider/provider.dart';
import '../../shared/circular_loading_indicator.dart';

enum Auth { Register, Login }

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String userEmail;
  String userPassword;
  TextEditingController passwordController = TextEditingController();
  String userNickname;

  Auth authMode = Auth.Login;

  AnimationController _animationController;

  Animation<double> opacityAnimation;
  Animation<Offset> offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 350),
      reverseDuration: Duration(milliseconds: 350),
      vsync: this,
    );

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInBack,
        parent: _animationController,
        reverseCurve: Curves.easeIn,
      ),
    );

    offsetAnimation = Tween<Offset>(
      begin: Offset(0, -0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _animationController,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    double sizedBoxHeight = size.height * 0.045;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 350),
                padding: const EdgeInsets.all(25),
                // constraints: BoxConstraints(
                //   maxHeight: size.height * 0.6,
                //   minHeight: size.height * 0.25,
                // ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(3, 3),
                      blurRadius: 6,
                      color: Colors.black38,
                      spreadRadius: 3,
                    )
                  ],
                ),
                height: authMode == Auth.Login ? 320 : 530,
                width: size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //email
                        TextFormField(
                          key: ValueKey('email form field'),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration:
                              textInputDecoration.copyWith(labelText: 'Email'),
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@')) {
                              return 'Please provide a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            userEmail = value;
                          },
                        ),
                        SizedBox(
                          height: sizedBoxHeight,
                        ),
                        //Password
                        TextFormField(
                          key: ValueKey('password form field'),
                          textInputAction: authMode == Auth.Login
                              ? TextInputAction.done
                              : TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          controller: passwordController,
                          autocorrect: false,
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter the password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            userPassword = value;
                          },
                        ),
                        SizedBox(
                          height: sizedBoxHeight,
                        ),
                        //Confirm Password only if the user is registering
                        if (authMode == Auth.Register)
                          FadeTransition(
                            opacity: opacityAnimation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: TextFormField(
                                key: ValueKey('confirm password form field'),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                enabled: authMode == Auth.Login ? false : true,
                                autocorrect: false,
                                obscureText: true,
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Confirm Password',
                                ),
                                validator: (value) {
                                  if (passwordController.text != value) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        if (authMode == Auth.Register)
                          SizedBox(
                            height: sizedBoxHeight,
                          ),

                        //Setting up user nickname
                        if (authMode == Auth.Register)
                          FadeTransition(
                            opacity: opacityAnimation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: TextFormField(
                                key: ValueKey('nickname form field'),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.visiblePassword,
                                enabled: authMode == Auth.Login ? false : true,
                                autocorrect: false,
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Nickname',
                                ),
                                validator: (value) {
                                  if (value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please provide a valid nickname';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  userNickname = value;
                                },
                              ),
                            ),
                          ),
                        if (authMode == Auth.Register)
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                        //LOGIN BUTTON
                        Container(
                          height: 45,
                          width: size.width * 0.35,
                          child: _isLoading
                              ? Center(child: circularProgerssIndicator())
                              : RaisedButton(
                                  onPressed: emailAndPassword,
                                  color: Theme.of(context).primaryColor,
                                  child: Text(
                                    authMode == Auth.Login
                                        ? 'Login'
                                        : 'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  textColor: Colors.white,
                                ),
                        ),

                        //Switch Mode Flat Button
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              if (authMode == Auth.Login) {
                                authMode = Auth.Register;
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                                authMode = Auth.Login;
                              }
                              _formKey.currentState.reset();
                            });
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Text(
                            authMode == Auth.Register
                                ? 'I allready have an account'
                                : 'I want to create an account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.07,
              ),
              FlatButton.icon(
                color: Colors.white,
                textColor: Theme.of(context).primaryColor,
                onPressed: () => googleSignIn(context),
                label: Text('Sign in with Google'),
                icon: Icon(mt.MdiIcons.google),
              ),
              SizedBox(
                height: sizedBoxHeight * 0.5,
              ),
              FlatButton.icon(
                onPressed: () {
                  // Creates account using facebook
                },
                icon: Icon(mt.MdiIcons.facebook),
                label: Text('Sign in using Facebook'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> googleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<auth.Auth>(context, listen: false).googleSignIn(context);

    setState(() {
      _isLoading = true;
    });
  }

  Future<void> emailAndPassword() async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
    }

    setState(() {
      _isLoading = true;
    });

    if (authMode == Auth.Login) {
      //LOGIN THE USER IN

      await Provider.of<auth.Auth>(context, listen: false)
          .signInEmailAndPassword(
        context: context,
        email: userEmail,
        password: userPassword,
      );
    } else {
      //REGISTERING THE USER
      await Provider.of<auth.Auth>(context, listen: false)
          .creatingUserEmailAndPassword(
        context: context,
        email: userEmail,
        nickname: userNickname,
        password: userPassword,
      );
    }

    setState(() {
      //this set state has to be called otherwise the user
      //is not going to be logged in and the home page will
      // not work properly
      _isLoading = false;
    });
  }
}
