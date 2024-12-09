import 'package:flutter/material.dart';
import 'package:kcmit/view/parentScreen/pauthentication/loginAsParent.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:kcmit/view/teacherScreen/tauthentication/loginAsTeacher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showButtons = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffa4c3e3),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Container(
                    height: 300,
                    child: Center(
                      child: Image.asset(
                        'assets/college-students.png',
                        height: 750.0,
                        width: 550.0,
                        // fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _showButtons ? 1.0 : 0.0,
              child: Visibility(
                visible: _showButtons,
                child: Container(
                  height: 450,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 15,),
                      Text("KCMIT-A pioneer BIM college of Kathmandu",style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20,),
                      Text("Leading college in Kathmandu offering Bachelor of Information Management(BIM), Business Administration (BBA), and Computer Application(BCA)-top education in Nepal",style: TextStyle(
                        fontSize: 14,
                      ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50.0),
                      _buildLoginButtonForTeacher(),
                      SizedBox(height: 15.0),
                      _buildLoginButtonForStudent(),
                      SizedBox(height: 15.0),
                      _buildLoginButtonForParent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButtonForTeacher() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginAsTeacher()),
          );
        },
        child: Text(
          'Login as Faculty',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2263A9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildLoginButtonForStudent() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginAsStudent()),
          );
        },
        child: Text(
          'Login as Student',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff588cd0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildLoginButtonForParent() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginAsParent()),
          );
        },
        child: Text(
          'Login as Parent',
          style: TextStyle(color: Color(0xff588cd0), fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          side: BorderSide(color: Color(0xff588cd0),style: BorderStyle.solid),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}
