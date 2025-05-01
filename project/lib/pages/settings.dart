import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';// Ensure this is available in your project

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkTheme = false;
  bool taskReminders = true;
  bool teamUpdates = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: Colors.black, 
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My Account Section
          Text(
            "My Account",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Change Name", style: GoogleFonts.poppins(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Change Name screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text("Change Email", style: GoogleFonts.poppins(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Change Email screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text("Change Password", style: GoogleFonts.poppins(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Change Password screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text("Log Out", style: GoogleFonts.poppins(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Handle log out
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: Text("Delete Account", style: GoogleFonts.poppins(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Handle account deletion
                  },
                ),
              ],
            ),
          ),
          // App Preferences Section
          Text(
            "App Preferences",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: Text("Task Reminders", style: GoogleFonts.poppins(fontSize: 16)),
                  value: taskReminders,
                  onChanged: (val) {
                    setState(() {
                      taskReminders = val;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.group),
                  title: Text("Team Updates", style: GoogleFonts.poppins(fontSize: 16)),
                  value: teamUpdates,
                  onChanged: (val) {
                    setState(() {
                      teamUpdates = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}