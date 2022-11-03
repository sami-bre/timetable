import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StudentHomePage extends StatefulWidget {
  final User user;

  StudentHomePage(this.user, {super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Class> classes = [];

  Future<void> loadClasses() async {
    var data = await FirestoreHelper.getClassesForAStudent(widget.user);
    setState(() {
      classes = data;
    });
  }

  @override
  void initState() {
    loadClasses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(classes[index].course),
          subtitle: Text('dep: ${classes[index].department.name}'
              'sec: ${classes[index].section}'),
        );
      },
    );
  }
}
