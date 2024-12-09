import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/authenticateModel/facultyAuthenticateModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/parentScreen/pauthentication/loginAsParent.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:kcmit/view/teacherScreen/HomeMain.dart';
import 'package:kcmit/view/teacherScreen/ThomeScreen.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAsTeacher extends StatefulWidget {
  const LoginAsTeacher({super.key});

  @override
  State<LoginAsTeacher> createState() => _LoginAsTeacherState();
}

class _LoginAsTeacherState extends State<LoginAsTeacher> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;


  Future<void> authenticateStudent(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
        successMessage = null;
      });
      return;
    }

    final url = Config.getFaculty();
    print("Authenticating to URL: $url");

    final authenticateRequest = Faculty(email: username, password: password);
    print("Sending payload: ${jsonEncode(authenticateRequest.toJson())}");

    setState(() {
      errorMessage = null;
      successMessage = null;
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(authenticateRequest.toJson()),
      );

      print("Response body:${response.body}");

      // if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print("response:$responseBody");
      final String token = responseBody['token'];
      context.read<facultyTokenProvider>().setToken(token);



      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      print("Token:${token}");

      setState(() {
        successMessage = 'Login successful!';
        errorMessage = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FactHomeMain()),
      );
      // }
      // else {
      //   setState(() {
      //     errorMessage = 'Login failed. Please try again.';
      //   });
      // }
    } catch (e) {
      print("${e}");
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
        successMessage = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: Image.asset('assets/KCMIT.png'),
              ),
            ),
            SizedBox(height: 40.0),
            _buildTextField(
              controller: usernameController,
              label: 'Enter email',
              isPassword: false,
            ),
            SizedBox(height: 10.0),
            _buildTextField(
              controller: passwordController,
              label: 'Your Password',
              isPassword: true,
            ),
            SizedBox(height: 20.0),
            _buildLoginButton(),
            SizedBox(height: 10.0),
            _buildLoginAsStudent(),
            _buildLoginAsParent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        )
            : null,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          authenticateStudent(usernameController.text, passwordController.text);
        },

        child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 15),),
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

  Widget _buildLoginAsStudent() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAsStudent()),
              );
            },
            child:  Text("Login as Student?"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginAsParent() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAsParent()),
              );
            },
            child: Text("Login as Parent?"),
          ),
        ],
      ),
    );
  }

}

