import 'package:flutter/material.dart';
import 'package:flutter_bs_ad_calendar/flutter_bs_ad_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? selectedDate;

  void onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
    });
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

            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: onDateChanged,
            ),

        // Container(
        //   height: 385,
        //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //   child: FlutterBSADCalendar(
        //     initialDate: DateTime.now(),
        //     firstDate: DateTime(1990),
        //     lastDate: DateTime(2090),
        //     onMonthChanged: (date, events) {
        //       setState(() {
        //         selectedDate = date;
        //       });
        //     },
        //     onDateSelected: (date, events) {
        //       setState(() {
        //         selectedDate = date;
        //       });
        //     },
        //     todayDecoration: BoxDecoration(
        //       borderRadius: BorderRadius.all(Radius.circular(2)),
        //       border: Border.all(color: Colors.blueAccent),
        //       color: Colors.lightBlue.withOpacity(0.3),
        //     ),
        //     selectedDayDecoration: BoxDecoration(
        //       borderRadius: BorderRadius.all(Radius.circular(2)),
        //       border: Border.all(color: Colors.black),
        //       color: Color(0xff456b9d),
        //     ),
        //     weekendDays: const [DateTime.saturday],
        //     holidayColor: Colors.red,
        //     eventColor: Colors.blue,
        //   ),
        // ),

          ],
        ),
      ),
    );
  }
}
