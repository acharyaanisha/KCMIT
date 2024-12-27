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
      print("Response: ${response.body}");

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

  void _showDialog(String? imageUrl, String name, String email, String mobileNumber, String qualification, String specialization) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  // member['profile_pic'].startsWith('http')
                  //     ? member['profile_pic']
                  //     :
                  "http://kcmit-api.kcmit.edu.np/$imageUrl",
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Center(child: const Icon(Icons.person_outlined,size: 100,)),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.cast_for_education_outlined),
                    const SizedBox(width: 8),
                    Text(
                      qualification,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined),
                    Expanded(
                      child: Text(
                        specialization,
                        maxLines: 5,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 15, color: Colors.grey),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        launch("tel:$mobileNumber");
                      },
                      child: Text(
                        mobileNumber,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        launch("mailto:$email");
                      },
                      child: Text(
                        email,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            final member = memberList[index];
            return GestureDetector(
              onTap: (){_showDialog(member['profile_pic'],member['name'],member['email'],member['mobileNumber'],member['qualification'],member['specialization']);},

              child: Card(
                color: Colors.grey.shade50,
                elevation: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        // member['profile_pic'].startsWith('http')
                        //     ? member['profile_pic']
                        //     :
                        "http://kcmit-api.kcmit.edu.np/${member['profile_pic']}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => Center(child: const Icon(Icons.person_outlined,size: 100,)),
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
                        child: Text(
                         member['name'],
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
      ),
    );
  }
}
