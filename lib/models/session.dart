import 'package:class_scheduler/util/converter.dart';
import 'package:flutter/material.dart';

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Session {
  Day day;
  Time startTime;
  int durationMinute;

  Session(this.day, this.startTime, this.durationMinute);

  Session.fromMap(Map<String, dynamic> map)
      : day = Converter.integerToDayEnum(map['day']),
        startTime = Time(
          hour: map['start_hour'],
          minute: map['start_minute'],
        ),
        durationMinute = map['duration_minute'];

  Map<String, dynamic> toMap() {
    return {
      'day': day.index,
      'start_hour': startTime.hour,
      'start_minute': startTime.minute,
      'duration_minute': durationMinute,
    };
  }
}

class Time extends TimeOfDay {
  Time({required int hour, required int minute})
      : super(hour: hour += minute ~/ 60, minute: minute % 60) {
    // hour += minute ~/ 60;
    if (hour > 23) {
      throw Exception("Hour can't be greater than 23");
    }
  }

  static Time now() {
    var now = TimeOfDay.now();
    return Time(hour: now.hour, minute: now.minute);
  }
}
