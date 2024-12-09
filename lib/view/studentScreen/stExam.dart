import 'package:flutter/material.dart';

class StudentResut extends StatefulWidget {
  const StudentResut({super.key});

  @override
  State<StudentResut> createState() => _StudentResutState();
}

class _StudentResutState extends State<StudentResut> {
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
            title: Text("Exam"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Exam Screen"),
          ],
        ),
      ),
    );
  }
}
