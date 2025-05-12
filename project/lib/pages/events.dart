import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    final data = await Supabase.instance.client
        .from('events')
        .select()
        .eq('UID', profileId) as List<dynamic>?;
    setState(() {
      events = data?.cast<Map<String, dynamic>>() ?? [];
    });
  }

  Future<int?> _getProfileId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    return data?['id'] as int?;
  }

  Future<void> _markComplete(int id, bool complete) async {
    await Supabase.instance.client
        .from('events')
        .update({'completed': complete})
        .eq('id', id);
    _fetchEvents();
  }

  Future<void> _deleteEvent(int id) async {
    await Supabase.instance.client
        .from('events')
        .delete()
        .eq('id', id);
    _fetchEvents();
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    final titleController = TextEditingController(text: event['title']);
    final descController = TextEditingController(text: event['description']);
    DateTime? selectedDate = event['date'] != null
        ? DateTime.tryParse(event['date'])
        : null;
    TimeOfDay? selectedTime;
    if (event['time'] != null && event['time'].toString().isNotEmpty) {
      final parts = event['time'].split(':');
      if (parts.length >= 2) {
        selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          selectedDate != null
                              ? selectedDate!.toLocal().toString().split(' ')[0]
                              : 'Select date',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          selectedTime = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : 'Select time',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              String? formattedTime;
              if (selectedTime != null) {
                final hour = selectedTime!.hour.toString().padLeft(2, '0');
                final minute = selectedTime!.minute.toString().padLeft(2, '0');
                formattedTime = '$hour:$minute:00';
              }
              await Supabase.instance.client
                  .from('events')
                  .update({
                    'title': titleController.text,
                    'description': descController.text,
                    'date': selectedDate?.toIso8601String().split('T').first,
                    'time': formattedTime,
                  })
                  .eq('id', event['id']);
              Navigator.pop(context);
              _fetchEvents();
            },
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(event['title'] ?? '', style: GoogleFonts.poppins()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['description'] ?? '', style: GoogleFonts.poppins(fontSize: 12)),
                        if (event['date'] != null)
                          Text('Date: ${event['date']}', style: GoogleFonts.poppins(fontSize: 12)),
                        if (event['time'] != null)
                          Text('Time: ${event['time']}', style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: event['completed'] ?? false,
                          onChanged: (val) => _markComplete(event['id'], val ?? false),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editEvent(event),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteEvent(event['id']),
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