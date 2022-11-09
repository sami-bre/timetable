import 'package:class_scheduler/models/class.dart';
import 'package:class_scheduler/models/session.dart';
import 'package:class_scheduler/models/teacher.dart';
import 'package:class_scheduler/util/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register.dart';

class AddClassScreen extends StatefulWidget {
  final User user;
  final Department department;
  final Year year;
  final String section;
  const AddClassScreen(this.user, this.department, this.year, this.section,
      {super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  TextEditingController txtCourseName = TextEditingController();
  List<Session> sessions = [];
  // the two properties below are temporary stores for a session data while the session is being created.
  int? day;
  Time? time;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adding a class"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCourseNameField(),
                for (int j = 0; j < sessions.length; j++)
                  ListTile(
                    title: Text("${sessions[j].day.name}\n"),
                    subtitle: Text(
                      "starts at: ${sessions[j].startTime.format(context)}\n"
                      "ends at: ${Time(
                        hour: sessions[j].startTime.hour,
                        minute: sessions[j].startTime.minute +
                            sessions[j].durationMinute,
                      ).format(context)}",
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    var data = await showDialog<Session?>(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          scrollable: true,
                          title: Text("Adding a session"),
                          content: AddSessionDialogContent(),
                        );
                      },
                    );
                    if (data != null) {
                      sessions.add(data);
                      setState(() {});
                    }
                    print(sessions.length);
                  },
                  child: const Text('Add a session'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Teacher? owner =
                          await FirestoreHelper.getTeacherDocument(widget.user);
                      // we assume the owner is not null because the teacher is logged in (exists) because
                      // the teacher document must've been created when the teacher got registered.
                      var clas = Class(
                        txtCourseName.text,
                        widget.department,
                        widget.section,
                        widget.year,
                        widget.user.uid,
                        owner!.name,
                        sessions.map((e) => e.toMap()).toList(),
                      );
                      FirestoreHelper.addClass(clas);
                    }
                  },
                  child: const Text("Publish class"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildCourseNameField() {
    return TextFormField(
      controller: txtCourseName,
      decoration: const InputDecoration(hintText: "Course name"),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Course name can't be empity";
        }
        return null;
      },
    );
  }
}

class AddSessionDialogContent extends StatefulWidget {
  const AddSessionDialogContent({super.key});

  @override
  State<AddSessionDialogContent> createState() =>
      _AddSessionDialogContentState();
}

class _AddSessionDialogContentState extends State<AddSessionDialogContent> {
  Day? day;
  Time? startTime;
  Time? endTime;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton(
          value: day,
          items: const [
            DropdownMenuItem(
              value: Day.monday,
              child: Text("Monday"),
            ),
            DropdownMenuItem(
              value: Day.tuesday,
              child: Text("Tuesday"),
            ),
            DropdownMenuItem(
              value: Day.wednesday,
              child: Text("Wednesday"),
            ),
            DropdownMenuItem(
              value: Day.thursday,
              child: Text("ThursDay"),
            ),
            DropdownMenuItem(
              value: Day.friday,
              child: Text("Friday"),
            ),
            DropdownMenuItem(
              value: Day.saturday,
              child: Text("Saturday"),
            ),
            DropdownMenuItem(
              value: Day.sunday,
              child: Text("Sunday"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              day = value;
            });
          },
        ),
        Row(
          children: [
            Expanded(
              child: (startTime != null)
                  ? Text(startTime!.format(context))
                  : const SizedBox(),
            ),
            TextButton(
              onPressed: () async {
                var temp = await showTimePicker(
                  context: context,
                  initialTime: Time.now(),
                );
                var temp2 = (temp != null)
                    ? Time(hour: temp.hour, minute: temp.minute)
                    : null;
                setState(() {
                  startTime = temp2;
                });
              },
              child: const Text("Set start time"),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: (endTime != null)
                  ? Text(endTime!.format(context))
                  : const SizedBox(),
            ),
            TextButton(
              onPressed: () async {
                var temp = await showTimePicker(
                  context: context,
                  initialTime: Time.now(),
                );
                var temp2 = (temp != null)
                    ? Time(hour: temp.hour, minute: temp.minute)
                    : null;
                setState(() {
                  endTime = temp2;
                });
              },
              child: const Text("Set end time"),
            ),
          ],
        ),
        if (errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ElevatedButton(
          onPressed: () {
            String? tempMessage;
            if (day == null) {
              tempMessage = "You need to select a day";
            } else if (startTime == null) {
              tempMessage = "You need to set the starting time";
            } else if (endTime == null) {
              tempMessage = "You need to set the ending time";
            }
            setState(() {
              errorMessage = tempMessage;
            });
            if (day != null && startTime != null && endTime != null) {
              Navigator.of(context).pop(
                Session(
                  day!,
                  startTime!,
                  (endTime!.hour * 60 + endTime!.minute) -
                      (startTime!.hour * 60 + startTime!.minute),
                ),
              );
            }
          },
          child: const Text("Done"),
        )
      ],
    );
  }
}
