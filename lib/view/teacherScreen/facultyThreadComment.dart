import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kcmit/model/commentThreadModel.dart';
import 'package:kcmit/model/viewCommentModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class FacultyThreadCommentView extends StatefulWidget {
  final String threaduuid;
  const FacultyThreadCommentView({super.key, required this.threaduuid});

  @override
  State<FacultyThreadCommentView> createState() => _FacultyThreadCommentViewState();
}

class _FacultyThreadCommentViewState extends State<FacultyThreadCommentView> {
  final TextEditingController commentController = TextEditingController();

  List<Comment> commentList = [];
  CommentThreadModel? commentThread;
  String? errorMessage;
  String? successMessage;
  bool isLoading = true;
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    viewThread();
    viewComment();
  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      viewThread();
    });
  }

  Future<void> postComment(String threadId) async {

    setState(() {
      isPosting = true;
    });

    final token = context.read<facultyTokenProvider>().token;
    final url = Config.getThreadCommentFac();
    final commentText = commentController.text.trim();

    if (commentText.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'thread': threadId,
            'comment': commentText,
          }),
        );

        final responseBody = jsonDecode(response.body);
        if (response.statusCode == 201) {
          setState(() {
            commentController.clear();
            viewComment();
            viewThread();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Failed to post comment: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: $e')),
        );
      }
      finally {
        setState(() {
          isPosting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
    }
  }

  Future<void> viewThread() async {
    final token = context.read<facultyTokenProvider>().token;
    final requestBody = jsonEncode({'thread': widget.threaduuid});

    print("UUID: ${widget.threaduuid}");
    print("Request Body: $requestBody");

    final url = Config.getThreadViewComment();
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          commentThread = CommentThreadModel.fromJson(jsonResponse['data']);
          print("Comments fetched: $jsonResponse");
          errorMessage = '';
          isLoading = false;
        });
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Please try again.';
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

  Future<void> viewComment() async {
    final token = context.read<facultyTokenProvider>().token;
    final requestBody = jsonEncode({'thread': widget.threaduuid});

    final url = Config.getThreadCommentViewFac();
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        // print("Comments fetched: $jsonResponse");
        setState(() {
          commentList = (jsonResponse['data'] as List)
              .map((item) => Comment.fromJson(item))
              .toList();
          errorMessage = '';
          isLoading = false;
          viewThread();
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
    if (commentThread == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            // bottom: Radius.circular(30),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                  // color: Colors.grey
                ),
                child: Column(
                  children: [
                    RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                              // bottom: BorderSide(color: Colors.grey, width: 0.3),
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
                                        "http://kcmit-api.kcmit.edu.np/${commentThread?.authorDetails.profilePicture}",
                                        // "http://kcmit-api.kcmit.edu.np/${commentThread.authorDetails.profilePicture ?? commentThread.authorDetails.profile_pic}",
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
                                          '${commentThread?.authorDetails.fullName}',
                                          // '${commentThread.authorDetails.fullName ?? commentThread.authorDetails.name}',
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
                                                      '${commentThread?.postedBy.toString().toLowerCase()}',
                                                      style: const TextStyle(fontSize: 9,color: Colors.grey,fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),

                                              ),
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width*0.015,),
                                            Text(
                                              // 'Date Time',
                                              '${commentThread?.postedAt}',
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
                                      commentThread!.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.003),
                                    Text(
                                      commentThread!.content,
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
                                              postLike(widget.threaduuid);
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
                                                      '${commentThread!.likeCount}',
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
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(builder: (context) => ThreadCommentView(threaduuid: threaduuid,)),
                                              // );
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
                                                      '${commentThread!.commentCount}',
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
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                    isLoading
                        ? Container(
                        decoration: BoxDecoration(
                          border: Border(
                            // bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          color: Colors.white,
                        ),
                        child: const Center(child: CircularProgressIndicator()))
                        : commentList.isEmpty
                        ? Center(
                      child: Container(
                          height: MediaQuery.of(context).size.height*0.6,
                          color: Colors.white,
                          child: const Center(child: Text('Be first to post comment.'))
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(left: 0.0,top: 0,bottom: 2),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentList.length,
                        itemBuilder: (context, index) {
                          final comment = commentList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5,),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                    // bottom: BorderSide(color: Colors.grey, width: 0.5),
                                  ),
                                  color: Colors.white
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0,left: 15.0,right: 10.0,bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.author,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      comment.comment,
                                      maxLines: 5,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.parse('${comment.createdAt}')),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height*0.085,
            padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 8),
                    TextButton(
                    onPressed: isPosting
                      ? null
                          : () => postComment(widget.threaduuid),
                      child: Icon(
                      Icons.send_rounded,
                      color: isPosting ? Colors.grey : Color(0xff323465),
                      size: 30,
                      ),
                    )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
