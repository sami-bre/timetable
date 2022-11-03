import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class TeacherHomePage extends StatefulWidget {
  final User user;

  TeacherHomePage(this.user, {super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  List<Class> classes = [];

  Future<void> loadClasses() async {
    var data = await FirestoreHelper.getClassesForATeacher(widget.user);
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
    FirestoreHelper.getClassesForATeacher(widget.user).then(
        (value) => print('length of the classes list is ${value.length}'));
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
