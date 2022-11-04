import 'package:class_scheduler/models/student.dart';
import 'package:class_scheduler/ui/register.dart';

class Class {
  String? id;
  String course;
  Department department;
  Year year;
  String section;
  String teacherId;
  String teacherName;
  List sessions;

  Class(
    this.course,
    this.department,
    this.section,
    this.year,
    this.teacherId,
    this.teacherName,
    this.sessions,
  );

  Class.fromMap(Map<String, dynamic> map)
      : course = map['course'],
        department = Student.getDepartment(map['department']),
        section = map['section'],
        year = Student.getYear(map['year']),
        teacherId = map['teacher_id'],
        teacherName = map['teacher_name'],
        sessions = map['sessions'];

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course': course,
      'department': department.name,
      'section': section,
      'year': year.name,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'sessions': sessions,
    };
  }
}
