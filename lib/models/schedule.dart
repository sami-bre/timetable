import 'package:flutter/material.dart';

import '../util/converter.dart';

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Schedule {
  String? id;
  String department;
  String teacher;
  String course;
  Day day;
  TimeOfDay startTime;
  TimeOfDay endTime;

  Schedule({
    this.id,
    required this.department,
    required this.teacher,
    required this.course,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Schedule.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        department = map['department'],
        teacher = map['teacher'],
        course = map['course'],
        day = Converter.stringToDayEnum(map['day']),
        startTime = Converter.stringToTimeOfDay(map['start_time']),
        endTime = Converter.stringToTimeOfDay(map['end_time']);

  toMap() {
    return {
      if (id != null) 'di': id,
      'department': department,
      'teacher': teacher,
      'course': course,
      'day': day.name,
      'start_time': Converter.timeOfDayToString(startTime),
      'end_time': Converter.timeOfDayToString(endTime),
    };
  }
}
