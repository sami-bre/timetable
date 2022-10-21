import 'package:class_scheduler/ui/drawer.dart';
import 'package:class_scheduler/util/converter.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_planner/time_planner.dart';
import 'package:flutter/material.dart';

import '../models/schedule.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Class?'),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/sign-in');
            },
            child: const Text(
              'Sign out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder(
          stream: FirestoreHelper.listenToSchedules(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return TimePlanner(
              startHour: 0,
              endHour: 23,
              style: TimePlannerStyle(
                horizontalTaskPadding: 2,
              ),
              headers: [
                for (int i = 0; i < 7; i++)
                  TimePlannerTitle(
                    title: dayNames[i],
                  )
              ],
              tasks: [
                for (var schedule in snapshot.data!)
                  TimePlannerTask(
                    dateTime: TimePlannerDateTime(
                      day: schedule.day,
                      hour: schedule.startHour,
                      minutes: schedule.startMinute,
                    ),
                    minutesDuration: schedule.durationMinute,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: ListTile(
                        title:
                            Text('${schedule.course} by ${schedule.teacher}'),
                        subtitle: Text('${dayNames[schedule.day]}:'
                            ' ${Converter.formattedTime(schedule.startHour, schedule.startMinute)} - '
                            '${Converter.formattedTime(schedule.startHour, schedule.startMinute + schedule.durationMinute)}'),
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}
