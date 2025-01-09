import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kcmit/dummymodel/imageList.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/section.dart';
import 'package:kcmit/view/studentScreen/stAttendance.dart';
import 'package:kcmit/view/studentScreen/stFacultyMember.dart';
import 'package:kcmit/view/studentScreen/stNotices.dart';
import 'package:kcmit/view/Resource.dart';
import 'package:kcmit/view/teacherScreen/factRoutine.dart';
import 'package:kcmit/view/teacherScreen/faculltyProfile.dart';
import 'package:kcmit/view/teacherScreen/facultyCalender.dart';
import 'package:kcmit/view/teacherScreen/facultyNotice.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:kcmit/view/teacherScreen/semesterList.dart';
import 'package:provider/provider.dart';

class TeachHomeScreen extends StatefulWidget {
  const TeachHomeScreen({super.key});

  @override
  State<TeachHomeScreen> createState() => _TeachHomeScreenState();
}

class _TeachHomeScreenState extends State<TeachHomeScreen> with SingleTickerProviderStateMixin {

  List<dynamic> noticeList = [];
  String errorMessage = '';
  bool isLoading = true;
  List<bool> _isExpandedList = [];
  int _currentindex = 0;

  List<String> captions = [
    "College Premises",
    "Principal",
    "Freshers",
    'Faculty Members',
    "Teachers Day Celebration",
    'Graduation',
    "Sports",
    "Students",
  ];


  @override
  void initState() {
    super.initState();
    fetchNoticeList();
  }

  Future<void> fetchNoticeList() async {
    final url = Config.getStNotices();
    final token = context.read<facultyTokenProvider>().token;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          noticeList = jsonResponse['data'];
          _isExpandedList = List.filled(noticeList.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load notices.';
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

  void _showImageDialog(String fileUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 1.0,
            maxScale: 5.0,
            child: Image.network(
              fileUrl.startsWith('http')
                  ? fileUrl
                  : "http://46.250.248.179:5000/$fileUrl",
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height*0.5,
              width: MediaQuery.of(context).size.width*0.5,
            ),
          ),
        );
      },
    );
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
                      MaterialPageRoute(builder: (_) => FacultyProfileScreen()),
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.33,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      // Carousel Slider
                      CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.28,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          autoPlayInterval: Duration(seconds: 5),
                          pageSnapping: true,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentindex = index;
                            });
                          },
                        ),
                        items: imageList.map((imageUrl) {
                          int index = imageList.indexOf(imageUrl);
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.height * 0.9,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                    children:[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: Image.asset(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          height: MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(0)
                                          ),
                                          child: Text(
                                            captions[_currentindex],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),)
                                    ]
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015,
                      ),
                      // Changing Circle Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageList.length,
                              (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            height: MediaQuery.of(context).size.height * 0.004,
                            width: _currentindex == index ? 20 : 10,
                            decoration: BoxDecoration(
                              color: _currentindex == index ? Color(0xff323465) : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            Icons.forum_outlined,
                            // "assets/attendance.png",
                            "Threads",
                            semesterScreen(),
                            Colors.orange.shade300
                        ),
                        IconAndText(
                          Icons.timer_outlined,
                          // "assets/routine.png",
                          "Routine",
                          FacultyRoutineScreen(),
                            Colors.blue.shade400
                        ),
                        IconAndText(
                          Icons.circle_notifications_outlined,
                          // "assets/notice.png",
                          "Notices",
                            FacultyNotices(),
                            Colors.deepPurple.shade300
                        ),
                        IconAndText(
                          Icons.download_for_offline_outlined,
                          // "assets/resource.png",
                          "Resources",
                            Resource(),
                            Color(0xff8EB486)
                        ),
                        IconAndText(
                            Icons.person,
                            "Faculties",
                            FacultyMemberList(),
                            Color(0xffA294F9)),
                        IconAndText(
                          Icons.calendar_month_outlined,
                          "Calender",
                            FacultyCalendarScreen(),
                            Colors.green.shade400
                        ),
                        IconAndText(
                          Icons.check_circle_outline,
                          // "assets/attendance.png",
                          "Attendance",
                          StudentAttendance(),
                            Colors.red.shade300
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Latest Notices",
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Color(0xff000000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : noticeList.isEmpty
                          ? Center(child: Text("No notices available."))
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: noticeList.length > 5 ? 5 : noticeList.length,
                        itemBuilder: (context, index) {
                          final noticeItem = noticeList[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpandedList[index] = !_isExpandedList[index];
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                              child: Card(
                                color: Colors.grey.shade50,
                                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        noticeItem['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 17,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            noticeItem['date'],
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        _isExpandedList[index]
                                            ? noticeItem['desc']
                                            : noticeItem['desc'],
                                        maxLines: _isExpandedList[index] ? null : 2,
                                        overflow: _isExpandedList[index]
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      SizedBox(height: 5),
                                      if (_isExpandedList[index])
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showImageDialog(noticeItem['fileURL']);
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  noticeItem['fileURL'] != null &&
                                                      noticeItem['fileURL']
                                                          .startsWith('http')
                                                      ? noticeItem['fileURL']
                                                      : "http://46.250.248.179:5000/${noticeItem['fileURL'] ?? ''}",
                                                  width: MediaQuery.of(context).size.width * 0.85,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Text("");
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

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


