import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kcmit/model/profileModel/facultyProfileModel.dart';
import 'package:kcmit/model/profileModel/parentProfile.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/parentScreen/parentTokenProvider.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen> {
  FacultyProfile? facultyProfile;
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final token = context.read<facultyTokenProvider>().token;
    final url = Config.getFacultyProfile();
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
          facultyProfile = FacultyProfile.fromJson(jsonResponse['data']);
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
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            // flexibleSpace: Container(
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Color(0xff264653), Color(0xff2a9d8f)],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //   ),
            // ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xff323465),
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple[100],
                        radius: 50,
                        child: facultyProfile?.profile_pic!= null &&
                            facultyProfile!.profile_pic.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            facultyProfile!.profile_pic
                                .startsWith('http')
                                ? facultyProfile!.profile_pic
                                : "http://46.250.248.179:5000/${facultyProfile!.profile_pic}",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  color: Color(0xff323465),
                                  size: 50);
                            },
                          ),
                        )
                            : const Icon(
                          Icons.person,
                          color: Color(0xff323465),
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        facultyProfile?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // color: Color(0xff323465),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InfoRow(
                        icon: Icons.cast_for_education_outlined,
                        label: facultyProfile?.qualification ?? 'N/A',
                      ),
                      InfoRow(
                        icon: Icons.cast_for_education_outlined,
                        label: facultyProfile?.specialization ?? 'N/A',
                      ),
                      InfoRow(
                        icon: Icons.phone,
                        label: facultyProfile?.mobileNumber ?? 'N/A',
                      ),
                      InfoRow(
                        icon: Icons.email,
                        label: facultyProfile?.email ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon,
            // color:Color(0xff323465)
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                // color: Color(0xff264653),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
