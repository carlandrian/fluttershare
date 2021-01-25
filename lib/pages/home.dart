import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
// import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Query usersRef = FirebaseFirestore.instance.collection('users');
final Query postsRef = FirebaseFirestore.instance.collection('posts');
final Query commentsRef = FirebaseFirestore.instance.collection('comments');
final Query activityFeedRef = FirebaseFirestore.instance.collection('feed');
final Query followersRef = FirebaseFirestore.instance.collection('followers');
final Query followingRef = FirebaseFirestore.instance.collection('following');
final Query timelineRef = FirebaseFirestore.instance.collection('timeline');
final Reference storageRef  = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when a user signed-in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignin(account);
    }, onError: (err){
      print('Error signing in: $err');
    });
    // Re-authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false)
      .then((account) {
        handleSignin(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  createUserInFirestore() async {
    // 1) Check if user exists in users collection in database according to their id.
    final GoogleSignInAccount user = googleSignIn.currentUser;
    print('user.id = ${user.id}');
    DocumentSnapshot doc = await usersRef.firestore
        .collection('users')
        .doc(user.id).get();

    if(!doc.exists) {
      // 2) if the user doesn't exist, then we want them to take to the create account page.
      final username = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccount()
          )
      );

      // 3) get username from create account, use it to make new user document in users collection.
      usersRef.firestore.collection('users').doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });

      // make new user their own follower to include their post in their timeline
      await followersRef.firestore
        .collection('followers')
        .doc(user.id)
        .collection('userFollowers')
        .doc(user.id)
        .set({});

      doc = await usersRef.firestore
          .collection('users').doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    // print(currentUser);
    // print(currentUser.username);
  }

  handleSignin(GoogleSignInAccount account) {
    if(account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(
        milliseconds: 200
      ),
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnauthScreen();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),    // '?' is a null aware operator, which will assign to profileId only when currentUser.id is not null
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),  // This will not scroll the PageView as we only want the views inside of it to scroll.
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnauthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('FlutterShare',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
