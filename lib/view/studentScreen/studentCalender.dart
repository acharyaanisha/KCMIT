import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {

  DateTime focusedDay = DateTime.now();
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
          filterEvents();
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
      filterEvents();
    });
  }

  void _showDialog(String? eventPoster, String name, String description, String? location, String? eventTime, String eventDate) {
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
                        : "http://kcmit-api.kcmit.edu.np:5000/$eventPoster",
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
                if (location != null && location.isNotEmpty)
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
                if (eventTime != null && eventTime.isNotEmpty)
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      this.selectedDate = selectedDay;
                      this.focusedDay = focusedDay;
                    });

                    final eventsForDay = filteredEvents.where((event) {
                      DateTime eventStartDate = DateTime.parse(event['eventDate']);
                      DateTime? eventEndDate = event['eventEndDate'] != null
                          ? DateTime.parse(event['eventEndDate'])
                          : eventStartDate;

                      return selectedDay.isAfter(eventStartDate) &&
                          selectedDay.isBefore(eventEndDate.add(const Duration(days: 1)));
                    }).toList();

                    if (eventsForDay.isNotEmpty) {
                      final firstEvent = eventsForDay.first;
                      _showDialog(
                        firstEvent['eventPoster'],
                        firstEvent['name'],
                        firstEvent['description'],
                        firstEvent['location'],
                        firstEvent['eventTime'],
                        firstEvent['eventDate'],
                      );
                    }
                    filterEvents();

                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      this.focusedDay = focusedDay;
                      this.selectedDate = focusedDay;
                    });
                    filterEvents();
                  },
                  eventLoader: (day) {
                    return filteredEvents.where((event) {
                      DateTime eventDate = DateTime.parse(event['eventDate']);
                      return isSameDay(day, eventDate);
                    }).toList();
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.rectangle,
                    ),
                    selectedDecoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(color: Color(0xff323465))
                    ),
                    defaultTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      for (var event in filteredEvents) {
                        DateTime eventStartDate = DateTime.parse(event['eventDate']);
                        DateTime? eventEndDate = event['eventEndDate'] != null
                            ? DateTime.parse(event['eventEndDate'])
                            : eventStartDate;

                        if (date.isAfter(eventStartDate) &&
                            date.isBefore(eventEndDate.add(const Duration(days: 1)))) {
                          String eventCategory = event['eventCategory']['name'];
                          Color markerColor;


                          switch (eventCategory) {
                            case 'Holiday':
                              markerColor = Colors.red;
                              break;
                            case 'Examination':
                              markerColor = Colors.green;
                              break;
                            case 'Sports':
                              markerColor = Colors.blue;
                              break;
                            case 'Academic & Professional Development':
                              markerColor = Colors.orange;
                              break;
                            default:
                              markerColor = Colors.cyan;
                          }

                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                )

            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.001,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text("Events",style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(left: 15.0,top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'No events found.',
                          style: TextStyle(fontSize: 12),
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
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Event name
                                    Text(
                                      event['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),

                                    // Event date
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month_outlined, size: 20),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                        Text("${event['eventDate']}"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),

                                    if (event['eventTime'] != null && event['eventTime']!.isNotEmpty)
                                      Row(
                                        children: [
                                          Icon(Icons.timer_outlined, size: 20),
                                          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                          Text(" ${event['eventTime']}"),
                                        ],
                                      ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.01,
                                    ),

                                    if (event['location'] != null && event['location']!.isNotEmpty)
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 20),
                                          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                          Text("${event['location']}"),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            )


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
