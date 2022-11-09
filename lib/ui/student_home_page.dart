import 'dart:math';
import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/models/session.dart';
import 'package:class_scheduler/ui/class_catalog.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import 'drawer.dart';

class StudentHomePage extends StatefulWidget {
  final User user;

  const StudentHomePage(this.user, {super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Class> classes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Class?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ClassCatalog(widget.user)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildTimeTable(),
      ),
    );
  }

  Widget _buildTimeTable() {
    return StreamBuilder(
      initialData: const <Class>[],
      stream: FirestoreHelper.listenToClassesForAStudent(widget.user),
      builder: (context, snapshot) {
        classes = snapshot.data ?? [];
        return TimePlanner(
            startHour: 0,
            endHour: 23,
            style: TimePlannerStyle(
              cellWidth: 76,
              horizontalTaskPadding: 2.0,
            ),
            headers: const [
              TimePlannerTitle(title: "Monday"),
              TimePlannerTitle(title: "Tuesday"),
              TimePlannerTitle(title: "Wednesday"),
              TimePlannerTitle(title: "Thursday"),
              TimePlannerTitle(title: "Friday"),
              TimePlannerTitle(title: "Saturday"),
              TimePlannerTitle(title: "Sunday"),
            ],
            tasks: () {
              List<TimePlannerTask> tasks = [];
              for (Class clas in classes) {
                Color classColor = Color.fromRGBO(
                  Random().nextInt(150) + 55,
                  Random().nextInt(150) + 55,
                  Random().nextInt(150) + 55,
                  1.0,
                );
                for (Session session in clas.sessions) {
                  tasks.add(
                    TimePlannerTask(
                      color: classColor,
                      dateTime: TimePlannerDateTime(
                          day: session.day.index,
                          hour: session.startTime.hour,
                          minutes: session.startTime.minute),
                      minutesDuration: session.durationMinute,
                      child: _buildSessionDisplay(clas, session),
                    ),
                  );
                }
              }
              return tasks;
            }.call());
      },
    );
  }

  Widget _buildSessionDisplay(Class clas, Session session) {
    // one class many sessions
    return GestureDetector(
      onLongPress: () => _showOptionsDialog(clas),
      child: RotatedBox(
        quarterTurns: 3,
        child: ListTile(
          title: Text(
            clas.course,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "${session.startTime.format(context)} - "
            "${Time(hour: session.startTime.hour, minute: session.startTime.minute + session.durationMinute).format(context)}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(Class clas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clas.course),
        content: TextButton(
          onPressed: () {
            FirestoreHelper.unregisterAClassForAStudent(clas, widget.user);
            Navigator.of(context).pop();
          },
          child: const Text('Untrack this class'),
        ),
      ),
    );
  }
}
