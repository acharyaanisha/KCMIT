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
        preferredSize: Size.fromHeight(60),
          child: AppBar(
            title: const Text('Student Profile'),
            centerTitle: true,
            elevation: 0,

            // actions: [
            //   IconButton(onPressed: (){
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => EditProfile()),
            //     );
            //   }, icon: Icon(Icons.edit)),
            // ],

          ),
        ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff323465),
              Color(0xffC82025),
              ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
            padding: const EdgeInsets.all(20.0),
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
                            : "http://192.168.1.78:5000/${studentProfile!.profilePicture!}",
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  studentProfile?.email ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 5,),
                const Divider(color: Colors.white70, thickness: 0.5),
                // Student Details
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                        _buildProfileTile(
                          icon: Icons.calendar_today,
                          title: 'Date of Birth',
                          value: studentProfile?.dateOfBirth ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: studentProfile?.gender == 'Male' ? Icons.male : Icons.female,
                          title: 'Gender',
                          value: studentProfile?.gender ?? 'N/A',
                        ),

                        _buildProfileTile(
                          icon: Icons.home,
                          title: 'Address',
                          value: studentProfile?.address ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.school,
                          title: 'Program',
                          value: studentProfile?.enrolledProgramName ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.calendar_view_day,
                          title: 'Batch',
                          value: studentProfile?.batch ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.date_range,
                          title: 'Enrollment Date',
                          value: studentProfile?.enrollmentDate ?? 'N/A',
                        ),
                        _buildProfileTile(
                          icon: Icons.book,
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout,color: Colors.white,),
                  label: const Text("Log Out",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color(0xffC82025),
                    // backgroundColor:  Color(0xff323465),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
          leading: Icon(icon, color: Color(0xff323465),),
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
