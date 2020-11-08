import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

final Query usersRef = Firebase.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  void initState() {
    print('START Firebase.initializeApp()');
    Firebase.initializeApp();
    print('END Firebase.initializeApp()');
    getUsers();
    super.initState();
  }

  getUsers() async {
    print('getUsers');
    await usersRef.getDocuments().then((QuerySnapshot snapshot) async {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        print(doc.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Text('Timeline'),
    );
  }
}
