import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _selectedType = 'Task';

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> events = [];

  double get _taskProgress {
    if (tasks.isEmpty) return 0;
    int completed = tasks.where((task) => task['completed'] == true).length;
    return completed / tasks.length;
  }

  double get _eventProgress {
    if (events.isEmpty) return 0;
    int completed = events.where((event) => event['completed'] == true).length;
    return completed / events.length;
  }

  double _overallProgress() {
    int total = tasks.length + events.length;
    if (total == 0) return 0;
    int completed = tasks.where((t) => t['completed'] == true).length +
        events.where((e) => e['completed'] == true).length;
    return completed / total;
  }

  String _completedGoals() {
    int completed = tasks.where((t) => t['completed'] == true).length +
        events.where((e) => e['completed'] == true).length;
    int total = tasks.length + events.length;
    return "$completed/$total";
  }

  void _showAddNewDialog() {
    showGeneralDialog(
      context: context,
      
      barrierDismissible: true,
      barrierLabel: 'Add New',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(child: _buildAddNewDialogContent());
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -200, 0.0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  Widget _buildAddNewDialogContent() {
    return Dialog(
      backgroundColor: Colors.white,
      shadowColor: Colors.indigo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add New', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Task', 'Event'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickStartDate,
                child: Text(_selectedStartDate == null
                    ? 'Pick Start Date'
                    : 'Start: ${_selectedStartDate!.toLocal()}'.split(' ')[0]),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 221, 226, 255), foregroundColor: Colors.indigo), 
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickEndDate,
                child: Text(_selectedEndDate == null
                    ? 'Pick End Date (Optional)'
                    : 'End: ${_selectedEndDate!.toLocal()}'.split(' ')[0]),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 221, 226, 255), foregroundColor: Colors.indigo),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel' 
                    ,style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.indigo)),
                  ),
                  ElevatedButton(
                    onPressed: _addNewItem,
                    child: Text('Add'
                    ,style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.indigo)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  void _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  void _addNewItem() {
    if (_titleController.text.isNotEmpty && _selectedStartDate != null) {
      final newItem = {
        'title': _titleController.text,
        'notes': _notesController.text,
        'startDate': _selectedStartDate!.toLocal().toString().split(' ')[0],
        'endDate': _selectedEndDate != null ? _selectedEndDate!.toLocal().toString().split(' ')[0] : null,
        'completed': false,
      };
      setState(() {
        if (_selectedType == 'Task') {
          tasks.add(newItem);
        } else {
          events.add(newItem);
        }
      });
      Navigator.pop(context);
      _titleController.clear();
      _notesController.clear();
      _selectedStartDate = null;
      _selectedEndDate = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Title and Start Date')),
      );
    }
  }

  Widget _buildProgressCircle({
    required String title,
    required double progress,
    required Color baseColor,
  }) {
    Color dynamicColor = progress == 1.0 ? Colors.green : baseColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  value: value,
                  backgroundColor: Colors.grey.shade300,
                  color: dynamicColor,
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text("${(progress * 100).toInt()}%", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDismissibleTile(Map<String, dynamic> item, bool isTask, int index) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!item['completed']) {
            setState(() {
              if (isTask) tasks[index]['completed'] = true;
              else events[index]['completed'] = true;
            });
          }
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        setState(() {
          if (isTask) tasks.removeAt(index);
          else events.removeAt(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTask ? Colors.white : Colors.blue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      decoration: item['completed'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item['notes'] != null && item['notes'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        item['notes'],
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      item['startDate'] != null
                          ? 'Start: ${item['startDate']}${item['endDate'] != null ? ' - End: ${item['endDate']}' : ''}'
                          : '',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool isTask) {
    final list = isTask ? tasks : events;
    return list.isEmpty
        ? Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(isTask ? Icons.check_circle_outline : Icons.event_available_outlined,
                    color: isTask ? Colors.indigo : Colors.indigo, size: 60),
                SizedBox(height: 10),
                Text(
                  isTask ? "You're all set for tasks! 🎉" : "No upcoming events! 🗓️",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildDismissibleTile(list[index], isTask, index);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Dashboard", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none, color: Colors.black)),
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
              cardTheme: CardTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.person_outline, color: Colors.black),
              offset: const Offset(0, 50),
              onSelected: (String value) {
                if (value == 'manageProfile') {
                  print("Manage Profile clicked");
                } else if (value == 'settings') {
                  print("Settings clicked");
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'manageProfile',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text('Manage Profile', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text('Settings', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Goals", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Today's Goal",
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text("${_completedGoals()} Completed",
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                    ]),
                  ),
                  Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _overallProgress(),
                        strokeWidth: 6,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text("${(_overallProgress() * 100).toInt()}%",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressCircle(title: "Tasks", progress: _taskProgress, baseColor: Colors.red),
                _buildProgressCircle(title: "Events", progress: _eventProgress, baseColor: Colors.lightBlue),
              ],
            ),
            SizedBox(height: 40),
            Text("Tasks", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildList(true),
            SizedBox(height: 30),
            Text("Events", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildList(false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _showAddNewDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Set the current index to Home
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            // Navigate to Teams page
            Navigator.pushNamed(context, '/teams');
          } else if (index == 2) {
            // Navigate to Calendar page
            Navigator.pushNamed(context, '/calendar');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt_outlined), label: 'Focus'),
        ],
      ),
    );
  }
}
