import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StRoutineScreen extends StatefulWidget {
  const StRoutineScreen({super.key});

  @override
  State<StRoutineScreen> createState() => _StRoutineScreenState();
}
class _StRoutineScreenState extends State<StRoutineScreen> with SingleTickerProviderStateMixin {
  String? selectedItem;
  String errorMessage = '';
  bool isLoading = true;
  Map<String, dynamic> routineData = {};
  DateTime currentDate = DateTime.now();
  int currentDay = DateTime.now().weekday;
  StudentProfile? studentProfile;
  TabController? _tabController;

  // Reorder days of the week for correct sequence
  List<String> orderedDays = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];

  @override
  void initState() {
    super.initState();
    fetchRoutineData();
    fetchUserData();
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
      default: return 'SUNDAY';
    }
  }

  Future<void> fetchRoutineData() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStudentRoutine();
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
          routineData = jsonResponse['data'];
          errorMessage = 'assets/no_data.png';
          isLoading = false;

          List<String> availableDays = orderedDays.where((day) => routineData.containsKey(day)).toList();

          _tabController = TabController(
            length: availableDays.length,
            vsync: this,
            initialIndex: currentDay > 6 ? 0 : currentDay,
          );
        });
      } else {
        setState(() {
          errorMessage = 'assets/no_data.png';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'assets/no_data.png';
        isLoading = false;
      });
    }
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
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          studentProfile = StudentProfile.fromJson(jsonResponse['data']);
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'assets/no_data.png';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'assets/no_data.png';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: const Text("Routine"),
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
                  return Tab(text: firstThreeChars);
                }).toList(),
              ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                            leading: const Icon(
                              Icons.timer_outlined,
                              size: 50,
                              color: Color(0xff323465),
                            ),
                            title: Text(
                              '${routine['startTime']} - ${routine['endTime']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${routine['subject']} (Room ${routine['room']})"),
                                Text(routine['faculty']),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : Center(child: Image.asset(errorMessage));
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
