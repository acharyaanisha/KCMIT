import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final bool isLoggedOut;
  const LoginAsStudent({super.key, this.isLoggedOut= false});

  @override
  State<LoginAsStudent> createState() => _LoginAsStudentState();
}

class _LoginAsStudentState extends State<LoginAsStudent> {
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

  Future<void> subscribeToRoleBasedTopics(String token) async {
    try {
      List<String> roles = await context.read<studentTokenProvider>().getRoleFromToken(token);

      for (String role in roles) {
        await _firebaseMessaging.subscribeToTopic(role);
        print("Subscribed to topic: $role");
      }
    } catch (e) {
      print("Error subscribing to topics: $e");
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

  Future<void> authenticateStudent(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
        successMessage = null;
      });
      return;
    }

    final url = Config.getStudent();
    print("Authenticating to URL: $url");

    final authenticateRequest = Student(email: username, password: password);
    // print("Sending payload: ${jsonEncode(authenticateRequest.toJson())}");

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

      // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);


        final String token = responseBody['token'];
        context.read<studentTokenProvider>().setToken(token);
        context.read<studentTokenProvider>().getRoleFromToken(token);
        await subscribeToRoleBasedTopics(token);
        // await subscribeToTopic(token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (keepLoggedIn) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('password', password);
          await prefs.setBool('keepLoggedIn', true);
          await prefs.setString('token', token);
        }


        // print("Token: $token");

        setState(() {
          successMessage = 'Login successful!';
          errorMessage = null;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StHomeMain()),
              (Route<dynamic> route) => false,
        );

        await saveLoginState(token);

      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Login failed. Please try again.';
          successMessage = null;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        if (e is http.ClientException || e.toString().contains("Failed host lookup")) {
          errorMessage = 'Server is down.';
        } else {
          errorMessage = 'An error occurred. Please try again later.';
        }
        successMessage = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveLoginState(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }


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
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    // child: Image.asset(
                    //   errorMessage!,
                    //   ),
                  ),
                if (successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 20.0),
                _buildLoginOptions(),
                const SizedBox(height: 20.0),
                _buildLoginButton(),
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
            fontSize: MediaQuery.of(context).size.width * 0.08,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 15),
        Text(
          '''Welcome Back,You've been missed!''',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.05,
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
}
