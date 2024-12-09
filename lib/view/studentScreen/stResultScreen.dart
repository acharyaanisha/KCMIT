import 'package:flutter/material.dart';

class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({super.key});

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
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
            title: Text("Result"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Result Screen"),
          ],
        ),
      ),
    );
  }
}

