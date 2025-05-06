import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/pages/team_dashboard.dart';



class FilteredTaskListPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String filter;
  final bool isTeamLeader;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onMarkDone;

  const FilteredTaskListPage({
    required this.tasks,
    required this.filter,
    required this.isTeamLeader,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkDone,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks;
    final now = DateTime.now();
    if (filter == 'completed') {
      filteredTasks = tasks.where((t) => t['complete'] == true).toList();
    } else if (filter == 'inprogress') {
      filteredTasks = tasks.where((t) {
        if (t['complete'] == true) return false;
        final start = DateTime.tryParse(t['start_date'] ?? '');
        final due = DateTime.tryParse(t['due_date'] ?? '');
        if (start == null || due == null) return false;
        return now.isAfter(start) && now.isBefore(due.add(const Duration(days: 1)));
      }).toList();
    } else {
      filteredTasks = tasks;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            isTeamLeader: isTeamLeader,
            onEdit: () => onEdit(task),
            onDelete: () => onDelete(task),
            onMarkDone: () => onMarkDone(task),
          );
        },
      ),
    );
  }
}