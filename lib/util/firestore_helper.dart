import 'package:class_scheduler/models/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final FirestoreHelper fsh = FirestoreHelper._internal();

  FirestoreHelper._internal();

  factory FirestoreHelper() {
    return fsh;
  }

  Future<List<Schedule>> getSchedules() async {
    var data = await FirebaseFirestore.instance.collection('schedules').get();
    var raw = data.docs.map((e) => e.data());
    var schedules = raw.map((e) => Schedule.fromMap(e));
    return schedules.toList();
  }

  static Stream<List<Schedule>> listenToSchedules() async* {
    await for (var snapshot
        in FirebaseFirestore.instance.collection('schedules').snapshots()) {
      var raw = snapshot.docs.map((e) => e.data());
      var schedules = raw.map((e) => Schedule.fromMap(e));
      yield schedules.toList();
    }
  }
}
