import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


enum TaskStatus {
  pending,
  inProgress,
  completed,
  overdue
}

extension TaskStatusExtension on TaskStatus {
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.overdue:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }
}

class TeamDashboardScreen extends StatefulWidget {
  final Map<String, String> team;
  const TeamDashboardScreen({Key? key, required this.team}) : super(key: key);

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  bool isTeamLeader = false; // Replace with actual role check
  String currentUserId = '1'; // Replace with actual user ID
  
  // Add these controllers
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamDescriptionController = TextEditingController();
  
  // Sample tasks data
  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Design the app',
      'description': 'Create wireframes and design the UI',
      'status': 'In Progress',
      'assignedTo': 'John Doe',
      'dueDate': '2023-10-10',
    },
    {
      'title': 'Develop the app',
      'description': 'Build the app using Flutter',
      'status': 'Pending',
      'assignedTo': 'Jane Smith',
      'dueDate': '2023-10-15',
    },
  ];

  // Sample team members data
  final List<Map<String, dynamic>> teamMembers = [
    {
      'id': '1',
      'name': 'John Doe',
      'role': 'Leader',
      'imageUrl': 'https://example.com/john.jpg',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'role': 'Member',
      'imageUrl': 'https://example.com/jane.jpg',
    },
  ];

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _teamNameController.dispose();
    _teamDescriptionController.dispose();
    super.dispose();
  }

  Widget _buildTeamMembersPreview() {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Members',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  for (var i = 0; i < teamMembers.length; i++)
                    Positioned(
                      left: i * 30.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            teamMembers[i]['name'][0],
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ),
                    ),
                  if (teamMembers.length > 4)
                    Positioned(
                      left: 4 * 30.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.indigo.withOpacity(0.8),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            '+${teamMembers.length - 4}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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

  // Add these methods to your _TeamDashboardScreenState class
  void _showEditTaskDialog(Map<String, dynamic> task) {
    _taskTitleController.text = task['title'];
    _taskDescriptionController.text = task['description'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Task',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _taskTitleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _taskDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Update task logic here
                      setState(() {
                        task['title'] = _taskTitleController.text;
                        task['description'] = _taskDescriptionController.text;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteTask(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tasks.remove(task);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(widget.team['name'] ?? 'Team Dashboard'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Total Tasks', '24'),
                SizedBox(width: 16),
                _buildStatCard('Completed', '18'),
                SizedBox(width: 16),
                _buildStatCard('In Progress', '6'),
              ],
            ),
            SizedBox(height: 24),
            _buildTeamMembersPreview(),
            SizedBox(height: 24),
            _buildTaskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    // Sample tasks data
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Design the app',
        'description': 'Create wireframes and design the UI',
        'status': 'In Progress',
        'assignedTo': 'John Doe',
        'dueDate': '2023-10-10',
      },
      {
        'title': 'Develop the app',
        'description': 'Build the app using Flutter',
        'status': 'Pending',
        'assignedTo': 'Jane Smith',
        'dueDate': '2023-10-15',
      },
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            isTeamLeader: isTeamLeader,
            onEdit: () => _showEditTaskDialog(task),
            onDelete: () => _deleteTask(task),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isTeamLeader;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isTeamLeader,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: task['status'] == 'In Progress' 
                  ? Colors.blue 
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task['assignedTo'] != null)
                  Text(
                    'Assigned to: ${task['assignedTo']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  'Due: ${task['dueDate']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isTeamLeader)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}