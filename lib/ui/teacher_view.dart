import 'dart:math';

import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/ui/section_view.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import '../util/converter.dart';
import 'drawer.dart';

class TeacherView extends StatefulWidget {
  final User user;

  const TeacherView(this.user, {super.key});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('My sessions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildTeacherTimeTable(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SectionView(widget.user),
          ));
        },
        child: const Icon(Icons.view_carousel_rounded),
      ),
    );
  }

  Widget _buildTeacherTimeTable() {
    return StreamBuilder(
      initialData: const <Class>[],
      stream: FirestoreHelper.listenToClassesForATeacher(widget.user),
      builder: (context, snapshot) {
        var classes = snapshot.data ?? [];
        var sessions = <TimePlannerTask>[];
        for (Class clas in classes) {
          // the currently logged in teacher owns these classes
          Color classColor = Color.fromRGBO(
            Random().nextInt(150) + 55,
            Random().nextInt(150) + 55,
            Random().nextInt(150) + 55,
            1.0,
          );
          for (dynamic session in clas.sessions) {
            sessions.add(
              TimePlannerTask(
                color: classColor,
                dateTime: TimePlannerDateTime(
                  day: session['day'],
                  hour: session['start_hour'],
                  minutes: session['start_minute'],
                ),
                minutesDuration: session['duration_minute'],
                child: _buildOwnSessionWidget(clas, session),
              ),
            );
          }
        }

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
          tasks: sessions,
        );
      },
    );
  }

  _buildOwnSessionWidget(Class clas, session) {
    // one class many sessions
    return GestureDetector(
      // onLongPress: () => _showOptionsDialog(clas),
      child: GestureDetector(
        onTap: () {
          _showTeacherSessionAlertDialog(clas, session);
        },
        child: RotatedBox(
          quarterTurns: 3,
          child: ListTile(
            title: Text(
              clas.course,
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              "${Converter.formattedTime(session['start_hour'], session['start_minute'])} - "
              "${Converter.formattedTime(session['start_hour'], session['start_minute'] + session['duration_minute'])}",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showTeacherSessionAlertDialog(Class clas, dynamic session) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(clas.course),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(clas.department.name),
              Text('Year ${clas.year.name}'),
              Text('Section ${clas.section}'),
              Text(
                "${Converter.formattedTime(session['start_hour'], session['start_minute'])} - "
                "${Converter.formattedTime(session['start_hour'], session['start_minute'] + session['duration_minute'])}",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // we pop the dialog first.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SectionView(
                      widget.user,
                      startDepartment: clas.department,
                      startYear: clas.year,
                      startSection: clas.section,
                    ),
                  ),
                );
              },
              child: const Text('Edit in section view'),
            )
          ],
        );
      },
    );
  }
}
