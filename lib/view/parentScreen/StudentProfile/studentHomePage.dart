import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/paStudentViewModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/section.dart';
import 'package:kcmit/view/Calendar.dart';
import 'package:kcmit/view/parentScreen/StudentProfile/StudentProfile.dart';
import 'package:kcmit/view/parentScreen/parentTokenProvider.dart';
import 'package:kcmit/view/studentScreen/stAttendance.dart';
import 'package:kcmit/view/studentScreen/stNotices.dart';
import 'package:kcmit/view/studentScreen/stProfile.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stResult.dart';
import 'package:kcmit/view/studentScreen/stRoutine.dart';
import 'package:provider/provider.dart';

class StudentHomePage extends StatefulWidget {

  final String uuid;

  const StudentHomePage({super.key, required this.uuid});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  StudentView? studentView;
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final token = context.read<parentTokenProvider>().token;
    final requestBody = jsonEncode({'uuid': '${widget.uuid}'});
    print('Requesting uuid: ${widget.uuid}');
    final url = Config.getStudentView();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print("uuid:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          studentView = StudentView.fromJson(jsonResponse['data']);
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user data.';
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
            title: Text(studentView?.fullName ?? 'N/A'),
            actions: [
              IconButton(
                icon: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                onPressed: () {
                  final student = studentView;
                  String uuid = student?.uuid?? 'N/A';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ParentStProfile(uuid:uuid)),
                  );

                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
        Container(
        child: Column(
        children: [
          Section(
          title: "",
          iconsAndTexts: [
            // IconAndText(
            //     Icons.timer_outlined,
            //     // "assets/routine.png",
            //     "Routine",
            //     StRoutineScreen(),
            //     Colors.blue.shade300
            // ),
            IconAndText(
                Icons.circle_notifications_outlined,
                // "assets/notice.png",
                "Notices",
                StudentNotices(),
                Colors.orange.shade300
            ),
            IconAndText(
              // "assets/calendar.png",
                Icons.calendar_month_outlined,
                "Calender",
                CalendarScreen(),
                Colors.red.shade300
            ),
            IconAndText(
                Icons.check_circle_outline,
                // "assets/attendance.png",
                "Attendance",
                StudentAttendance(),
                Colors.amber.shade300
            ),
            IconAndText(
                Icons.assignment_outlined,
                // "assets/result.png",
                "Result",
                StudentResult(),
                Colors.deepPurple.shade300
            ),
          ],
        ),
          ],
        ),
      )
    ],
    ),
    )
    );
  }
}
