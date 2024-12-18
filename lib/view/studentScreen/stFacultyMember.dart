import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:url_launcher/url_launcher.dart';

class FacultyMemberList extends StatefulWidget {
  const FacultyMemberList({super.key});

  @override
  State<FacultyMemberList> createState() => _FacultyMemberListState();
}

class _FacultyMemberListState extends State<FacultyMemberList> {
  List<dynamic> memberList = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMemberList();
  }

  Future<void> fetchMemberList() async {
    final url = Config.getStFacultyMemberList();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      // print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          memberList = jsonResponse['faculties'];

          print("Member: $memberList");
          errorMessage = 'assets/no_data.png';
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
        errorMessage = 'assets/no_data.png';
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
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: const Text("Faculty Member"),
          ),
        ),
      ),
      body:
      isLoading
          ? Padding(
        padding: const EdgeInsets.all(100.0),
        child: const Center(child: CircularProgressIndicator()),
      )
          : memberList.isEmpty
          ? Center(
        child: errorMessage.isNotEmpty
            ? (errorMessage.contains('no_data.png')
            ? Image.asset(errorMessage)
            : Image.asset(errorMessage))
            : Image.asset(errorMessage),
      )   :
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            final member = memberList[index];
            return Card(
              color: Colors.white,
              elevation: 5,
              margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      radius: 50,
                      child: member['profile_pic'] != null &&
                          member['profile_pic'].isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          member['profile_pic']
                              .startsWith('http')
                              ? member['profile_pic']
                              : "http://46.250.248.179:5000/${member['profile_pic']}",
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
                    const SizedBox(height: 10),

                    Text(
                      member['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.cast_for_education_outlined),
                         SizedBox(width: 8),
                        Text(
                          member['qualification'] ?? 'N/A',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                     SizedBox(height: 5),

                    Text(
                      member['specialization'] ?? 'N/A',
                      style:  TextStyle(fontSize: 16),
                    ),
                     Divider(height: 15, color: Colors.grey),

                    Row(
                        mainAxisSize: MainAxisSize.max,
                      children: [
                         Icon(Icons.phone,
                             color: Colors.grey, size: 20),
                         SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            launch("tel:${member['mobileNumber']}");
                          },
                          child: Text(
                            member['mobileNumber'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),

                    Row(
                        mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.email,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            launch("mailto:${member['email']}");
                          },
                          child: Text(
                            member['email'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
