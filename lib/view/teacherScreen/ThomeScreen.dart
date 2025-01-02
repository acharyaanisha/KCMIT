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
import 'package:kcmit/view/teacherScreen/FCalendar.dart';
import 'package:kcmit/view/teacherScreen/factRoutine.dart';
import 'package:kcmit/view/teacherScreen/faculltyProfile.dart';
import 'package:kcmit/view/teacherScreen/semesterList.dart';

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


  @override
  void initState() {
    super.initState();
    fetchNoticeList();
  }

  Future<void> fetchNoticeList() async {
    final url = Config.getStNotices();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          noticeList = jsonResponse['notices'];
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
                          FacultyRoutineScreen(),
                            Colors.blue.shade400
                        ),
                        IconAndText(
                          Icons.circle_notifications_outlined,
                          // "assets/notice.png",
                          "Notices",
                          StudentNotices(),
                            Colors.orange.shade400
                        ),
                        IconAndText(
                          Icons.download_for_offline_outlined,
                          // "assets/resource.png",
                          "Resources",
                            Resource(),
                            Colors.red.shade400
                        ),
                        IconAndText(
                          Icons.calendar_month_outlined,
                          "Calender",
                            FCalendarScreen(),
                            Colors.green.shade400
                        ),
                        IconAndText(
                            Icons.person,
                            "Faculty",
                            FacultyMemberList(),
                            Colors.deepPurple.shade300),
                        IconAndText(
                          Icons.check_circle_outline,
                          // "assets/attendance.png",
                          "Attendance",
                          StudentAttendance(),
                            Colors.amber.shade300
                        ),IconAndText(
                          Icons.forum_outlined,
                          // "assets/attendance.png",
                          "Threads",
                            semesterScreen(),
                            Colors.red.shade300
                        ),
                        // IconAndText(
                        //   Icons.check_circle_outline,
                        //   // "assets/attendance.png",
                        //   "Attendance",
                        //   StudentAttendance(),
                        //     Colors.deepPurple.shade300
                        // ),
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
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final noticeItem = noticeList[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpandedList[index] =
                                !_isExpandedList[index];
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 10.0),
                              child: Card(
                                color: Colors.grey.shade50,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                        maxLines: _isExpandedList[index]
                                            ? null
                                            : 2,
                                        overflow: _isExpandedList[index]
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      if (_isExpandedList[index])
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap:(){
                                                _showImageDialog(noticeItem['fileURL']);
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    8.0),
                                                child: Image.network(
                                                  noticeItem['fileURL'] !=
                                                      null &&
                                                      noticeItem[
                                                      'fileURL']
                                                          .startsWith(
                                                          'http')
                                                      ? noticeItem['fileURL']
                                                      : "http://46.250.248.179:5000/${noticeItem['fileURL'] ?? ''}",
                                                  width: MediaQuery.of(context).size.width * 0.85,
                                                  // height: 250,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context,
                                                      error, stackTrace) {
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

