import 'dart:convert';
import 'dart:io';
import 'package:kcmit/view/studentScreen/stMenuItem/stSetting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kcmit/model/profileModel/studentProfileModel.dart';
import 'package:kcmit/view/authentication/loginPage.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:kcmit/view/studentScreen/uploadProfile.dart';
import 'package:provider/provider.dart';
import '../../service/config.dart';

class StProfile extends StatefulWidget {
  const StProfile({Key? key}) : super(key: key);

  @override
  State<StProfile> createState() => _StProfileState();
}

class _StProfileState extends State<StProfile> {

  StudentProfile? studentProfile;
  String errorMessage = '';
  bool isLoading = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final token = context
        .read<studentTokenProvider>()
        .token;
    final url = Config.getStudentProfile();

    print("url:$url");
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response:${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<
            String,
            dynamic>;
        setState(() {
          studentProfile = StudentProfile.fromJson(jsonResponse['data']);
          print("Profile:$studentProfile");
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: const Text('Student Profile'),
            centerTitle: true,
            elevation: 0,

            // actions: [
            //   IconButton(
            //       onPressed: (){
            //         Navigator.pushReplacement(
            //           context,
            //           MaterialPageRoute(builder: (context) => EditProfile()),
            //         ).then((_) {
            //         });
            //       }, icon: Icon(Icons.edit)),
            // ],

          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.only(left: 300.0),
                child: ClipOval(
                  child: IconButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentSetting()),
                    );
                  },
                      icon: Icon(Icons.settings_outlined)),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.155,
                width: MediaQuery.of(context).size.width*0.32,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xff323465),
                    width: 1.0,
                  ),
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  // color: Color(0xff323465),
                ),
                child: studentProfile?.profilePicture != null &&
                    studentProfile!.profilePicture!.isNotEmpty
                    ? ClipRRect(
                  child: Image.network(
                    studentProfile!.profilePicture!.startsWith('http')
                        ? studentProfile!.profilePicture!
                        : "http://kcmit-api.kcmit.edu.np:5000/${studentProfile!
                        .profilePicture!}",
                    height: MediaQuery.of(context).size.height*0.15,
                    width: MediaQuery.of(context).size.width*0.3,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Color(0xff323465),
                        size: 50,
                      );
                    },
                  ),
                )
                    : const Icon(
                  Icons.person,
                  color: Color(0xff323465),
                  size: 50,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.003,
              ),
              Text(
                studentProfile?.fullName.toUpperCase() ?? 'N/A',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // SizedBox(height: MediaQuery.of(context).size.height*0.00001),
              Text(
                studentProfile?.email ?? 'N/A',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.015),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.3,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.04,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xff323465),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.transparent,
                  // color: Color(0xff323465),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    ).then((_) {});
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 15,
                            color: Color(0xff323465),
                          ),
                          SizedBox(width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.025),
                          Text(
                            'Edit Profile',
                            style: const TextStyle(
                              color: Color(0xff323465),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              // const Divider(color: Colors.black, thickness: 0.1),
              // Student Details
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileTile(
                        icon: Icons.phone,
                        title: 'Phone Number',
                        value: studentProfile?.phoneNumber ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date of Birth',
                        value: studentProfile?.dateOfBirth ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: studentProfile?.gender == 'MALE'
                            ? Icons.male
                            : Icons.female,
                        title: 'Gender',
                        value: studentProfile?.gender ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.home_outlined,
                        title: 'Address',
                        value: studentProfile?.address ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.school_outlined,
                        title: 'Program',
                        value: studentProfile?.enrolledProgramName ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.book_outlined,
                        title: 'Semester',
                        value: studentProfile?.enrolledSemesterName ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.check_box_outlined,
                        title: 'Batch',
                        value: studentProfile?.batch ?? 'N/A',
                      ),
                      Divider(thickness: 0.09, color: Colors.grey),
                      _buildProfileTile(
                        icon: Icons.date_range_outlined,
                        title: 'Enrollment Date',
                        value: studentProfile?.enrollmentDate ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),

              // Logout Button
              // ElevatedButton.icon(
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const LoginPage()),
              //           (Route<dynamic> route) => false,
              //     );
              //   },
              //   icon: const Icon(Icons.logout, color: Colors.white),
              //   label: const Text(
              //     "Log Out",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xff323465),
              //     padding: const EdgeInsets.symmetric(
              //         horizontal: 30, vertical: 10),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     textStyle: const TextStyle(
              //       fontSize: 16,
              //     ),
              //   ),
              // ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black, size: 25),
            SizedBox(width: MediaQuery.of(context).size.width*0.05),
            Expanded(
              child: Text(
                title,
                style:  TextStyle(fontWeight:FontWeight.bold,color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(color: Colors.black),
              ),

            ),
          ],
        ),
        // Divider(thickness: 0.09, color: Colors.grey),
      ],
    );
  }
}