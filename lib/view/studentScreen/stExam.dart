import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StudentResut extends StatefulWidget {
  const StudentResut({super.key});

  @override
  State<StudentResut> createState() => _StudentResutState();
}

class _StudentResutState extends State<StudentResut> {

  String errorMessage = '';
  bool isLoading = true;
  List<dynamic> examRoutineList = [];

  @override
  void initState() {
    super.initState();
    fetchExamRoutine();
  }

  Future<void> fetchExamRoutine() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getExam();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          examRoutineList = jsonResponse['data'];
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load resources.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data.';
        isLoading = false;
      });
    }
  }

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
