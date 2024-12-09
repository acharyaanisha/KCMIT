import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
        context.read<studentTokenProvider>().setToken(token);


        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        print("Token:${token}");

        setState(() {
          successMessage = 'Login successful!';
          errorMessage = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StHomeMain()),
          // MaterialPageRoute(builder: (context) => StHomeScreen()),
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
    LoginController loginController = Get.put(LoginController());
    return Scaffold(
      body: Stack(
        children:[ SingleChildScrollView(
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
                // controller: loginController.username,
                label: 'Enter email',
                isPassword: false,
              ),
              SizedBox(height: 10.0),
              _buildTextField(
                controller: passwordController,
                // controller: loginController.password,
                label: 'Your Password',
                isPassword: true,
              ),
              SizedBox(height: 20.0),
              _buildLoginOptions(),
              SizedBox(height: 20.0),
              _buildLoginButton(),
              SizedBox(height: 10.0),
              _buildLoginAsTeacher(),
              _buildLoginAsParent()
            ],
          ),
        ),
    ]
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
        onPressed: isLoading ? null : () async{
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', usernameController.text);
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

  Widget _buildLoginOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgetPassword()),
            );
          },
          child: const Text('Forgot Password?'),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginAsTeacher()),
              );
            },
            child:  Text("Login as Teacher?"),
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
              Navigator.push(
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
