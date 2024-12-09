import 'package:flutter/material.dart';
import 'package:kcmit/view/Calendar.dart';
import 'package:kcmit/view/parentScreen/paHomeScreen.dart';
import 'package:kcmit/view/parentScreen/paSetting.dart';
import 'package:kcmit/view/studentScreen/StHomeScreen.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stMenu.dart';


class PaHomeMain extends StatefulWidget {

  const PaHomeMain({Key? key,}) : super(key: key);

  @override
  State<PaHomeMain> createState() => _PaHomeMainState();
}

class _PaHomeMainState extends State<PaHomeMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PaHomeScreen(),
      ParentSetting(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40),
        // padding: const EdgeInsets.only(bottom: 50,left: 10,right: 10),
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
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            selectedIconTheme: IconThemeData(
              // color: Color(0xff323465),
              color: Colors.blue,
              size: 30,
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.black,
              size: 25,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined,),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined,),
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
