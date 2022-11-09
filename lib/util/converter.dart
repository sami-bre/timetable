import 'package:flutter/material.dart';
import '../models/session.dart';

class Converter {
  // static TimeOfDay stringToTimeOfDay(String time) {
  //   /// input format should be:  hh:mm am
  //   dynamic temp = time.split(':');
  //   int hour = int.parse(temp[0]);
  //   temp = temp[1].split(' ');
  //   int minute = int.parse(temp[0]);
  //   if (temp[1] == 'pm') hour += 12;
  //   return TimeOfDay(hour: hour, minute: minute);
  // }

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

  // static String timeToString(Time tod) {
  //   String amPm = 'am';
  //   int hour = tod.hour;
  //   dynamic minute = tod.minute;
  //   if (hour > 12) {
  //     amPm = 'pm';
  //     hour -= 12;
  //   }
  //   if (minute == 0) minute = "00";
  //   return "$hour:$minute $amPm";
  // }

  static String formattedTime(int hour, int minute) {
    /// hour should be in [0,23]
    /// minute should be in [0, 59]
    // if the minutes are more than 60 ...
    hour += minute ~/ 60;
    minute %= 60;
    // if the newly added hour goes into the next day ...
    if (hour > 23) {
      throw Exception("Time overflowed into the next day.");
    }
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
    if (minute < 10) formattedMinute = "0$minute";
    return '$formattedHour:$formattedMinute $amPm';
  }

  static String integerToDayString(int dayInt) {
    var days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dayInt];
  }

  static Day integerToDayEnum(int dayInt) {
    switch (dayInt) {
      case 0:
        return Day.monday;
      case 1:
        return Day.tuesday;
      case 2:
        return Day.wednesday;
      case 3:
        return Day.thursday;
      case 4:
        return Day.friday;
      case 5:
        return Day.saturday;
      case 6:
        return Day.sunday;
      default:
        throw Exception('invalid integer representing a day (not in [0-6])');
    }
  }
}
