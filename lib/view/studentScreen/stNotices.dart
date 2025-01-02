import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class StudentNotices extends StatefulWidget {
  const StudentNotices({super.key});

  @override
  State<StudentNotices> createState() => _StudentNoticesState();
}

class _StudentNoticesState extends State<StudentNotices> {

  List<dynamic> noticeList = [];
  String errorMessage = '';
  bool isLoading = true;
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    fetchNoticeList();
  }


  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchNoticeList();
    });
  }
  Future<void> fetchNoticeList() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStNotices();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          noticeList = jsonResponse['data'];
          _isExpandedList = List.filled(noticeList.length, false);
          errorMessage = '';
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
        errorMessage = 'Failed to load data.';
        print("Error: $e");
        isLoading = false;
      });
    }
  }

  void _showImageDialog(String fileUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 1.0,
            maxScale: 5.0,
            child: Image.network(
              fileUrl.startsWith('http')
                  ? fileUrl
                  : "http://46.250.248.179:5000/$fileUrl",
              fit: BoxFit.contain,
              // height: MediaQuery.of(context).size.height*0.5,
              // width: MediaQuery.of(context).size.width*0.5,
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
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Notices"),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Center(
            child: Column(
                children: [
                if (isLoading)
            Center(child: const CircularProgressIndicator()),
            if (errorMessage.isNotEmpty)
            Padding(
            padding: const EdgeInsets.only(top: 130.0),
            child: Image.asset(errorMessage),
            // child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ),
            if (!isLoading && noticeList.isNotEmpty)SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    itemCount: noticeList.length,
                    itemBuilder: (context, index) {
                      final noticeItem = noticeList[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpandedList[index] = !_isExpandedList[index];
                          });
                        },
                        child: Padding(
                          padding:  EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0),
                          child: Card(
                            color: Colors.grey.shade50,
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    noticeItem['title'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 17,),
                                      SizedBox(width: 5,),
                                      Text(
                                        noticeItem['date'],
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _isExpandedList[index]
                                        ? noticeItem['desc']
                                        : noticeItem['desc'],
                                    maxLines: _isExpandedList[index] ? null : 2,
                                    overflow: _isExpandedList[index] ? TextOverflow.visible : TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black
                                    ),

                                  ),

                                  SizedBox(height: 5,),
                                  _isExpandedList[index]?Row(
                                    children: [
                                      GestureDetector(
                                        onTap:(){
                                          _showImageDialog(noticeItem['fileURL']);
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.network(
                                            noticeItem['fileURL'] != null && noticeItem['fileURL'].startsWith('http')
                                                ? noticeItem['fileURL']
                                                : "http://46.250.248.179:5000/${noticeItem['fileURL'] ?? ''}",
                                            width: 330,
                                            // height: 350,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text("");
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ):
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: 0,
                                    ),
                                  ) ,
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
            ],
          ),
        ),
            ]
            ),
        ),
      )
    );
  }

}

class NoticeDetail extends StatelessWidget {
  final Map<String, dynamic> noticeItem;

  const NoticeDetail({Key? key, required this.noticeItem}) : super(key: key);

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
            title: Text(
              noticeItem['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Notice Description
                Text(
                  noticeItem['desc'],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          noticeItem['fileURL'] != null && noticeItem['fileURL'].startsWith('http')
                              ? noticeItem['fileURL']
                              : "http://46.250.248.179:5000/${noticeItem['fileURL'] ?? ''}",
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            );
                          },
                        ),
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
  }
}


