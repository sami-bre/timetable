import 'package:class_scheduler/ui/register.dart';

class Student {
  String? id;
  String userName;
  String email;
  Department department;
  Year year;
  int section;

  Student(this.userName, this.email, this.department, this.year, this.section);

  Student.fromMap(Map<String, dynamic> map)
      : userName = map['username'],
        email = map['email'],
        department = getDepartment(map['department']),
        year = getYear(map['year']),
        section = map['section'];

  Map<String, dynamic> tomap() {
    return {
      if (id != null)
       'id': id,
      'username': userName,
      'email': email,
      'department': department.name,
      'year': year.name,
      'section': section,
    };
  }

  static Department getDepartment(String departmentName) {
    switch (departmentName) {
      case "software":
        return Department.software;
      case "electrical":
        return Department.electrical;
      case "mechanical":
        return Department.mechanical;
      case "biomedical":
        return Department.biomedical;
      case "civil":
        return Department.civil;
      default:
        throw Exception('unknown department.');
    }
  }

  static Year getYear(String yearName) {
    switch (yearName) {
      case "one":
        return Year.one;
      case "two":
        return Year.two;
      case "three":
        return Year.three;
      case "four":
        return Year.four;
      case "five":
        return Year.five;
      default:
        throw Exception('unknown year value');
    }
  }
}
