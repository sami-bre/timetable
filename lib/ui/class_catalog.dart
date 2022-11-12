import 'package:class_scheduler/ui/register.dart';
import 'package:class_scheduler/util/converter.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/class.dart';

class ClassCatalog extends StatefulWidget {
  final User user;
  const ClassCatalog(this.user, {super.key});

  @override
  State<ClassCatalog> createState() => _ClassCatalogState();
}

class _ClassCatalogState extends State<ClassCatalog> {
  Department? department;
  Year? year;
  List<Class>? classes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class catalog')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDepartmentDropDownButton(),
                _buildYearDropDownButton(),
              ],
            ),
            Builder(
              builder: (context) {
                if (classes == null) {
                  return const Center(
                    child: Text('Enter department and year.'),
                  );
                } else if (classes!.isEmpty) {
                  return const Center(
                    child: Text('No classes for that department and year.'),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: classes!.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          title: Text(classes![index].course),
                          subtitle: Text("by ${classes![index].teacherName}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_rounded),
                            onPressed: () {
                              FirestoreHelper.registerAStudentForAClass(
                                  classes![index], widget.user);
                            },
                          ),
                          onTap: () => _showClassDetails(classes![index]),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropDownButton() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DropdownButton(
        value: department,
        hint: const Text('Department'),
        onChanged: _handleDepartmentDropDownChange,
        items: const [
          DropdownMenuItem(
            value: Department.software,
            child: Text('Software'),
          ),
          DropdownMenuItem(
            value: Department.electrical,
            child: Text('Electrical'),
          ),
          DropdownMenuItem(
            value: Department.mechanical,
            child: Text('Mechanical'),
          ),
          DropdownMenuItem(
            value: Department.biomedical,
            child: Text('Biomedical'),
          ),
          DropdownMenuItem(
            value: Department.civil,
            child: Text('Civil'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropDownButton() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DropdownButton(
        value: year,
        hint: const Text('Year'),
        onChanged: _handleYearDropDownChange,
        items: const [
          DropdownMenuItem(
            value: Year.one,
            child: Text('One'),
          ),
          DropdownMenuItem(
            value: Year.two,
            child: Text('Two'),
          ),
          DropdownMenuItem(
            value: Year.three,
            child: Text('Three'),
          ),
          DropdownMenuItem(
            value: Year.four,
            child: Text('Four'),
          ),
          DropdownMenuItem(
            value: Year.five,
            child: Text('Five'),
          ),
        ],
      ),
    );
  }

  void _handleDepartmentDropDownChange(Department? value) async {
    var temp = classes;
    if (year != null && value != null) {
      temp = await FirestoreHelper.getClasses(value, year!);
    }
    setState(() {
      department = value;
      classes = temp;
    });
  }

  void _handleYearDropDownChange(Year? value) async {
    var temp = classes;
    if (department != null && value != null) {
      temp = await FirestoreHelper.getClasses(department!, value);
    }
    setState(() {
      year = value;
      classes = temp;
    });
  }

  _showClassDetails(Class clas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          "${clas.course} "
          "\nby ${clas.teacherName}",
        ),
        content: Column(
          children: [
            for (dynamic session in clas.sessions) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("${Converter.integerToDayString(session['day'])}"
                    "\nStarts at ${Converter.formattedTime(session['start_hour'], session['start_minute'])}"
                    "\nEnds at ${Converter.formattedTime(session['start_hour'], session['start_minute'] + session['duration_minute'])}"),
              ),
              const Divider(
                endIndent: 5,
              )
            ]
          ],
        ),
      ),
    );
  }
}
