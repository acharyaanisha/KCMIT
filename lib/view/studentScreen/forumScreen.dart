import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kcmit/view/studentScreen/postThread.dart';
import 'package:kcmit/view/studentScreen/threadCommentView.dart';
import 'package:provider/provider.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';

class Forumscreen extends StatefulWidget {
  const Forumscreen({super.key});

  @override
  State<Forumscreen> createState() => _ForumscreenState();
}

class _ForumscreenState extends State<Forumscreen> {
  List<dynamic> threadList = [];
  String? errorMessage;
  String? successMessage;
  // String errorMessage = '';
  bool isLoading = true;

  final TextEditingController commentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String selectedSemester = '';
  // Timer? _timer;


  // void _startTimer() {
  //
  //   _timer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
  //     _refreshData();
  //   });
  // }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchThreads();
    });
  }


  @override
  void initState() {
    super.initState();
    fetchThreads();
  }

  Future<void> fetchThreads() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getThreadView();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Thread:${response.body}");

      if (response.statusCode == 201) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          threadList = jsonResponse['data'];
          errorMessage = '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load threads: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Future<void> postComment(String threadId) async {
  //   final token = context.read<studentTokenProvider>().token;
  //   final url = Config.getThreadComment();
  //   final commentText = commentController.text.trim();
  //
  //   if (commentText.isNotEmpty) {
  //     try {
  //       final response = await http.post(
  //         Uri.parse(url),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $token',
  //         },
  //         body: jsonEncode({
  //           'thread': threadId,
  //           'comment': commentText,
  //         }),
  //       );
  //
  //       if (response.statusCode == 201) {
  //         setState(() {
  //           commentController.clear();
  //         });
  //         fetchThreads();
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to post comment: ${response.statusCode}')),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error posting comment: $e')),
  //       );
  //     }
  //   }
  // }


  Future<void> postLike(String threadId) async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getThreadLike();

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

          fetchThreads();
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


  // Future<void> postThread(String title, String content,) async {
  //   final token = context.read<studentTokenProvider>().token;
  //   final url = Config.getThreadPost();
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         'title': title,
  //         'content': content,
  //       }),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       fetchThreads();
  //       titleController.clear();
  //       contentController.clear();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to post thread: ${response.statusCode}')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error posting thread: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
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
        ),child: const Center(child: Text('No threads available')))
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
                    MaterialPageRoute(builder: (context) => ThreadCommentView(threaduuid: threaduuid,)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3.5),
                  // padding: const EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0,bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),

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
                                            MaterialPageRoute(builder: (context) => ThreadCommentView(threaduuid: threaduuid,)),
                                          );
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
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => PostThread())
          );
        },
        backgroundColor: Color(0xff323465),
        child:  Icon(Icons.add,size: 40,color: Colors.white,),
      ),
    );
  }
}
