import 'package:flutter/material.dart';

class StudentContact extends StatefulWidget {
  const StudentContact({super.key});

  @override
  State<StudentContact> createState() => _StudentContactState();
}

class _StudentContactState extends State<StudentContact> {
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
            title: Text("Contact"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Contact"),
          ],
        ),
      ),
    );
  }
}
