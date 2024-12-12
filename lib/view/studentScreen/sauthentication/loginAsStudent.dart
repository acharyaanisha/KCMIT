import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kcmit/controller/loginController.dart';
import 'package:kcmit/model/authenticateModel/studentAuthenticateModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/authentication/forgetPassword.dart';
import 'package:kcmit/view/parentScreen/pauthentication/loginAsParent.dart';
import 'package:kcmit/view/studentScreen/HomeMain.dart';
import 'package:kcmit/view/teacherScreen/tauthentication/loginAsTeacher.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAsStudent extends StatefulWidget {
  const LoginAsStudent({super.key});

  @override
  State<LoginAsStudent> createState() => _LoginAsStudentState();
}

class _LoginAsStudentState extends State<LoginAsStudent> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top wave design
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xff323465),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
            ),
          ),
          // Bottom wave design
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // height: 120,
              decoration: const BoxDecoration(
                color: Color(0xff323465),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200.0),
                _buildWelcomeText(),
                const SizedBox(height: 40.0),
                _buildTextField(
                  controller: usernameController,
                  label: 'Enter email',
                  isPassword: false,
                ),
                const SizedBox(height: 20.0),
                _buildTextField(
                  controller: passwordController,
                  label: 'Your Password',
                  isPassword: true,
                ),
                const SizedBox(height: 20.0),
                _buildLoginOptions(),
                const SizedBox(height: 20.0),
                _buildLoginButton(),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 10.0),
                _buildLoginAsTeacher(),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          "Let's Sign in",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 15),
        Text(
          '''Welcome Back,You've been missed!''',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
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
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isPasswordVisible
              ? Icons.visibility
              : Icons.visibility_off),
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
        onPressed: isLoading
            ? null
            : () async {
          authenticateStudent(
            usernameController.text,
            passwordController.text,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff323465),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Sign in',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildLoginOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgetPassword()),
            );
          },
          child: const Text(
            'Reset password?',
            style: TextStyle(color: Color(0xff323465)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginAsTeacher() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAsTeacher()),
              );
            },
            child: const Text(
              "Login as Teacher?",
              style: TextStyle(color: Color(0xff323465)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> authenticateStudent(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
        successMessage = null;
      });
      return;
    }

    final url = Config.getStudent();
    final authenticateRequest = Student(email: username, password: password);

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        context.read<studentTokenProvider>().setToken(token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', 'student');

        setState(() {
          successMessage = 'Login successful!';
          errorMessage = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StHomeMain()),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ??
              'Login failed. Please try again.';
          successMessage = null;
        });
      }
    } catch (e) {
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
}
