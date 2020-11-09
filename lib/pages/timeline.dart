import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final Query usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  void initState() {
    deleteUser();
    super.initState();
  }

  createUser() async {
    await usersRef.firestore.collection("users").add({
      "username": "Diana",
      "postCount": 0,
      "isAdmin": false,
    });
  }

  updateUser() async {
    final doc = await usersRef.firestore.collection("users")
        .doc("x4UokBVeRrSXZvQoN85x")
        .get();
    if(doc.exists) {
      doc.reference..update({
        "username": "Diane",
        "postCount": 0,
        "isAdmin": false,
      });
    }
  }

  deleteUser() async {
    final doc = await usersRef.firestore.collection("users")
        .doc("x4UokBVeRrSXZvQoN85x").get();
    if(doc.exists) {
      doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot> (
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return circularProgress();
          }

          final List<Text> children = snapshot.data.docs.map((doc) => Text(doc['username'])).toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        }
      ),
    );
  }
}
