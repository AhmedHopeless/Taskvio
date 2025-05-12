import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final profileId = await _getProfileId();
    print('Profile ID: $profileId');
    if (profileId == null) return;
    final data = await Supabase.instance.client
        .from('tasks')
        .select()
        .eq('UID', profileId) as List<dynamic>?;

    setState(() {
      tasks = data?.cast<Map<String, dynamic>>() ?? [];
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
        .from('tasks')
        .update({'complete': complete})
        .eq('id', id);
    _fetchTasks();
  }

  Future<void> _deleteTask(int id) async {
    await Supabase.instance.client
        .from('tasks')
        .delete()
        .eq('id', id);
    _fetchTasks();
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final titleController = TextEditingController(text: task['title']);
    final descController = TextEditingController(text: task['description']);
    DateTime? selectedDueDate = task['due_date'] != null
        ? DateTime.tryParse(task['due_date'])
        : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
            SizedBox(height: 8),
            Row(
              children: [
                Text(selectedDueDate != null
                    ? 'Due: ${selectedDueDate?.toLocal().toString().split(' ')[0]}'
                    : 'No due date'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDueDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Supabase.instance.client
                  .from('tasks')
                  .update({
                    'title': titleController.text,
                    'description': descController.text,
                    'due_date': selectedDueDate?.toIso8601String().split('T').first,
                  })
                  .eq('id', task['id']);
              Navigator.pop(context);
              _fetchTasks();
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

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
                    title: Text(task['title'] ?? '', style: GoogleFonts.poppins()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['description'] ?? '', style: GoogleFonts.poppins(fontSize: 12)),
                        if (task['due_date'] != null)
                          Text('Due: ${task['due_date']}', style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task['complete'] ?? false,
                          onChanged: (val) => _markComplete(task['id'], val ?? false),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTask(task),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTask(task['id']),
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