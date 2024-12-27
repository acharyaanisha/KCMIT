import 'package:flutter/material.dart';
import 'package:kcmit/view/Calendar.dart';
import 'package:kcmit/view/studentScreen/StHomeScreen.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stMenu.dart';

class StHomeMain extends StatefulWidget {
  const StHomeMain({Key? key}) : super(key: key);

  @override
  State<StHomeMain> createState() => _StHomeMainState();
}

class _StHomeMainState extends State<StHomeMain> {
  int _selectedIndex = 0;

  // List of Pages
  final List<Widget> _pages = [
    StHomeScreen(),
    CalendarScreen(),
    StudentMenu(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 30,left: 40,right: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Color(0xff323465),
              // selectedItemColor: Colors.blue,
              unselectedItemColor:  Color(0xff323465),
              selectedIconTheme: IconThemeData(
                color: Color(0xff323465),
                // color: Colors.blue,
                size: 30,
              ),
              unselectedIconTheme: IconThemeData(
                color:  Color(0xff323465),
                size: 25,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined,),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu,),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


