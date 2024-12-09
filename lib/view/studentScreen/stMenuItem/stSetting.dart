import 'package:flutter/material.dart';
import 'package:kcmit/view/authentication/loginPage.dart';
import 'package:kcmit/view/studentScreen/stMenuItem/stContact.dart';
import 'package:kcmit/view/studentScreen/stSetting/stChangePassword.dart';
import 'package:kcmit/view/PrivacyPolicy.dart';

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
              SizedBox(height: 40),
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
              SizedBox(height: 40),
              _buildProfileButton(
                label: "Rate Us",
                icon: Icons.star_rate_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentChangePassword()),
                  );
                },
              ),
              SizedBox(height: 40),
              _buildProfileButton(
                label: "Contact Us",
                icon: Icons.contacts_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentContact()),
                  );
                },
              ),

              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  // Icons.logout,
                  color: Colors.white,),
                label: const Text("Log Out",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.black,
                  // backgroundColor:  Color(0xff323465),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

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
                Icon(icon, color: Colors.black),
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
            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 15),
          ],
        ),
      ),
    );
  }

}
