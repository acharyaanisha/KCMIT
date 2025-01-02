import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
    final token = context.read<studentTokenProvider>().token;
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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

            actions: [
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfile()),
                );
              }, icon: Icon(Icons.edit)),
            ],

          ),
        ),
      ),
      body: Container(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
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
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child:
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple[100],
                    radius: 60,
                    child: studentProfile?.profilePicture != null &&
                        studentProfile!.profilePicture!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        studentProfile!.profilePicture!.startsWith('http')
                            ? studentProfile!.profilePicture!
                            : "http://192.168.1.64:5000/${studentProfile!.profilePicture!}",
                        width: 150,
                        height: 150,
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

                ),
                Text(
                  studentProfile?.fullName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  studentProfile?.email ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5,),
                const Divider(color: Colors.black, thickness: 0.5),
                // Student Details
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          icon: Icons.phone,
                          title: 'Phone Number',
                          value: studentProfile?.phoneNumber ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Date of Birth',
                          value: studentProfile?.dateOfBirth ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: studentProfile?.gender == 'Male' ? Icons.male : Icons.female,
                          title: 'Gender',
                          value: studentProfile?.gender ?? 'N/A',
                        ),

                        _buildProfileTile(
                          icon: Icons.home_outlined,
                          title: 'Address',
                          value: studentProfile?.address ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.school_outlined,
                          title: 'Program',
                          value: studentProfile?.enrolledProgramName ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.check_box_outlined,
                          title: 'Batch',
                          value: studentProfile?.batch ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.date_range_outlined,
                          title: 'Enrollment Date',
                          value: studentProfile?.enrollmentDate ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.book_outlined,
                          title: 'Semester',
                          value: studentProfile?.enrolledSemesterName ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Logout Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff323465),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
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
      children: [
        ListTile(
          leading: Icon(icon, color: Color(0xff323465),size: 25,),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value),
        ),
        const Divider(thickness: 1, color: Colors.grey),
      ],
    );
  }
}
