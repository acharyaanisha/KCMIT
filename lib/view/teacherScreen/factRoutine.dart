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

class _FacultyRoutineScreenState extends State<FacultyRoutineScreen> with SingleTickerProviderStateMixin {
  String? selectedItem;
  String errorMessage = '';
  bool isLoading = true;
  Map<String, dynamic> routineData = {};
  DateTime currentDate = DateTime.now();
  int currentDay = DateTime.now().weekday;
  StudentProfile? studentProfile;
  TabController? _tabController;

  List<String> orderedDays = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];

  @override
  void initState() {
    super.initState();
    fetchRoutineData();
    setState(() {
      selectedItem = getDayFromIndex(currentDay);
    });
  }

  String getDayFromIndex(int dayIndex) {
    switch (dayIndex) {
      case 1: return 'SUNDAY';
      case 2: return 'MONDAY';
      case 3: return 'TUESDAY';
      case 4: return 'WEDNESDAY';
      case 5: return 'THURSDAY';
      case 6: return 'FRIDAY';
      case 7: return 'SATURDAY';
      default: return 'SUNDAY';
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

          List<String> availableDays = orderedDays.where((day) => routineData.containsKey(day)).toList();
          _tabController = TabController(
            length: availableDays.length,
            vsync: this,
            initialIndex: currentDay > 6 ? 0 : currentDay,
          );
          errorMessage = '';
          isLoading = false;
        });


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
        padding: const EdgeInsets.only(top: 13.0),
        child: Column(
          children: [
            if (_tabController != null)
              TabBar(
                controller: _tabController,
                labelColor: Color(0xff323465),
                indicatorColor: Color(0xff323465),
                unselectedLabelColor: Colors.black,
                tabs: orderedDays.where((day) => routineData.containsKey(day)).map((day) {
                  String firstThreeChars = day.length >= 3 ? day.substring(0, 3) : day;
                  return Container(
                    child: Tab(text: firstThreeChars),
                  );
                }).toList(),
              ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
                child: _tabController != null
                    ? TabBarView(
                  controller: _tabController,
                  children: orderedDays.where((day) => routineData.containsKey(day)).map((day) {
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
                                Text('Semester:${routine['semester']}', style: TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : Image.asset(errorMessage);
                  }).toList(),
                )
                    : Container(
                    height: MediaQuery.of(context).size.height*0.9,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset('assets/no_data.png')
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



