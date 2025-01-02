import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/model/changePasswordModel/studentChangePassword.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';
import 'package:kcmit/view/studentScreen/studentToken.dart';
import 'package:provider/provider.dart';

class StudentChangePassword extends StatefulWidget {
  const StudentChangePassword({super.key});

  @override
  State<StudentChangePassword> createState() => _StudentChangePasswordState();
}

class _StudentChangePasswordState extends State<StudentChangePassword> {
  late StChangePassword stChangePassword;
  String errorMessage = '';
  bool isLoading = true;
  String? successMessage;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> authenticateUser(
      String oldPassword, String newPassword, String confirmPassword) async {
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
        successMessage = null;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = 'New password and confirmation do not match.';
        successMessage = null;
      });
      return;
    }

    final token = context.read<studentTokenProvider>().token;
    final url = Config.getStudentChangePassword();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      print("Response:${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          successMessage = 'Password changed successfully!';
          errorMessage = '';
          oldPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        });

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginAsStudent()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        setState(() {
          errorMessage = 'Failed to change password. Please try again.';
          successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while changing the password.';
        successMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Change Password"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Old password field
            Text(
              "Old Password",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 2),
            TextField(
              controller: oldPasswordController,
              obscureText: !_isOldPasswordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isOldPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // New password field
            Text(
              "New Password",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 2),
            TextField(
              controller: newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm new password field
            Text(
              "Confirm New Password",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 2),
            TextField(
              controller: confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error or success message display
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            if (successMessage != null)
              Text(successMessage!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),

            // Change Password Button
            Center(
              child: SizedBox(
                width: 200, // Adjust width here
                child: ElevatedButton(
                  onPressed: () {
                    authenticateUser(
                      oldPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                  },
                  child: Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xff323465),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
