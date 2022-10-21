import 'package:class_scheduler/models/schedule.dart';
import 'package:flutter/material.dart';

class Converter {
  static TimeOfDay stringToTimeOfDay(String time) {
    /// input format should be:  hh:mm am
    dynamic temp = time.split(':');
    int hour = int.parse(temp[0]);
    temp = temp[1].split(' ');
    int minute = int.parse(temp[0]);
    if (temp[1] == 'pm') hour += 12;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static stringToDayEnum(String day) {
    switch (day) {
      case 'monday':
        return Day.monday;
      case 'tuesday':
        return Day.tuesday;
      case 'wednesday':
        return Day.wednesday;
      case 'thursday':
        return Day.thursday;
      case 'friday':
        return Day.friday;
      case 'saturday':
        return Day.saturday;
      case 'sunday':
      default:
        throw Exception('day string couldn\'t be parsed.');
    }
  }

  static String timeOfDayToString(TimeOfDay tod) {
    String amPm = 'am';
    int hour = tod.hour;
    dynamic minute = tod.minute;
    if (hour > 12) {
      amPm = 'pm';
      hour -= 12;
    }
    if (minute == 0) minute = "00";
    return "$hour:$minute $amPm";
  }

  static String formattedTime(int hour, int minute) {
    /// hour should be in [0,23]
    /// minute should be in [0, 59]
    int formattedHour = hour;
    dynamic formattedMinute = minute;
    var amPm = 'am';
    // formatting the hour and amPm thing
    if (hour == 0) {
      formattedHour = 12;
      amPm = 'pm';
    } else if (hour == 12) {
      amPm = 'pm';
    } else if (hour > 12) {
      formattedHour = hour - 12;
      amPm = 'pm';
    }
    // formatting the minute
    if (minute == 0) formattedMinute = "00";
    return '$formattedHour:$formattedMinute $amPm';
  }
}
