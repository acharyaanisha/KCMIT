import 'package:flutter/material.dart';

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({super.key});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {

  bool isPasswordVisible = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmationPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xffC82025),
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
                  decoration: const BoxDecoration(
                    color: Color(0xffC82025),
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
                    SizedBox(height: MediaQuery.of(context).size.height*0.04),
                    _buildTextField(
                      controller: fullNameController,
                      label: 'Full Name',
                      isPassword: false,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      isPassword: false,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    _buildTextField(
                      controller: phoneNumberController,
                      label: 'Contact Number',
                      isPassword: false,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Your Password',
                      isPassword: true,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    _buildTextField(
                      controller: confirmationPasswordController,
                      label: 'Confirm Your Password',
                      isPassword: true,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ]
        )
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
        onPressed:(){},
        style: ElevatedButton.styleFrom(
          backgroundColor:  Color(0xffC82025),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
        child:  Text(
          'Register',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.08,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        // Text(
        //   '''Welcome Back,You've been missed!''',
        //   style: TextStyle(
        //     fontSize: MediaQuery.of(context).size.width * 0.05,
        //     color: Colors.black,
        //   ),
        //   textAlign: TextAlign.justify,
        // ),
      ],
    );
  }
}
