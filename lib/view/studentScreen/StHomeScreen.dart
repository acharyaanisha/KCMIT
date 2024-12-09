import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kcmit/dummymodel/imageList.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/section.dart';
import 'package:kcmit/view/Calendar.dart';
import 'package:kcmit/view/studentScreen/stAttendance.dart';
import 'package:kcmit/view/studentScreen/stFacultyMember.dart';
import 'package:kcmit/view/studentScreen/stNotices.dart';
import 'package:kcmit/view/studentScreen/stProfile.dart';
import 'package:kcmit/view/studentScreen/stResource.dart';
import 'package:kcmit/view/studentScreen/stRoutine.dart';

class StHomeScreen extends StatefulWidget {
  const StHomeScreen({super.key});

  @override
  State<StHomeScreen> createState() => _StHomeScreenState();
}

class _StHomeScreenState extends State<StHomeScreen> with SingleTickerProviderStateMixin {

  List<dynamic> noticeList = [];
  String errorMessage = '';
  bool isLoading = true;
  int _currentIndex = 0;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  //
  //   if (_currentIndex == 1) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => GalleryScreen()),
  //     );
  //   } else if (_currentIndex == 2) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => StudentMenu()),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
    fetchNoticeList();
  }

  Future<void> fetchNoticeList() async {
    // final token = context.read<studentTokenProvider>().token;
    final url = Config.getStNotices();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          noticeList = jsonResponse['notices'];
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
        print("Error: $e");
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
        preferredSize:  Size.fromHeight(70),
    child: ClipRRect(
    borderRadius: const BorderRadius.vertical(
    bottom: Radius.circular(30),
    ),
    child:AppBar(
          title: Center(child: Text("KCMITians")),
          automaticallyImplyLeading: false,
          actions: [
      IconButton(
        icon: CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/profile.png'),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StProfile()),
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
                height: 250,
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: Duration(seconds: 5),
                  ),
                  items: imageList.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Column(
                  children: [
                    Section(
                      title: "Quick Navigation",
                      iconsAndTexts: [
                        IconAndText(
                          Icons.timer_outlined,
                          // "assets/routine.png",
                          "Routine",
                          StRoutineScreen(),
                            Colors.blue.shade300
                        ),
                        IconAndText(
                          Icons.circle_notifications_outlined,
                          // "assets/notice.png",
                          "Notices",
                          StudentNotices(),
                            Colors.orange.shade300
                        ),
                        IconAndText(
                          Icons.download_for_offline_outlined,
                          // "assets/resource.png",
                          "Resources",
                          StudentResource(),
                            Colors.purple.shade300
                        ),
                        IconAndText(
                          // "assets/calendar.png",
                          Icons.calendar_month_outlined,
                          "Calender",
                          CalendarScreen(),
                            Colors.red.shade300
                        ),
                        IconAndText(
                          Icons.person,
                          // "assets/faculty1.png",
                          "Faculty",
                          FacultyMemberList(),
                            Colors.deepPurple.shade300
                        ),
                        IconAndText(
                          Icons.check_circle_outline,
                          // "assets/attendance.png",
                          "Attendance",
                          StudentAttendance(),
                            Colors.amber.shade300
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Container(
                        child: Row(
                          children: [
                            Section2(title: "Latest Notices"),
                          ],
                        )
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20.0, top: 15.0,bottom: 15),
                    //   child: Container(
                    //     child: Column(
                    //       children: [
                    //         Text("Latest Notices",
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.bold
                    //         ),
                    //         textAlign: TextAlign.start,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Section2 extends StatelessWidget {
  final String title;
  // final List<IconAndText> iconsAndTexts;
  // final String? image;

  const Section2({super.key, required this.title, });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        // color: const Color(0xFFF3F5F8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 15.0,bottom: 15),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                color: Color(0xff000000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(

          )
        ],
      ),
    );
  }
}

