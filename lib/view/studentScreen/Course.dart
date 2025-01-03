import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  Map<String, dynamic> course = {};
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourseList();
  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchCourseList();
    });
  }
  Future<void> fetchCourseList() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getCourse();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          course = jsonResponse['course'];  // Fetching course details
          print("Course: $course");
          errorMessage = '';  // Reset error message
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load course data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
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
            title: Text("My course"),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Name
              Text(
                "${course['name'] ?? 'No description available.'}",
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 5,),
              // Course Description
              Text(
                "${course['desc'] ?? 'No description available.'}",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
              // Duration
              Text(
                "Duration: ${course['duration'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Semester Count
              Text(
                "Semester Count: ${course['semester_count'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Subject Count
              Text(
                "Subject Count: ${course['subject_count'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Seats
              Text(
                "Seats: ${course['seat'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Credit Hours
              Text(
                "Credit Hours: ${course['credit_hours'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Stream
              Text(
                "Stream: ${course['stream'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Curriculum (Semesters)
              Text(
                "Curriculum (Semesters):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: course['curriculums']?.length ?? 0,
                itemBuilder: (context, index) {
                  final semester = course['curriculums'][index];
                  final subjects = semester['subjects'] ?? [];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide.none,
                    ),
                    color: Colors.grey.shade50,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide.none,
                      ),
                      tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      title: Text(semester['semester']),
                      children: [
                        subjects.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "No subjects available",
                            style: TextStyle(fontSize: 14),
                          ),
                        )
                            : SingleChildScrollView(
                          // scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0,left: 15,right: 10,bottom: 10),
                            child: DataTable(
                              headingRowHeight: MediaQuery.of(context).size.height*0.06,
                              dataRowHeight:MediaQuery.of(context).size.height*0.09,
                              columnSpacing:MediaQuery.of(context).size.width*0.1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400, width: 2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Subject Name',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Code',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Credit\nHour ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              rows: subjects.map<DataRow>((subject) {
                                return DataRow(cells: [
                                  DataCell(Text(subject['subject_name'])),
                                  DataCell(Text(subject['subject_code'])),
                                  DataCell(Text(subject['credit_hour'].toString())),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
