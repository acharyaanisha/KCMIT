import 'package:flutter/material.dart';
import 'package:kcmit/view/studentScreen/sauthentication/loginAsStudent.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {


  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
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


          SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.0),
                IconButton(
                  icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(
                        builder: (context)=>LoginAsStudent()
                    )
                    );
                  },
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(

                  ),
                ),
                SizedBox(height: 40.0),
                Text(
                  "Email",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 2),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Old Password",
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
                SizedBox(height: 10.0),
                Text(
                  "Confirm Password",
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
                SizedBox(height: 10.0),

                Center(
                  child: SizedBox(
                    width: 200, // Adjust width here
                    child: ElevatedButton(
                      onPressed: () {

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
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
    ]
      ),
    );
  }
}
