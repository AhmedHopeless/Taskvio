import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/pages/events.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/pages/teams.dart';
import 'package:project/pages/tasks.dart';

class DashboardScreen extends StatefulWidget {
  static var primaryColor;

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Add this state variable to track the current nav index.
  int _currentIndex = 0;

  // Brand Colors and Typography (matching new_dashboard.dart look)
  static const Color primaryColor = Color(0xFF4F5DD3);
  static const Color lightGreen = Color(0xFFDFF3E3);

  @override
  void initState() {
    super.initState();
    _fetchTasksFromDb();
    _fetchEventsFromDb();
  }

  void _editTask(int index) {
    // Preload the inline form with the task's existing data.
    final task = tasks[index];
    _titleController.text = task['title'] ?? '';
    _notesController.text = task['description'] ?? '';
    _selectedStartDate = task['taskDate'];
    _selectedEndDate = task['dueDate'];
    
    setState(() {
      _editingTaskIndex = index;
      _showTaskForm = true;
    });
  }

  Future<void> _toggleTaskFinished(int index) async {
    final task = tasks[index];
    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'complete': !(task['completed'] ?? false)})
          .eq('id', task['id']);
      await _fetchTasksFromDb();
    } catch (e) {
      _showSnackBar("Error updating task: $e");
    }
  }

  Future<void> _deleteTask(int index) async {
    final task = tasks[index];
    try {
      await Supabase.instance.client
          .from('tasks')
          .delete()
          .eq('id', task['id']);
      await _fetchTasksFromDb();
    } catch (e) {
      _showSnackBar("Error deleting task: $e");
    }
  }

  void _editEvent(int index) {
    final event = events[index];
    _titleController.text = event['title'] ?? '';
    _notesController.text = event['description'] ?? '';
    _selectedStartDate = event['taskDate'];
    _selectedEndDate = event['dueDate'];
    setState(() {
      _editingEventIndex = index;
      _showEventForm = true;
    });
  }

  Future<void> _toggleEventFinished(int index) async {
    final event = events[index];
    try {
      await Supabase.instance.client
          .from('events')
          .update({'complete': !(event['completed'] ?? false)})
          .eq('id', event['id']);
      await _fetchEventsFromDb();
    } catch (e) {
      _showSnackBar("Error updating event: $e");
    }
  }

  Future<void> _deleteEvent(int index) async {
    final event = events[index];
    try {
      await Supabase.instance.client
          .from('events')
          .delete()
          .eq('id', event['id']);
      await _fetchEventsFromDb();
    } catch (e) {
      _showSnackBar("Error deleting event: $e");
    }
  }

  void _viewAllTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TasksScreen(tasks: tasks), // tasks already filtered for today
      ),
    );
  }

  void _viewAllEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventsScreen(events: events), // events already filtered for today
      ),
    );
  }

  static const double borderRadius = 16.0;

  // Controllers and state variables (for dialogs, etc.)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _selectedType = 'Task';
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> events = [];
  bool _showTaskForm = false;
  bool _showEventForm = false;
  int? _editingTaskIndex;
  int? _editingEventIndex; // <-- Added this for editing events

  Future<int?> _getProfileId() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final data = await Supabase.instance.client
      .from('profiles')
      .select('id')
      .eq('user_id', user.id)
      .limit(1) as List<dynamic>?;

  if (data != null && data.isNotEmpty) {
    return data.first['id'] as int;
  }
  return null;
}

  // Supabase: Fetch first name for greeting.
  Future<String> _fetchFirstName() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return "User";
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('user_id', currentUser.id)
          .single();
      if (response == null) return "User";
      return response['name'] ?? "User";
    } catch (e) {
      print('Error fetching first name: $e');
      return "User";
    }
  }

  Future<void> _fetchTasksFromDb() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T').first;
    final data = await Supabase.instance.client
        .from('tasks')
        .select('id, title, description, start_date, due_date, complete')
        .eq('UID', profileId)
        .lte('start_date', todayStr)
        .gte('due_date', todayStr) as List<dynamic>?;

    setState(() {
      tasks = data
              ?.map((e) => {
                    'id': e['id'],
                    'title': e['title'],
                    'description': e['description'],
                    'taskDate': DateTime.parse(e['start_date']),
                    'dueDate': DateTime.parse(e['due_date']),
                    'completed': e['complete'],
                  })
              .toList() ??
          [];
    });
  }

  Future<void> _fetchEventsFromDb() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T').first;
    final data = await Supabase.instance.client
        .from('events')
        .select('id, title, description, date, time, complete')
        .eq('UID', profileId)
        .eq('date', todayStr) as List<dynamic>?;

    print('Fetched events: $data');

    setState(() {
      events = data
              ?.map((e) => {
                    'id': e['id'],
                    'title': e['title'],
                    'description': e['description'],
                    'taskDate': DateTime.parse(e['date']),
                    'dueDate': _combineDateAndTime(e['date'], e['time']),
                    'completed': e['complete'],
                  })
              .toList() ??
          [];
    });
  }
  void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

  Future<void> _createTask() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    try {
      await Supabase.instance.client.from('tasks').insert({
        'title': _titleController.text,
        'description': _notesController.text,
        'start_date': _selectedStartDate!.toIso8601String().split('T').first,
        'due_date': _selectedEndDate!.toIso8601String().split('T').first,
        'complete': false,
        'UID': profileId,
      });
      await _fetchTasksFromDb();
    } catch (e) {
      _showSnackBar("Error creating task: $e");
    }
  }

  Future<void> _createEvent() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    try {
      final selectedTime = _selectedEndDate!; // This should be a DateTime

      final formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";
      await Supabase.instance.client.from('events').insert({
        'title': _titleController.text,
        'description': _notesController.text,
        'date': _selectedStartDate!.toIso8601String().split('T').first,
        'time': formattedTime,
        'complete': false,
        'UID': profileId,
      });
      await _fetchEventsFromDb();
    } catch (e) {
      _showSnackBar("Error creating event: $e");
    }
  }
  // Greeting widget at top.
  Widget _buildGreeting() {
    return FutureBuilder<String>(
      future: _fetchFirstName(),
      builder: (context, snapshot) {
        List<String> nameParts = (snapshot.data ?? 'User').split(" ");
        String firstName = nameParts.first;
        String greeting = "Hello, $firstName";
        return Text(
          greeting,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  // "Today's Goals" card.
  Widget _buildTodaysGoalsCard() {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.adjust, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "No goals for today",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "Add your first task",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      int totalTasks = tasks.length;
      int completedTasks =
          tasks.where((task) => task['completed'] == true).length;
      int percent = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completedTasks of $totalTasks tasks completed ($percent%)",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // Add this method to combine tasks and events goals:
  Widget _buildCombinedGoalsCard() {
    int total = tasks.length + events.length;
    int completedTasks = tasks.where((t) => t['completed'] == true).length;
    int completedEvents = events.where((e) => e['completed'] == true).length;
    int completed = completedTasks + completedEvents;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: const [
            Icon(Icons.adjust, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No goals for today",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Add your first task or event",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      int percent = ((completed / total) * 100).round();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completed of $total goals completed ($percent%)",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // Updated Action card used for Tasks and Events.
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String percent,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("$percent $subtitle",
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText, textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  // Status card for Tasks section.
  Widget _statusCard(String title, String subtitle, {IconData? icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.task_alt,
              color: Colors.blueAccent,
              size: 32,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Inline task form that appears when _showTaskForm is true.
  Widget _buildInlineTaskForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showTaskForm
          ? Container(
              key: const ValueKey('taskForm'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Task',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Task Date Field
                  TextField(
                    controller: TextEditingController(
                      text: _selectedStartDate == null
                          ? ''
                          : _selectedStartDate!.toLocal().toString().split(' ')[0],
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedStartDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Due Date Field
                  TextField(
                    controller: TextEditingController(
                      text: _selectedEndDate == null
                          ? ''
                          : _selectedEndDate!.toLocal().toString().split(' ')[0],
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedEndDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showTaskForm = false;
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Only process if a task name is provided.
                          if (_titleController.text.isNotEmpty) {
                            await _createTask();
                            setState(() {
                              _showTaskForm = false;
                              // Clear fields and date selections.
                              _titleController.clear();
                              _notesController.clear();
                              _selectedStartDate = null;
                              _selectedEndDate = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Task added', style: GoogleFonts.poppins()),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please enter a task name', style: GoogleFonts.poppins()),
                              ),
                            );
                          }
                        },
                        child: Text(
                          _editingTaskIndex == null ? 'Add Task' : 'Save Task',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('emptyForm')),
    );
  }

  // Inline event form that appears when _showEventForm is true.
  Widget _buildInlineEventForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showEventForm
          ? Container(
              key: const ValueKey('eventForm'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Event',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Event Name',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Event Description',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Event Date Field
                  TextField(
                    controller: TextEditingController(
                      text: _selectedStartDate == null
                          ? ''
                          : _selectedStartDate!.toLocal().toString().split(' ')[0],
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Event Date',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedStartDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Time Field
                  TextField(
                    controller: TextEditingController(
                      text: _selectedEndDate == null
                          ? ''
                          : _selectedEndDate!.toLocal().toString(),
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Event Time',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedEndDate = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showEventForm = false;
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Only process if an event name is provided.
                          if (_titleController.text.isNotEmpty) {
                            await _createEvent();
                            setState(() {
                              _showEventForm = false;
                              // Clear fields and date selections.
                              _titleController.clear();
                              _notesController.clear();
                              _selectedStartDate = null;
                              _selectedEndDate = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Event added', style: GoogleFonts.poppins()),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter an event name', style: GoogleFonts.poppins()),
                              ),
                            );
                          }
                        },
                        child: Text(
                          _editingEventIndex == null ? 'Add Event' : 'Save Event',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('emptyForm')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
  // Basic formatting: you can adjust this format as needed.
  return dateTime.toLocal().toString().substring(0, 16);
}

DateTime _combineDateAndTime(String date, String time) {
  final datePart = DateTime.parse(date);
  final timeParts = time.split(':');
  return DateTime(
    datePart.year,
    datePart.month,
    datePart.day,
    int.parse(timeParts[0]),
    int.parse(timeParts[1]),
    int.parse(timeParts[2]),
  );
}

  Widget _buildTasksList() {
    if (tasks.isEmpty) {
      return Row(
        children: [
          _statusCard("No tasks for today", "Enjoy your day!"),
          const SizedBox(width: 12),
        ],
      );
    } else {
      int previewCount = tasks.length > 3 ? 3 : tasks.length;
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewCount,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: ListTile(
                  title: Text(task['title'], style: GoogleFonts.poppins()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['description'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      if (task['dueDate'] != null)
                        Text(
                          "Time: ${_formatDateTime(task['dueDate'])}",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editTask(index);
                      } else if (value == 'finish') {
                        _toggleTaskFinished(index);
                      } else if (value == 'delete') {
                        _deleteTask(index);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit', style: GoogleFonts.poppins()),
                      ),
                      PopupMenuItem(
                        value: 'finish',
                        child: Text(
                          task['completed'] == true
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
          if (tasks.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TasksScreen(tasks: tasks),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        final tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: Curves.ease),
                        );
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Go to Tasks Page", style: GoogleFonts.poppins()),
              ),
            ),
        ],
      );
    }
  }

  Widget _buildEventsList() {
  if (events.isEmpty) {
    return Row(
      children: [
        _statusCard("No events for today", "Enjoy your day!"),
        const SizedBox(width: 12),
      ],
    );
  } else {
    int previewCount = events.length > 3 ? 3 : events.length;
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: previewCount,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: ListTile(
                title: Text(event['title'], style: GoogleFonts.poppins()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['description'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    if (event['dueDate'] != null)
                      Text(
                        "Time: ${_formatDateTime(event['dueDate'])}",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editEvent(index);
                    } else if (value == 'finish') {
                      _toggleEventFinished(index);
                    } else if (value == 'delete') {
                      _deleteEvent(index);
                    }
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
        if (events.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        EventsScreen(events: events),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      final tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: Curves.ease),
                      );
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Go to Events Page", style: GoogleFonts.poppins()),
            ),
          ),
      ],
    );
  }
}

  Widget _buildTasksSectionHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Tasks",
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      // Show FAB only after at least one task is added.
      if (tasks.isNotEmpty)
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _showTaskForm = true;
            });
          },
          mini: true,
          elevation: 0,
          backgroundColor: primaryColor,
          shape: const CircleBorder(side: BorderSide.none),
          child: const Icon(Icons.add, color: Colors.white),
        ),
    ],
  );
}

  // --- Add this new header for Events section ---
Widget _buildEventsSectionHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Events",
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      // Show FAB only after at least one event is added.
      if (events.isNotEmpty)
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _showEventForm = true;
            });
          },
          mini: true,
          elevation: 0,
          backgroundColor: primaryColor,
          shape: const CircleBorder(side: BorderSide.none),
          child: const Icon(Icons.add, color: Colors.white),
        ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: SizedBox(
          width: 200,
          child: Text(
            "Taskvio",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ), // or any title widget you use
        actions: [
          // Notification Bell Icon
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Implement notification functionality, e.g., show a snackbar or navigate
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Notifications pressed", style: GoogleFonts.poppins())),
              );
            },
          ),
          // Profile Icon with Dropdown Menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: DashboardScreen.primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'Profile') {
                // Navigate to Profile Screen
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              }else if (value == 'Logout') {
                // Handle logout logic
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile', style: GoogleFonts.poppins()),
              ),PopupMenuItem<String>(
                value: 'settings',
                child: Text('settings', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 24),
              Text("Today's Goals",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildCombinedGoalsCard(),
              const SizedBox(height: 16),
              // Side-by-side Action Cards for Tasks & Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionCard(
                    icon: Icons.checklist_rounded,
                    title: "Tasks",
                    percent: tasks.isEmpty 
                        ? "0%" 
                        : "${((tasks.where((t) => t['completed'] == true).length / tasks.length) * 100).round()}%",
                    subtitle: "Completed",
                    buttonText: tasks.isEmpty ? "Add your first task" : "View Tasks",
                    onPressed: () {
                      if (tasks.isEmpty) {
                        setState(() {
                          _showTaskForm = !_showTaskForm;
                        });
                      } else {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                TasksScreen(tasks: tasks),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              final tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: Curves.ease),
                              );
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  _actionCard(
                    icon: Icons.calendar_month_outlined,
                    title: "Events",
                    percent: events.isEmpty
                        ? "0%"
                        : "${((events.where((e) => e['completed'] == true).length / events.length) * 100).round()}%",
                    subtitle: "Completed",
                    buttonText: events.isEmpty ? "Add your first event" : "View events",
                    onPressed: () {
                      if (events.isEmpty) {
                        setState(() {
                          _showEventForm = !_showEventForm;
                          _showTaskForm = false;
                        });
                      } else {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                EventsScreen(events: events),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              final tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: Curves.ease),
                              );
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add both inline forms (they can be mutually exclusive if needed)
              _buildInlineTaskForm(),
              _buildInlineEventForm(), // <-- Add this so the event form appears when _showEventForm is true.
              const SizedBox(height: 16),
              // Tasks list (example placeholder)
              _buildTasksSectionHeader(),
              _buildTasksList(),
              const SizedBox(height: 24),
              _buildEventsSectionHeader(), // <-- Add this line to include the Events section header
              _buildEventsList(),
            ],
          ),
        ),
      ),
      // Rounded bottom navigation bar with the new Settings item.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          iconSize: 28,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              // Already on Home (DashboardScreen).
            } else if (index == 1) {
              Navigator.pushNamed(context, '/teams');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/calendar');
            } else if (index == 3) {
              // Navigate to Focus screen.
              Navigator.pushNamed(context, '/focus');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Teams',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Focus',
            ),
          ],
        ),
      ),
    );
  }
}
