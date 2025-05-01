import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const TasksScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Tasks", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: tasks.isEmpty
          ? Center(
              child: Text("No tasks", style: GoogleFonts.poppins(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(task['title'], style: GoogleFonts.poppins()),
                    subtitle: Text(task['description'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}