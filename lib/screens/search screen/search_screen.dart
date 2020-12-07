import 'package:flutter/material.dart';

import '../../shared/text_field_decoration.dart';
import '../../widgets/appdrawer.dart';
import '../../shared/circular_loading_indicator.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as fbcloud;

class SearchScreen extends StatefulWidget {
  static const routeName = '/search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  AnimationController _textFieldController;
  Animation<Offset> slideTextFieldAnimation;
  Animation<double> fadeTextFieldAnimation;

  AnimationController _titleController;

  FocusNode _searchFieldFocusNode;
  Animation<double> titleFadeAnimation;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String searchKey;

  @override
  void initState() {
    _textFieldController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 800,
      ),
    );

    _titleController = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );

    slideTextFieldAnimation = Tween<Offset>(
      begin: Offset(0, -3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _textFieldController,
      ),
    );

    fadeTextFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _textFieldController,
      ),
    );

    titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _titleController,
      ),
    );

    _textFieldController.addListener(startTitleAnimation);

    _textFieldController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.removeListener(startTitleAnimation);
    _textFieldController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void startTitleAnimation() {
    if (_textFieldController.isCompleted) {
      // starts second animation
      _titleController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Theme.of(context).primaryColor,
          splashRadius: kToolbarHeight * 0.4,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.08,
              ),
              Container(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: titleFadeAnimation,
                      child: Text(
                        'Arrow',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontSize: size.height * 0.09,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FadeTransition(
                      opacity: fadeTextFieldAnimation,
                      child: SlideTransition(
                        position: slideTextFieldAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            decoration: textInputDecoration.copyWith(
                              labelText: 'Search user',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {},
                              ),
                            ),
                            focusNode: _searchFieldFocusNode,
                            onChanged: (value) {
                              setState(() {
                                searchKey = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 350,
                      child: StreamBuilder<fbcloud.QuerySnapshot>(
                        stream: fbcloud.FirebaseFirestore.instance
                            .collection('users')
                            .where('nickname',
                                isGreaterThanOrEqualTo: searchKey)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final user = snapshot.data.docs;

                            return ListView.builder(
                              itemCount: user.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    user[index]['nickname'],
                                  ),
                                );
                              },
                            );
                          } else {
                            return circularProgerssIndicator();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
