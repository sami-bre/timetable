import 'dart:math';

import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/ui/register.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import '../util/converter.dart';
import 'drawer.dart';

class SectionView extends StatefulWidget {
  final User user;
  Department? startDepartment;
  Year? startYear;
  String startSection = "";

  SectionView(this.user,
      {this.startDepartment,
      this.startYear,
      this.startSection = "",
      super.key});

  @override
  State<SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<SectionView> {
  Department? displayedDepartment;
  Year? displayedYear;
  String displayedSection = "";
  Stream<List<Class>>? classesStream;
  TextEditingController txtSection = TextEditingController();

  @override
  void initState() {
    if (widget.startDepartment != null &&
        widget.startYear != null &&
        widget.startSection != "") {
      displayedDepartment = widget.startDepartment;
      displayedYear = widget.startYear;
      displayedSection = widget.startSection;
      txtSection.text = widget.startSection;
      classesStream = FirestoreHelper.listenForClasses(
        department: displayedDepartment,
        year: displayedYear,
        section: displayedSection,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    txtSection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        toolbarHeight: 130,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDepartmentDropDownButton(),
                _buildYearDropDownButton()
              ],
            ),
            TextField(
              controller: txtSection,
              cursorColor: Theme.of(context).secondaryHeaderColor,
              decoration: InputDecoration(
                label: Text(
                  'Section',
                  style:
                      TextStyle(color: Theme.of(context).secondaryHeaderColor),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: _handleSectionChange,
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildSectionTimeTable(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Text('...'),
      ),
    );
  }

  Widget _buildDepartmentDropDownButton() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DropdownButton(
        itemHeight: 60,
        value: displayedDepartment,
        hint: const Text('Department'),
        onChanged: _handleDisplayedDepartmentChange,
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
        itemHeight: 60,
        value: displayedYear,
        hint: const Text('Year'),
        onChanged: _handleDisplayedYearChange,
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

  Widget _buildSectionTimeTable() {
    return StreamBuilder(
      initialData: const <Class>[],
      stream: classesStream,
      builder: (context, snapshot) {
        var classes = snapshot.data ?? [];
        var sessions = <TimePlannerTask>[];
        for (Class clas in classes) {
          Color classColor;
          if (clas.teacherId == widget.user.uid) {
            // the currently logged in teacher owns this class
            classColor = Color.fromRGBO(
              Random().nextInt(150) + 55,
              Random().nextInt(150) + 55,
              Random().nextInt(150) + 55,
              1.0,
            );
            for (dynamic session in clas.sessions) {
              sessions.add(
                TimePlannerTask(
                  color: classColor,
                  dateTime: TimePlannerDateTime(
                    day: session['day'],
                    hour: session['start_hour'],
                    minutes: session['start_minute'],
                  ),
                  minutesDuration: session['duration_minute'],
                  child: _buildOwnSessionWidget(clas, session),
                ),
              );
            }
          } else {
            // the currently logged in teacher doesn't won these classes
            classColor = Colors.grey[350]!;
            for (dynamic session in clas.sessions) {
              sessions.add(
                TimePlannerTask(
                  color: classColor,
                  dateTime: TimePlannerDateTime(
                    day: session['day'],
                    hour: session['start_hour'],
                    minutes: session['start_minute'],
                  ),
                  minutesDuration: session['duration_minute'],
                  child: _buildAlienSessionWidget(clas, session),
                ),
              );
            }
          }
        }

        return TimePlanner(
          startHour: 0,
          endHour: 23,
          style: TimePlannerStyle(
            cellWidth: 76,
            horizontalTaskPadding: 2.0,
          ),
          headers: const [
            TimePlannerTitle(title: "Monday"),
            TimePlannerTitle(title: "Tuesday"),
            TimePlannerTitle(title: "Wednesday"),
            TimePlannerTitle(title: "Thursday"),
            TimePlannerTitle(title: "Friday"),
            TimePlannerTitle(title: "Saturday"),
            TimePlannerTitle(title: "Sunday"),
          ],
          tasks: sessions,
        );
      },
    );
  }

  void _handleDisplayedYearChange(Year? value) {
    if (displayedDepartment != null &&
        value != null &&
        displayedSection.isNotEmpty) {
      __setStream(displayedDepartment!, value, displayedSection);
    }
    setState(() {
      displayedYear = value;
    });
  }

  void _handleDisplayedDepartmentChange(Department? value) {
    if (displayedYear != null && value != null && displayedSection.isNotEmpty) {
      __setStream(value, displayedYear!, displayedSection);
    }
    setState(() {
      displayedDepartment = value;
    });
  }

  void _handleSectionChange(String value) {
    if (displayedYear != null && displayedYear != null && value.isNotEmpty) {
      __setStream(displayedDepartment!, displayedYear!, value);
    }
    setState(() {
      displayedSection = value;
    });
  }

  void __setStream(Department department, Year year, String section) {
    // alien classes are classes not owned by the currently logged in teacher.
    classesStream = FirestoreHelper.listenForClasses(
        department: department, year: year, section: section);
  }

  Widget _buildAlienSessionWidget(Class clas, session) {
    // one class many sessions
    return GestureDetector(
      // TODO: implement different behaviors for owned and alien sessions
      // onLongPress: () => _showOptionsDialog(clas),
      child: RotatedBox(
        quarterTurns: 3,
        child: ListTile(
          title: Text(
            clas.course,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "${Converter.formattedTime(session['start_hour'], session['start_minute'])} - "
            "${Converter.formattedTime(session['start_hour'], session['start_minute'] + session['duration_minute'])}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  _buildOwnSessionWidget(Class clas, session) {
    // one class many sessions
    return GestureDetector(
      // onLongPress: () => _showOptionsDialog(clas),
      child: RotatedBox(
        quarterTurns: 3,
        child: ListTile(
          title: Text(
            clas.course,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "${Converter.formattedTime(session['start_hour'], session['start_minute'])} - "
            "${Converter.formattedTime(session['start_hour'], session['start_minute'] + session['duration_minute'])}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
