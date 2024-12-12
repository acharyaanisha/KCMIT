import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/authenticateModel/parentAuthenticateModel.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/parentScreen/paHomeMain.dart';
import 'package:kcmit/view/parentScreen/parentTokenProvider.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:kcmit/view/teacherScreen/tauthentication/loginAsTeacher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAsParent extends StatefulWidget {
  const LoginAsParent({super.key});

  @override
  State<LoginAsParent> createState() => _LoginAsParentState();
}

class _LoginAsParentState extends State<LoginAsParent> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  /// Function to authenticate a parent
  Future<void> authenticateParent(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
        successMessage = null;
      });
      return;
    }

    final url = Config.getParent();
    final authenticateRequest = Parent(email: username, password: password);

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

        context.read<parentTokenProvider>().setToken(token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', 'parent');

        setState(() {
          successMessage = 'Login successful!';
          errorMessage = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaHomeMain()),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Login failed. Please try again.';
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
            SizedBox(height: 10.0),
            _buildLoginAsStudent(),
            _buildLoginAsTeacher(),
          ],
        ),
      ),
    );
  }

  /// Build Text Field Widget
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

  /// Build Login Button Widget
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
          authenticateParent(usernameController.text, passwordController.text);
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

  /// Build "Login as Student" Widget
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

  /// Build "Login as Teacher" Widget
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
            child: Text("Login as Teacher?"),
          ),
        ],
      ),
    );
  }
}
