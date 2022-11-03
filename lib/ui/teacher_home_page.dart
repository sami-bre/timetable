import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'drawer.dart';

class TeacherHomePage extends StatefulWidget {
  final User user;

  const TeacherHomePage(this.user, {super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  List<Class> classes = [];
  bool onSearch = false;

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
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: onSearch
            ? Form(
                child: TextFormField(
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) {},
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                  cursorColor: Colors.white,
                ),
              )
            : const Text('Class?'),
        actions: [
          if (!onSearch)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                setState(() {
                  onSearch = true;
                });
              },
            ),
          if (onSearch)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                setState(() {
                  onSearch = false;
                });
              },
            )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(classes[index].course),
                subtitle: Text('dep: ${classes[index].department.name}'
                    'sec: ${classes[index].section}'),
              );
            },
          )),
    );
  }
}
