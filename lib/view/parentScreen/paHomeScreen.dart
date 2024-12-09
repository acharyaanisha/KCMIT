import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kcmit/dummymodel/imageList.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/parentScreen/StudentProfile/studentHomePage.dart';
import 'package:kcmit/view/parentScreen/parentProfile.dart';
import 'package:kcmit/view/parentScreen/parentTokenProvider.dart';
import 'package:provider/provider.dart';

class PaHomeScreen extends StatefulWidget {
  const PaHomeScreen({super.key});

  @override
  State<PaHomeScreen> createState() => _PaHomeScreenState();
}

class _PaHomeScreenState extends State<PaHomeScreen> {

  List<dynamic> studentList = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentList();
  }

  Future<void> fetchStudentList() async {
    final token = context.read<parentTokenProvider>().token;
    final url = Config.getStudentList();
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
            studentList = jsonResponse['data'];
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

  @override
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
            title:  Center(child: Text("KCMITians")),
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
                    MaterialPageRoute(builder: (_) => ParentProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children:  [
            // CarouselSlider section
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
            // Students list display section
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Text("My children",
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,),
                SizedBox(height: 10),
                studentList.isEmpty
                    ? Center(child: Text(errorMessage))
                    : GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3.0,
                        mainAxisSpacing: 5.0,
                      ),
                      itemCount: studentList.length,
                      itemBuilder: (context, index) {
                        final student = studentList[index];
                        String uuid = student['uuid'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentHomePage(
                                  uuid: uuid,
                                ),
                              ),
                            );
                          },
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Card(
                                elevation: 5.0,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.deepPurple[100],
                                          radius: 30,
                                          child: student['profilePicture'] != null
                                              ? ClipOval(
                                            child: Image.network(
                                              student['profilePicture']
                                                  .startsWith('http')
                                                  ? student['profilePicture']
                                                  : "http://192.168.1.78:5000/${student['profilePicture']}",
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(Icons.person, color: Color(0xff323465), size: 40);
                                              },
                                            ),
                                          )
                                              : const Icon(
                                            Icons.person,
                                            color: Color(0xff323465),
                                            size: 50,
                                          ),
                                        ),
                                        Divider(),
                                        SizedBox(height: 5,),
                                        Text(
                                          student['fullName'] ?? 'N/A',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16.0,  // Adjusted font size
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          student['enrolledCourse'] ?? 'N/A',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14.0,  // Adjusted font size
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                      },
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
