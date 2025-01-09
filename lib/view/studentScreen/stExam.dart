import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';

class StudentResut extends StatefulWidget {
  const StudentResut({super.key});

  @override
  State<StudentResut> createState() => _StudentResutState();
}

class _StudentResutState extends State<StudentResut> {
  String errorMessage = '';
  bool isLoading = true;
  List<dynamic> examRoutineList = [];

  @override
  void initState() {
    super.initState();
    fetchExamRoutine();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    fetchExamRoutine();
  }

  Future<void> fetchExamRoutine() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getExam();
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
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
            examRoutineList = jsonResponse['data'];
            errorMessage = '';
          } else {
            errorMessage = 'Invalid data format received.';
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load resources. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data. Error: $e';
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
            title: const Text("Exam Schedule"),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchExamRoutine,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: examRoutineList.isNotEmpty
                      ? DataTable(
                    headingRowHeight: 50,
                    dataRowHeight: MediaQuery.of(context).size.height * 0.08,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Subject',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                    rows: examRoutineList
                        .where((examResult) =>
                    examResult is Map &&
                        examResult.containsKey('examDate') &&
                        examResult.containsKey('subject'))
                        .map((examResult) {
                      final examDate = examResult['examDate'] ?? 'N/A';
                      final subject = examResult['subject'] ?? 'N/A';
                      return DataRow(cells: [
                        DataCell(Text(
                          examDate,
                          style: const TextStyle(fontSize: 12),
                        )),
                        DataCell(Text(
                          subject,
                          style: const TextStyle(fontSize: 12),
                        )),
                      ]);
                    }).toList(),
                  )
                      :  Container(
                      height: MediaQuery.of(context).size.height*0.8,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset('assets/no_data.png')
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
