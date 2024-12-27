import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FacultyRoutineScreen extends StatefulWidget {
  const FacultyRoutineScreen({super.key});

  @override
  State<FacultyRoutineScreen> createState() => _FacultyRoutineScreenState();
}

class _FacultyRoutineScreenState extends State<FacultyRoutineScreen> with SingleTickerProviderStateMixin{

  String? selectedItem;
  String errorMessage = '';
  bool isLoading = true;
  Map<String, dynamic> routineData = {};
  DateTime currentDate = DateTime.now();
  int currentDay = DateTime.now().weekday;
  StudentProfile? studentProfile;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    fetchRoutineData();
    // fetchUserData();
    setState(() {
      selectedItem = getDayFromIndex(currentDay);
    });
  }

  // Map weekday index to day name (Monday, Tuesday, etc.)
  String getDayFromIndex(int dayIndex) {
    switch (dayIndex) {
      case 1: return 'MONDAY';
      case 2: return 'TUESDAY';
      case 3: return 'WEDNESDAY';
      case 4: return 'THURSDAY';
      case 5: return 'FRIDAY';
      case 6: return 'SATURDAY';
      case 7: return 'SUNDAY';
      default: return 'MONDAY'; // Default fallback if the index is invalid
    }
  }

  Future<void> fetchRoutineData() async {
    final token = context.read<facultyTokenProvider>().token;
    final url = Config.getFacultyRoutine();
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
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          routineData = jsonResponse['data'];
          _tabController = TabController(
            length: routineData.keys.length,
            vsync: this,
            initialIndex: currentDay > 6 ? 0 : currentDay - 1,
          );
          errorMessage = '';
          isLoading = false;
        });

        // Ensure selectedItem matches a key in routineData
        if (!routineData.containsKey(selectedItem)) {
          setState(() {
            selectedItem = routineData.keys.isNotEmpty ? routineData.keys.first : null;
          });
        }
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

  // Future<void> fetchUserData() async {
  //   final token = context.read<studentTokenProvider>().token;
  //   final url = Config.getStudentProfile();
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  //       setState(() {
  //         studentProfile = StudentProfile.fromJson(jsonResponse['data']);
  //         errorMessage = '';
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         errorMessage = 'Failed to load user data.';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'Failed to load data.';
  //       isLoading = false;
  //     });
  //   }
  // }

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
            title: Text("Routine"),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 13.0, ),
        child: Column(
          children: [
            if (_tabController != null)
              TabBar(
                controller: _tabController,
                labelColor: Color(0xff323465),
                indicatorColor: Color(0xff323465),
                unselectedLabelColor: Colors.black,
                // indicator: BoxDecoration(
                //   color: Color(0xff323465),
                //   shape: BoxShape.rectangle,
                //   border: Border.all(
                //     color: Colors.white,
                //     width: 2.0,
                //   ),
                //   borderRadius: BorderRadius.circular(5)
                // ),
                tabs: routineData.keys.map((day) {
                  String firstThreeChars = day.length >= 3 ? day.substring(0, 3) : day;
                  return Container(
                      child: Tab(text: firstThreeChars,));
                }).toList(),
              ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0,top: 10),
                child: _tabController != null
                    ? TabBarView(
                  controller: _tabController,
                  children: routineData.keys.map((day) {
                    return routineData[day] != null
                        ? ListView.builder(
                      itemCount: routineData[day]!.length,
                      itemBuilder: (context, index) {
                        var routine = routineData[day]![index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          color: Colors.grey.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.timer_outlined, size: 50, color: Color(0xff323465)),
                            title: Text(
                              '${routine['startTime']} - ${routine['endTime']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${routine['subject']} (Room ${routine['room']})"),
                                Text('Semester:${routine['semester']}',style: TextStyle(fontSize: 15),),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : Image.asset(errorMessage);
                  }).toList(),
                )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



