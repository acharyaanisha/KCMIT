import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kcmit/dummymodel/imageList.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/section.dart';
import 'package:kcmit/view/Calendar.dart';
import 'package:kcmit/view/studentScreen/Course.dart';
import 'package:kcmit/view/studentScreen/forumScreen.dart';
import 'package:kcmit/view/studentScreen/stAttendance.dart';
import 'package:kcmit/view/studentScreen/stFacultyMember.dart';
import 'package:kcmit/view/studentScreen/stNotices.dart';
import 'package:kcmit/view/studentScreen/stProfile.dart';
import 'package:kcmit/view/Resource.dart';
import 'package:kcmit/view/studentScreen/stRoutine.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class StHomeScreen extends StatefulWidget {
  const StHomeScreen({super.key});

  @override
  State<StHomeScreen> createState() => _StHomeScreenState();
}

class _StHomeScreenState extends State<StHomeScreen> {

  StudentProfile? studentProfile;
  List<dynamic> noticeList = [];
  String errorMessage = '';
  bool isLoading = true;
  List<bool> _isExpandedList = [];


  @override
  void initState() {
    super.initState();
    fetchNoticeList();
    fetchUserData();
  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchNoticeList();
      fetchUserData();
    });
  }


  Future<void> fetchUserData() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStudentProfile();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          studentProfile = StudentProfile.fromJson(jsonResponse['data']);
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

  Future<void> fetchNoticeList() async {
    final url = Config.getStNotices();
    final token = context.read<studentTokenProvider>().token;
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
          preferredSize: Size.fromHeight(70),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            child: AppBar(
              title: Center(child: Text("KCMITians")),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.account_circle,size: 45,),
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
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
                Section(
                  title: "Quick Navigation",
                  iconsAndTexts: [
                    IconAndText(
                        Icons.timer_outlined, "Routine", StRoutineScreen(),
                        Colors.blue.shade300),
                    IconAndText(
                        Icons.circle_notifications_outlined,
                        "Notices",
                        StudentNotices(),
                        Colors.orange.shade300),
                    IconAndText(
                        Icons.download_for_offline_outlined,
                        "Resources",
                        Resource(),
                        Colors.purple.shade300),
                    IconAndText(
                        Icons.calendar_month_outlined,
                        "Calendar",
                        CalendarScreen(),
                        Colors.deepPurple.shade300),
                    IconAndText(
                        Icons.person,
                        "Faculty",
                        FacultyMemberList(),
                        Color(0xff8EB486)
                    ),
                    IconAndText(
                        Icons.check_circle_outline,
                        "Attendance",
                        StudentAttendance(),
                        Colors.amber.shade300
                    ),
                    IconAndText(
                        Icons.book_online_outlined,
                        "My Course",
                        CourseScreen(),
                        Color(0xffA294F9)
                    ),
                    IconAndText(
                        Icons.forum_outlined,
                        "Thread",
                        Forumscreen(),
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
                        fontSize: 16.0,
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

