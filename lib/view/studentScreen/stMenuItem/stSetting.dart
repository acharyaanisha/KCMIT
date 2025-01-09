import 'package:flutter/material.dart';
import 'package:kcmit/view/authentication/loginPage.dart';
import 'package:kcmit/view/Contact.dart';
import 'package:kcmit/view/rate.dart';
import 'package:kcmit/view/studentScreen/stSetting/stChangePassword.dart';
import 'package:kcmit/view/PrivacyPolicy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentSetting extends StatefulWidget {
  const StudentSetting({super.key});

  @override
  State<StudentSetting> createState() => _StudentSettingState();
}

class _StudentSettingState extends State<StudentSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Setting"),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildProfileButton(
                label: "Change Password ",
                icon: Icons.lock_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentChangePassword()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildProfileButton(
                label: "Privacy Policy ",
                icon: Icons.privacy_tip_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Policy()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildProfileButton(
                label: "Rate Us",
                icon: Icons.star_border_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Rate()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildProfileButton(
                label: "Contact Us",
                icon: Icons.phone,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Contact()),
                  );
                },
              ),

              SizedBox(height: 20),

              TextButton(
                onPressed: () async {

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('username');
                  await prefs.remove('password');
                  await prefs.setBool('keepLoggedIn', false);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                  child: Row(
                    children: [
                      Icon(Icons.logout,color: Color(0xff323465),),
                      SizedBox(width: 10,),
                      Text("Log Out",
                        style: TextStyle(
                            color: Color(0xff323465),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
              ),

              // ElevatedButton.icon(
              //   onPressed: () {
              //     Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const LoginPage(),
              //       ),
              //     );
              //   },
              //   icon: const Icon(
              //     Icons.logout,
              //     // Icons.logout,
              //     color: Color(0xffEE1B08),),
              //   label: const Text("Log Out",
              //     style: TextStyle(
              //         color: Color(0xffEE1B08)
              //     ),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor:  Colors.white,
              //     // backgroundColor:  Color(0xff323465),
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 50,
              //       vertical: 3,
              //     ),
              //     // shape: RoundedRectangleBorder(
              //     //   borderRadius: BorderRadius.circular(50),
              //     //   side: BorderSide.none,
              //     // ),
              //     textStyle: const TextStyle(
              //       fontSize: 16,
              //     ),
              //   ),
              // ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color:  Color(0xff323465)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color:  Color(0xff323465), size: 15),
          ],
        ),
      ),
    );
  }

}
