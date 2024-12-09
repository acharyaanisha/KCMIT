import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/resultSection.dart';
import 'package:kcmit/view/studentScreen/stResultScreen.dart';

class StudentResult extends StatefulWidget {
  const StudentResult({super.key});

  @override
  State<StudentResult> createState() => _StudentResultState();
}

class _StudentResultState extends State<StudentResult> with SingleTickerProviderStateMixin {

  String errorMessage = '';
  bool isLoading = true;
  List<dynamic> examList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchExamList();
  }


  Future<void> fetchExamList() async {
    final url = Config.getExamList();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          examList = jsonResponse['data'];
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
          child: AppBar(
            title: const Text("Result"),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 18),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(text: "Assessment Result"),
                Tab(text: "Board Result"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Assessment Tab
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ResultSection(
                    title: "",
                    iconsAndTexts: [
                      IconAndText(
                          Icons.assignment_outlined,
                          "Result",
                          StudentResultScreen(),
                          Colors.deepPurple.shade300
                      ),
                      IconAndText(
                          Icons.assignment_outlined,
                          "Result",
                          StudentResultScreen(),
                          Colors.red.shade300
                      ),
                      IconAndText(
                          Icons.assignment_outlined,
                          "Result",
                          StudentResultScreen(),
                          Colors.green.shade300
                      ),
                      IconAndText(
                          Icons.assignment_outlined,
                          "Result",
                          StudentResultScreen(),
                          Colors.blue.shade300
                      ),
                      IconAndText(
                          Icons.assignment_outlined,
                          "Result",
                          StudentResultScreen(),
                          Colors.orange.shade300
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Board Tab
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Text("Board Result Content"),
            ),
          ),
        ],
      ),
    );
  }
}
