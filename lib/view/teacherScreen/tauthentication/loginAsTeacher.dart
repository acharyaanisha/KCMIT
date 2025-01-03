import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/authenticateModel/facultyAuthenticateModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/parentScreen/pauthentication/loginAsParent.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:kcmit/view/teacherScreen/HomeMain.dart';
import 'package:kcmit/view/teacherScreen/facultyToken.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAsTeacher extends StatefulWidget {
  final bool isLoggedOut;
  const LoginAsTeacher({super.key,this.isLoggedOut= false});

  @override
  State<LoginAsTeacher> createState() => _LoginAsTeacherState();
}

class _LoginAsTeacherState extends State<LoginAsTeacher> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _firebaseMessaging = FirebaseMessaging.instance;

  bool isPasswordVisible = false;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;
  bool keepLoggedIn = false;


  @override
  void initState() {
    super.initState();
    if (!widget.isLoggedOut) {
      _loadLoginPreferences();
    }
  }

  Future<void> _loadLoginPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
      if (keepLoggedIn) {
        usernameController.text = prefs.getString('username') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> subscribeToRoleBasedTopics(String token) async {
    try {
      String role = await context.read<facultyTokenProvider>().getRoleFromToken(token);

      if (role.isNotEmpty) {
        print("Subscribing to topic: $role");
        await _firebaseMessaging.subscribeToTopic(role);
      } else {
        print("Unexpected role format: $role (type: ${role.runtimeType})");
      }
    } catch (e) {
      print("Error subscribing to topics: $e");
    }
  }

  Future<void> authenticateTeacher(String username, String password) async {
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

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);
        print("response: $responseBody");

        final String token = responseBody['token'];
        context.read<facultyTokenProvider>().setToken(token);
        context.read<facultyTokenProvider>().getRoleFromToken(token);
        await subscribeToRoleBasedTopics(token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (keepLoggedIn) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('password', password);
          await prefs.setBool('keepLoggedIn', true);
          await prefs.setString('token', token);
        }

        print("Token: $token");

        setState(() {
          successMessage = 'Login successful!';
          errorMessage = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FactHomeMain()),
        );
      } else {

        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Login failed. Please try again.';
          successMessage = null;
        });
      }
    } catch (e) {
      print("$e");
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
      body:Stack(
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
            SizedBox(height: 200.0),
            _buildWelcomeText(),
            SizedBox(height: 40.0),
            _buildTextField(
              controller: usernameController,
              label: 'Enter email',
              isPassword: false,
            ),
            SizedBox(height: 20.0),
            _buildTextField(
              controller: passwordController,
              label: 'Your Password',
              isPassword: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            if (successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  successMessage!,
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            SizedBox(height: 20.0),
            _buildLoginOptions(),
            SizedBox(height: 20.0),
            _buildLoginButton(),
            SizedBox(height: 10.0),
            _buildLoginAsStudent(),
            // _buildLoginAsParent(),
          ],
        ),
      ),
      ]
    ),
    );
  }


  Widget _buildLoginOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: keepLoggedIn,
              onChanged: (bool? value) {
                setState(() {
                  keepLoggedIn = value ?? false;
                });
              },
            ),
            const Text('Keep Login'),
          ],
        ),
        // TextButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => ForgetPassword()),
        //     );
        //   },
        //   child: const Text(
        //     'Reset password?',
        //     style: TextStyle(color: Color(0xff323465)),
        //   ),
        // ),
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
        onPressed: isLoading
            ? null
            : () {
          authenticateTeacher(usernameController.text, passwordController.text);
        },
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff323465),
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
            child: Text("Login as Student?"),
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
}
