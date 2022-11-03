import 'dart:math';
import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import '../util/converter.dart';

class StudentHomePage extends StatefulWidget {
  final User user;

  StudentHomePage(this.user, {super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Class> classes = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: const <Class>[],
        stream: FirestoreHelper.listenToClassesForAStudent(widget.user),
        builder: (context, snapshot) {
          classes = snapshot.data!;
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
                  for (dynamic session in clas.sessions) {
                    tasks.add(
                      TimePlannerTask(
                        color: classColor,
                        dateTime: TimePlannerDateTime(
                            day: session['day'],
                            hour: session['start_hour'],
                            minutes: session['start_minute']),
                        minutesDuration: session['duration_minute'],
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
                }
                return tasks;
              }.call());
        });
  }
}
