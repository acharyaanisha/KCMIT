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

class _StRoutineScreenState extends State<StRoutineScreen> {

  String? selectedItem;
  String errorMessage = '';
  bool isLoading = true;
  Map<String, dynamic> routineData = {};
  DateTime currentDate = DateTime.now();
  int currentDay = DateTime.now().weekday;
  StudentProfile? studentProfile;

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
      case 1: return 'MONDAY';
      case 2: return 'TUESDAY';
      case 3: return 'WEDNESDAY';
      case 4: return 'THURSDAY';
      case 5: return 'FRIDAY';
      case 6: return 'SATURDAY';
      case 7: return 'SUNDAY';
      default: return 'MONDAY';
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
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          routineData = jsonResponse['data'];
          errorMessage = '';
          isLoading = false;
        });

        if (routineData.isEmpty) {
          setState(() {
            errorMessage = 'assets/no_data.png';
          });
        }

        if (!routineData.containsKey(selectedItem)) {
          setState(() {
            selectedItem = routineData.keys.isNotEmpty ? routineData.keys.first : null;
          });
        }
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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
        errorMessage = "assets/no_data.png";
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : routineData.isEmpty
          ? Center(
        child: errorMessage.isNotEmpty
            ? (errorMessage.contains('no_data.png')
            ? Image.asset(errorMessage)
            : Text(errorMessage))
            : Text('No routine data found.'),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemCount: routineData.keys.length,
                itemBuilder: (context, index) {
                  final day = routineData.keys.elementAt(index);
                  String firstThreeChars = day.length >= 3 ? day.substring(0, 3) : day;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedItem = day;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        color: selectedItem == day ? Color(0xff323465) : Colors.white,
                        child: Center(
                          child: Text(
                            firstThreeChars,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selectedItem == day ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            selectedItem != null
                ? Container(
              height: 640,
              child: Column(
                children: [
                  if (routineData[selectedItem] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(routineData[selectedItem]!.length, (index) {
                        var routine = routineData[selectedItem]![index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Card(
                            color: Colors.white,
                            // color: Color(0xffe8edef),
                            elevation: 8,
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(30),
                                  ),
                                  child: Icon(Icons.timer_outlined, size: 50)),
                              title: Text('${routine['startTime']} - ${routine['endTime']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(routine['subject'], style: TextStyle(fontSize: 15)),
                                  Text('${routine['room']}', style: TextStyle(fontSize: 15)),
                                  Text('${routine['faculty']}', style: TextStyle(fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  else
                    Text('No routine found for this day'),
                ],
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
