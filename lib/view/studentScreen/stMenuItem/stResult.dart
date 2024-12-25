import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/service/resultSection.dart';
import 'package:kcmit/view/studentScreen/stResultScreen.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

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
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getExamList();
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
        preferredSize: const Size.fromHeight(120),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: const Text("Result"),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),

              child: TabBar(
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Assessment Tab
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: examList.length,
                    itemBuilder: (context, index) {
                      final row = index ~/ 2;
                      final col = index % 2;

                      final color = ((row % 2 == 0 && col == 0) || (row % 2 == 1 && col == 1))
                          ? Color(0xff3a3e79)
                          : Colors.red.shade400;

                      final exam = examList[index];
                      String examSetupUuid = exam['examSetupUUid'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StudentResultScreen(examSetupUuid: examSetupUuid,)),
                          );
                        },
                        child: Card(
                          color: color,
                          elevation: 5,

                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: Icon(Icons.assignment_outlined,size: 70,
                                            color: Colors.white,
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
                                    exam['examSetupName'],
                                    style: const TextStyle(
                                      fontSize: 12.0,
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
                  )


                  // ResultSection(
                  //   title: "",
                  //   iconsAndTexts: [
                  //     IconAndText(
                  //         Icons.assignment_outlined,
                  //         examList['name'],
                  //         StudentResultScreen(),
                  //         Colors.deepPurple.shade300
                  //     ),
                  //     IconAndText(
                  //         Icons.assignment_outlined,
                  //         "Result",
                  //         StudentResultScreen(),
                  //         Colors.red.shade300
                  //     ),
                  //     IconAndText(
                  //         Icons.assignment_outlined,
                  //         "Result",
                  //         StudentResultScreen(),
                  //         Colors.green.shade300
                  //     ),
                  //     IconAndText(
                  //         Icons.assignment_outlined,
                  //         "Result",
                  //         StudentResultScreen(),
                  //         Colors.blue.shade300
                  //     ),
                  //     IconAndText(
                  //         Icons.assignment_outlined,
                  //         "Result",
                  //         StudentResultScreen(),
                  //         Colors.orange.shade300
                  //     ),
                  //   ],
                  // ),

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
