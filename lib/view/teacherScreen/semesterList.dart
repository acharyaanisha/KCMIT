import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:kcmit/view/teacherScreen/threadScreen.dart';
import 'package:provider/provider.dart';

class semesterScreen extends StatefulWidget {
  const semesterScreen({super.key});

  @override
  State<semesterScreen> createState() => _semesterScreenState();
}

class _semesterScreenState extends State<semesterScreen> {

  String errorMessage = '';
  bool isLoading = true;
  List<dynamic> semesterList = [];

  @override
  void initState() {
    super.initState();
    fetchSemesterList();
  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      fetchSemesterList();
    });
  }

  Future<void> fetchSemesterList() async {
    final token = context.read<facultyTokenProvider>().token;
    final url = Config.getSemester();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("URL: $token");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          semesterList = jsonResponse['data'];
          print("object:$semesterList");
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load resources.';
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
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(60),
          ),
          child: AppBar(
            elevation: 5,
            title: const Text(
              "Threads",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 7.0,
                ),
                itemCount: semesterList.length,
                itemBuilder: (context, index) {
                  final semester = semesterList[index];
                  final row = index ~/ 2;
                  final col = index % 2;

                  final color = ((row % 2 == 0 && col == 0) || (row % 2 == 1 && col == 1))
                      ? Color(0xff3a3e79)
                      : Colors.red.shade400;

                  String uuid = semester['uuid'];
                  print("uuid:$uuid");

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ThreadScreen(uuid: uuid)),
                      );
                    },
                    child: Card(
                      color: color,
                      elevation: 6,
                      clipBehavior: Clip.none,
                      child: Stack(
                        children: [
                          Center(
                            child: Text('${semester['course']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child:
                              Text(
                                '${semester['semester']}',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
