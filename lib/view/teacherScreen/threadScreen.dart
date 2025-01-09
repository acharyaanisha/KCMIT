import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/commentThreadModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/teacherScreen/facThreadPost.dart';
import 'package:kcmit/view/teacherScreen/facultyThreadComment.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';

class ThreadScreen extends StatefulWidget {
  final String uuid;

  const ThreadScreen({super.key, required this.uuid});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {

  List<dynamic> threadList = [];
  // CommentThreadModel? commentThread;
  String? errorMessage;
  String? successMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewThread();

  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      viewThread();
    });
  }

  Future<void> viewThread() async {
    final token = context.read<facultyTokenProvider>().token;
    final requestBody = jsonEncode({'semester': widget.uuid});
print("UUID:${widget.uuid}");
    final url = Config.getThread();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        print("response:${jsonResponse}");
        setState(() {
          threadList = jsonResponse['data'];
          errorMessage = '';
          isLoading = false;
        });
        // print("Comments fetched: $jsonResponse");
      } else {
        setState(() {
          errorMessage = '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching comments: $e';
        isLoading = false;
      });
    }
  }

  Future<void> postLike(String threadId) async {
    final token = context.read<facultyTokenProvider>().token;
    final url = Config.getThreadLikeFaculty();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'thread': threadId,
        }),
      );

      print("Like id:${response.body}");

      if (response.statusCode == 201) {
        setState(() {
          viewThread();
        });
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Login failed. Please try again.'),)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
          child: AppBar(
            elevation: 5,
            title: const Text(
              "Threads",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Container(decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),

            ),
            color: Colors.white
        ),child: const Center(child: CircularProgressIndicator()))
            : threadList.isEmpty
            ? Container(decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),

            ),
            color: Colors.white
        ),
            child: Container(
            height: MediaQuery.of(context).size.height*0.9,
          width: MediaQuery.of(context).size.width,
          child: Image.asset('assets/no_data.png')
      )
        )

            : Padding(
          // padding: const EdgeInsets.all(0.0),
          padding: const EdgeInsets.only(left: 0.0,top: 0,bottom: 2),
          child: ListView.builder(
            itemCount: threadList.length,
            itemBuilder: (context, index) {
              final thread = threadList[index];
              String threaduuid = thread['uuid'];
              print("UUID:$threaduuid");

              return GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FacultyThreadCommentView(threaduuid: threaduuid,)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3.5),
                  // padding: const EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0,bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                          // bottom: BorderSide(color: Colors.grey, width: 0.5),

                        ),
                        color: Colors.white
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0,bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                child: ClipOval(
                                  child: Image.network(
                                    // "http://192.168.1.78:5000/${thread['author']['profilePicture']} ?? http://192.168.1.78:5000/${thread['author']['profile_pic']}",
                                    "http://kcmit-api.kcmit.edu.np/${thread['author']['profilePicture'] ?? thread['author']['profile_pic']}",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) => Center(child: const Icon(Icons.person_outlined,)),
                                  ),
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${thread['author']['fullName'] ?? thread['author']['name']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.0015,),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0.0),
                                          // padding: const EdgeInsets.only(left: 45.0),
                                          child: Container(
                                            // height: MediaQuery.of(context).size.height*0.028,
                                            width: MediaQuery.of(context).size.width*0.13,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey, width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.transparent,
                                              // color: Color(0xff323465),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 2,bottom: 2),
                                              child: Center(
                                                child: Text(
                                                  '${thread['postedBy'].toString().toLowerCase()}',
                                                  style: const TextStyle(fontSize: 9,color: Colors.grey,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),

                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.015,),
                                        Text(
                                          // 'Date Time',
                                          '${thread['postedAt']}',
                                          style: const TextStyle(fontSize: 9,color: Colors.grey,fontWeight: FontWeight.bold),

                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                            ],
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height*0.015),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread['title'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.003),
                                Text(
                                  thread['content'],
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.015),
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.15,
                                      height: MediaQuery.of(context).size.height * 0.035,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.transparent,
                                        // color: Color(0xff323465),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          postLike(threaduuid);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,                                               mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.thumb_up_outlined,
                                                  size: 15,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                                                Text(
                                                  '${thread['likeCount']}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 10,),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.15,
                                      height: MediaQuery.of(context).size.height * 0.035,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.transparent,
                                        // color: Color(0xff323465),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => FacultyThreadCommentView(threaduuid: threaduuid,)),
                                          ).then((shouldRefresh) {
                                            if (shouldRefresh == true) {
                                              viewThread();
                                            }
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,                                               mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.comment_outlined,
                                                  size: 15,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                                                Text(
                                                  '${thread['commentCount']}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostThreadFaculty(uuid: '${widget.uuid}',)),
          ).then((shouldRefresh) {
            if (shouldRefresh == true) {
              viewThread();
            }
          });
        },
        backgroundColor: Color(0xff323465),
        child:  Icon(Icons.add,size: 40,color: Colors.white,),
      ),
    );
  }
}
