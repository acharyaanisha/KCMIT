import 'package:flutter/material.dart';

class StudentAttendance extends StatefulWidget {
  const StudentAttendance({super.key});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Attendance"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Attendance"),
          ],
        ),
      ),
    );
  }
}

