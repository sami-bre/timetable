import 'package:class_scheduler/models/student.dart';
import 'package:class_scheduler/ui/register.dart';

import 'session.dart';

class Class {
  String? id;
  String course;
  Department department;
  Year year;
  String section;
  String teacherId;
  String teacherName;
  late List<Session> sessions;

  Class(
    this.course,
    this.department,
    this.section,
    this.year,
    this.teacherId,
    this.teacherName,
    List<Map<String, dynamic>> listOfSessionMaps,
  ) {
    sessions = makeSessionsFromMaps(listOfSessionMaps);
  }

  static List<Session> makeSessionsFromMaps(List<Map> listOfSessionMaps) {
    var sessions = listOfSessionMaps.map((e) => Session.fromMap(e.cast<String, dynamic>())).toList();
    return sessions;
  }

  Class.fromMap(Map<String, dynamic> map)
      : course = map['course'],
        department = Student.getDepartment(map['department']),
        section = map['section'],
        year = Student.getYear(map['year']),
        teacherId = map['teacher_id'],
        teacherName = map['teacher_name'],
        sessions = makeSessionsFromMaps(map['sessions'].cast<Map>());

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course': course,
      'department': department.name,
      'section': section,
      'year': year.name,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'sessions': sessions.map((e) => e.toMap()).toList(),
    };
  }
}
