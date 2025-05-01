import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  const EventsScreen({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Events", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: events.isEmpty
          ? Center(
              child: Text("No events", style: GoogleFonts.poppins(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(event['title'] ?? "",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(event['description'] ?? "",
                        style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        // TODO: Implement actions for edit, finish, delete.
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit', style: GoogleFonts.poppins()),
                        ),
                        PopupMenuItem(
                          value: 'finish',
                          child: Text(
                            event['completed'] == true
                                ? 'Mark as Unfinished'
                                : 'Mark as Finished',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}