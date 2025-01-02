import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/resultModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class StudentResultScreen extends StatefulWidget {
  final String examSetupUuid;

  const StudentResultScreen({super.key, required this.examSetupUuid});

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {

  List<ExamResult> examResult = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResult();
  }

  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchResult();
    });
  }

  Future<void> fetchResult() async {
    final token = context.read<studentTokenProvider>().token;
    final requestBody = jsonEncode({'examSetupUuid': '${widget.examSetupUuid}'});
    // print("UUID:${widget.examSetupUuid}");
    print("UUID:${requestBody}");
    final url = Config.getResult();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      print("Response : ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          examResult = (jsonResponse['data'] as List)
              .map((item) => ExamResult.fromJson(item))
              .toList();

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
            title: Text("Result"),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0,left: 15,right: 15),
                child: Center(
                  child: DataTable(
                    // columnSpacing: 30,
                    headingRowHeight: 50,
                    dataRowHeight:MediaQuery.of(context).size.height*0.08,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    columns: const [
                      DataColumn(
                          label: Text('Subject',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14))),
                      DataColumn(
                          label: Text('Obtain\nMarks',
                              style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                      DataColumn(
                          label: Text('Remarks',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13))),
                    ],
                    rows: examResult.map((examResult) {
                      final subject = examResult.subject;
                      final obtainedMarks = examResult.obtainedMarks.toString();
                      final remarks = examResult.remarks;
                      return DataRow(cells: [
                        DataCell(Text(subject,style: TextStyle(fontSize: 12),)),
                        DataCell(Text(obtainedMarks,style: TextStyle(fontSize: 12),)),
                        DataCell(Text(remarks,style: TextStyle(fontSize: 12),)),
                      ]);
                    }).toList(),
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

