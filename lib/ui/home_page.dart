import 'package:class_scheduler/ui/drawer.dart';
import 'package:class_scheduler/util/converter.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  User user = FirebaseAuth.instance.currentUser!;

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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var schedule = snapshot.data![index];
                String timeStart =
                    Converter.timeOfDayToString(schedule.startTime);
                String timeEnd = Converter.timeOfDayToString(schedule.endTime);
                return ListTile(
                  title: Text('${schedule.course} - ${schedule.teacher}'),
                  subtitle: Text('${schedule.day.name}: $timeStart - $timeEnd'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
