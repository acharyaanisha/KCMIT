import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  DateTime? selectedDate;
  List<dynamic> _events = [];
  List<dynamic> filteredEvents = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventData();
    selectedDate = DateTime.now();
    filterEvents();
  }

  Future<void> fetchEventData() async {
    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStudentEvent();
    print('Fetching data from $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("Events: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _events = jsonResponse['data'];
          filterEvents(); // Update filtered events after fetching data
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data.');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterEvents() {
    if (selectedDate == null) {
      setState(() {
        filteredEvents = [];
      });
      return;
    }

    int selectedMonth = selectedDate!.month;
    int selectedYear = selectedDate!.year;

    setState(() {
      filteredEvents = _events.where((event) {
        DateTime eventDate = DateTime.parse(event['eventDate']);
        return eventDate.month == selectedMonth && eventDate.year == selectedYear;
      }).toList();
    });
  }

  void onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      filterEvents(); // Update filtered events when date changes
    });
  }

  void _showDialog(String? eventPoster, String name, String description, String location, String eventTime, String eventDate) {
    print("Image URL: $eventPoster");
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
                if (eventPoster != null && eventPoster.isNotEmpty)
                  Image.network(
                    eventPoster.startsWith('http')
                        ? eventPoster
                        : "http://kcmit-api.kcmit.edu.np/$eventPoster",
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
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
                Text(description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                if (location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(location, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(eventDate, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(eventTime, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),
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
    print("Image:${'http://kcmit-api.kcmit.edu.np/$eventPoster'}");
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
            title: const Text("Academic Calendar"),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: onDateChanged,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'No Events Found',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return GestureDetector(
                          onTap: () {
                            _showDialog(
                              event['eventPoster'],
                              event['name'],
                              event['description'],
                              event['location'],
                              event['eventTime'],
                              event['eventDate'],
                            );
                          },
                          child: Card(
                            elevation: 5,
                            color: Colors.grey.shade50,
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(event['name']),
                              subtitle: Text(
                                "Date: ${event['eventDate']}\n"
                                    "Time: ${event['eventTime']}\n"
                                    "Location: ${event['location']}",
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


