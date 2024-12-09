import 'package:flutter/material.dart';
import 'package:kcmit/service/section.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stContact.dart';
import 'package:kcmit/view/studentScreen/stExam.dart';
import 'package:kcmit/view/studentScreen/stSetting/stChangePassword.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stResult.dart';
import 'package:kcmit/view/studentScreen/stRoutine.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stSetting.dart';

class StudentMenu extends StatefulWidget {
  const StudentMenu({super.key});

  @override
  State<StudentMenu> createState() => _StudentMenuState();
}

class _StudentMenuState extends State<StudentMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(100),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
          child: AppBar(
           title: Text("Menu"),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Section(
              title: "",
              iconsAndTexts: [
                IconAndText(
                  Icons.assignment_outlined,
                  // "assets/result.png",
                  "Result",
                  StudentResult(),
                    Colors.deepPurple.shade300
                ),
                IconAndText(
                  Icons.settings_outlined,
                  // "assets/setting.png",
                  "Setting",
                  StudentSetting(),
                    Colors.deepPurple.shade300
                ),
                IconAndText(
                  Icons.assignment_add,
                  // "assets/exam.png",
                  "Exam",
                    StudentResut(),
                    Colors.deepPurple.shade300
                ),
                IconAndText(
                  Icons.contact_phone_outlined,
                  // "assets/contact.png",
                  "Contact",
                  StudentContact(),
                    Colors.deepPurple.shade300
                ),
                IconAndText(
                  Icons.timer,
                  // "assets/routine.png",
                  "Routine",
                  StRoutineScreen(),
                    Colors.deepPurple.shade300

                ),
              ],
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
