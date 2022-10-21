import 'package:flutter/material.dart';

import '../util/converter.dart';

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

List<String> dayNames = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

class Schedule {
  String? id;
  String department;
  String teacher;
  String course;
  int day;
  int startHour;
  int startMinute;
  int durationMinute;

  Schedule({
    this.id,
    required this.department,
    required this.teacher,
    required this.course,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.durationMinute,
  });

  Schedule.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        department = map['department'],
        teacher = map['teacher'],
        course = map['course'],
        day = map['day'],
        startHour = map['start_hour'],
        startMinute = map['start_minute'],
        durationMinute = map['duration_minute'];

  toMap() {
    return {
      if (id != null) 'di': id,
      'department': department,
      'teacher': teacher,
      'course': course,
      'day': day,
      'start_hour': startHour,
      'start_minute': startMinute,
      'duration_minute': durationMinute,
    };
  }
}
