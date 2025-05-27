import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/pages/filteredTasks.dart';
import 'package:project/pages/teamMember.dart';
import 'package:supabase_flutter/supabase_flutter.dart';





class TeamDashboard extends StatefulWidget {
  final int tid;

  const TeamDashboard({Key? key, required this.tid}) : super(key: key);

  @override
  _TeamDashboardState createState() => _TeamDashboardState();
}

class _TeamDashboardState extends State<TeamDashboard> {
  int? profileId;
  bool isLeader = false;

  Map<String, dynamic>? teamInfo;
  List<Map<String, dynamic>> teamMembers = [];

  List<Map<String, dynamic>> teamTasks = [];
  List<Map<String, dynamic>> teamEvents = [];
  List<Map<String, dynamic>> myTasks = [];
  List<Map<String, dynamic>> myEvents = [];

  int completedTasks = 0;
  int inProgressTasks = 0;
  int totalTasks = 0;

  bool showAllTasks = false;
  bool showAllEvents = false;

  @override
  void initState() {
    super.initState();
    _initUserAndData();
  }

  Future<void> _initUserAndData() async {
    await _initUser();
    await _fetchTeamInfo();
    await _fetchTeamMembers();
    if (isLeader) {
      await _fetchAllTeamTasksEvents();
      _calculateTaskStats(teamTasks);
    } else {
      await _fetchMyAssignedTasksEvents();
      _calculateTaskStats(myTasks);
    }
    setState(() {});
  }

  Future<void> _initUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    profileId = data?['id'];
    final rel = await Supabase.instance.client
        .from('team_user_rel')
        .select('team_leader')
        .eq('UID', profileId!)
        .eq('TID', widget.tid)
        .maybeSingle();
    isLeader = rel?['team_leader'] == true;
  }

  Future<void> _fetchTeamInfo() async {
    final team = await Supabase.instance.client
        .from('teams')
        .select()
        .eq('id', widget.tid)
        .maybeSingle();
    teamInfo = team;
  }

  Future<void> _fetchTeamMembers() async {

    final members = await Supabase.instance.client
        .from('team_user_rel')
        .select('UID, team_leader')
        .eq('TID', widget.tid) as List<dynamic>?;

    if (members == null || members.isEmpty) {
      teamMembers = [];
      return;
    }

    final uids = members.map((e) => e['UID']).toList();


    final profilesList = await Supabase.instance.client
        .from('profiles')
        .select('id, name')
        .inFilter('id', uids) as List<dynamic>?;


    final Map<int, String> profilesMap = {
      for (var p in profilesList ?? [])
        if (p['id'] != null) p['id'] as int: p['name'] ?? ''
    };


    print('UIDs: $uids');
    print('Profiles List: $profilesList');
    print('Profiles Map: $profilesMap');


    teamMembers = members.map<Map<String, dynamic>>((member) {
      final uid = member['UID'] as int;
      return {
        ...member,
        'profileName': profilesMap[uid] ?? '',
      };
    }).toList();
  }

  Future<void> _fetchAllTeamTasksEvents() async {
    final tasks = await Supabase.instance.client
        .from('team_tasks')
        .select()
        .eq('TID', widget.tid) as List<dynamic>?;
    teamTasks = tasks?.cast<Map<String, dynamic>>() ?? [];
    final events = await Supabase.instance.client
        .from('team_events')
        .select()
        .eq('TID', widget.tid) as List<dynamic>?;
    this.teamTasks = (teamTasks.where((e) => e != null).toList()) ?? [];
    teamEvents = events?.cast<Map<String, dynamic>>() ?? [];
    print('teamTasks: $teamTasks');
  }

  Future<void> _fetchMyAssignedTasksEvents() async {

    final taskRels = await Supabase.instance.client
        .from('TeamTask_user_rel')
        .select('TaskID')
        .eq('UID', profileId!) as List<dynamic>?;
    final taskIds = taskRels?.map((e) => e['TaskID']).toList() ?? [];
    final tasks = taskIds.isEmpty
        ? []
        : await Supabase.instance.client
            .from('team_tasks')
            .select()
            .inFilter('id', taskIds)
            .eq('TID', widget.tid) as List<dynamic>?;

    final eventRels = await Supabase.instance.client
        .from('teamEvent_user_rel')
        .select('Event_ID')
        .eq('UID', profileId!) as List<dynamic>?;
    final eventIds = eventRels?.map((e) => e['Event_ID']).toList() ?? [];
    final events = eventIds.isEmpty
        ? []
        : await Supabase.instance.client
            .from('team_events')
            .select()
            .inFilter('id', eventIds)
            .eq('TID', widget.tid) as List<dynamic>?;
    myTasks = tasks?.cast<Map<String, dynamic>>() ?? [];
    myEvents = events?.cast<Map<String, dynamic>>() ?? [];
  }

Future<void> deleteTeam() async {

  await Supabase.instance.client
      .from('TeamTask_user_rel')
      .delete()
      .inFilter('TaskID', (await Supabase.instance.client
          .from('team_tasks')
          .select('id')
          .eq('TID', widget.tid) as List<dynamic>)
          .map((task) => task['id'])
          .toList());


  await Supabase.instance.client
      .from('teamEvent_user_rel')
      .delete()
      .inFilter('Event_ID', (await Supabase.instance.client
          .from('team_events')
          .select('id')
          .eq('TID', widget.tid) as List<dynamic>)
          .map((event) => event['id'])
          .toList());


  await Supabase.instance.client
      .from('team_tasks')
      .delete()
      .eq('TID', widget.tid);


  await Supabase.instance.client
      .from('team_events')
      .delete()
      .eq('TID', widget.tid);

  await Supabase.instance.client
      .from('team_user_rel')
      .delete()
      .eq('TID', widget.tid);

  await Supabase.instance.client
      .from('teams')
      .delete()
      .eq('id', widget.tid);

  Navigator.pop(context, true); 
}

  Future<void> leaveTeam() async {

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    final profileId = profile?['id'];
    if (profileId == null) return;
    await Supabase.instance.client
        .from('team_user_rel')
        .delete()
        .eq('UID', profileId)
        .eq('TID', widget.tid);
    Navigator.pop(context, true); 
  }

  Future<void> editTeam(String newName, String newDescription) async {
    await Supabase.instance.client.from('teams').update({
      'name': newName,
      'description': newDescription,
    }).eq('id', widget.tid);
    await _fetchTeamInfo(); 
    setState(() {});
  }

  Future<void> showEditTeamDialog() async {
    final nameController = TextEditingController(text: teamInfo?['name'] ?? '');
    final descController =
        TextEditingController(text: teamInfo?['description'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Team Title'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await editTeam(nameController.text, descController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> showTeamCodeDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Team Code',
          style: TextStyle(fontSize: 24), 
        ),
        content: Text(
          'Your team code is: ${teamInfo?['code'] ?? 'N/A'}',
          style: TextStyle(fontSize: 20), 
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateTaskStats(List<Map<String, dynamic>> tasks) {
    final now = DateTime.now();
    totalTasks = tasks.length;
    completedTasks = tasks.where((t) => t['complete'] == true).length;
    inProgressTasks = tasks.where((t) {
      if (t['complete'] == true) return false;
      final start = DateTime.tryParse(t['start_date'] ?? '');
      final due = DateTime.tryParse(t['due_date'] ?? '');
      if (start == null || due == null) return false;
      return now.isAfter(start) &&
          now.isBefore(due.add(const Duration(days: 1)));
    }).length;
  }

  Future<bool> showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? _selectedStartDate;
    DateTime? _selectedEndDate;
    final assignableMembers =
        teamMembers.where((m) => m['team_leader'] != true).toList();
    final allMemberIds = assignableMembers.map((m) => m['UID'] as int).toList();
    List<int> selectedMemberIds =
        List<int>.from(allMemberIds); 

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(
                    text: _selectedStartDate == null
                        ? ''
                        : _selectedStartDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
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
                      borderSide: BorderSide(color: Colors.indigo),
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
                      borderSide: BorderSide(color: Colors.indigo),
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
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Assign to:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                AssignToDropdown(
                  members: assignableMembers,
                  selectedIds: selectedMemberIds,
                  onChanged: (ids) {
                    setState(() {
                      selectedMemberIds = ids;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedStartDate != null &&
                    _selectedEndDate != null &&
                    selectedMemberIds.isNotEmpty) {
                  final insertResult = await Supabase.instance.client
                      .from('team_tasks')
                      .insert({
                        'title': titleController.text,
                        'description': descController.text,
                        'start_date': _selectedStartDate!
                            .toIso8601String()
                            .split('T')
                            .first,
                        'due_date': _selectedEndDate!
                            .toIso8601String()
                            .split('T')
                            .first,
                        'complete': false,
                        'TID': widget.tid,
                      })
                      .select()
                      .single();
                  final taskId = insertResult['id'];

                  for (final uid in selectedMemberIds) {
                    await Supabase.instance.client
                        .from('TeamTask_user_rel')
                        .insert({
                      'UID': uid,
                      'TaskID': taskId,
                    });
                  }
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task added')),
                  );
                  await isLeader
                      ? _fetchAllTeamTasksEvents()
                      : _fetchMyAssignedTasksEvents();
                  _calculateTaskStats(teamTasks);
                  setState(() {});
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
    return true;
  }

  void _navigateToTaskList(BuildContext context, {required String filter}) {
    final tasks = isLeader ? teamTasks : myTasks;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilteredTaskListPage(
          tasks: tasks,
          filter: filter,
          isTeamLeader: isLeader,
          onEdit: (task) => _editTask(task),
          onDelete: (task) => _deleteTask(task),
          onMarkDone: (task) => _markTaskDone(task),
        ),
      ),
    );
  }

  Future<bool> showAddEventDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? eventDate;
    DateTime? _selectedStartDate; 
    DateTime? _selectedEndDate; 
    TimeOfDay? eventTime;
    final assignableMembers =
        teamMembers.where((m) => m['team_leader'] != true).toList();
    final allMemberIds = assignableMembers.map((m) => m['UID'] as int).toList();
    List<int> selectedMemberIds =
        List<int>.from(allMemberIds);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: eventDate == null
                        ? ''
                        : '${eventDate!.year}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}',
                  ),
                  decoration: InputDecoration(labelText: 'Event Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: eventDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        eventDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: eventTime == null ? '' : eventTime!.format(context),
                  ),
                  decoration: InputDecoration(labelText: 'Event Time'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: eventTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        eventTime = picked;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Assign to:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                AssignToDropdown(
                  members: assignableMembers,
                  selectedIds: selectedMemberIds,
                  onChanged: (ids) {
                    setState(() {
                      selectedMemberIds = ids;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (eventDate != null &&
                    eventTime != null &&
                    selectedMemberIds.isNotEmpty) {
                  final formattedTime =
                      '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}:00';
                  final insertResult = await Supabase.instance.client
                      .from('team_events')
                      .insert({
                        'title': titleController.text,
                        'description': descController.text,
                        'date': eventDate!.toIso8601String().split('T').first,
                        'time': formattedTime,
                        'complete': false,
                        'TID': widget.tid,
                      })
                      .select()
                      .single();
                  final eventId = insertResult['id'];

                  for (final uid in selectedMemberIds) {
                    await Supabase.instance.client
                        .from('teamEvent_user_rel')
                        .insert({
                      'UID': uid,
                      'Event_ID': eventId,
                    });
                  }
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event added')),
                  );
                  await isLeader
                      ? _fetchAllTeamTasksEvents()
                      : _fetchMyAssignedTasksEvents();
                  _calculateTaskStats(teamTasks);
                  setState(() {});
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
    return true;
  }

  Future<void> showEditTaskDialog(Map<String, dynamic> task) async {
    final titleController = TextEditingController(text: task['title'] ?? '');
    final descController =
        TextEditingController(text: task['description'] ?? '');
    DateTime? startDate = DateTime.tryParse(task['start_date'] ?? '');
    DateTime? dueDate = DateTime.tryParse(task['due_date'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: startDate == null
                        ? ''
                        : startDate?.toLocal().toString().split(' ')[0],
                  ),
                  decoration: InputDecoration(labelText: 'Start Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: dueDate == null
                        ? ''
                        : dueDate?.toLocal().toString().split(' ')[0],
                  ),
                  decoration: InputDecoration(labelText: 'Due Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        dueDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.from('team_tasks').update({
                  'title': titleController.text,
                  'description': descController.text,
                  'start_date': startDate?.toIso8601String().split('T').first,
                  'due_date': dueDate?.toIso8601String().split('T').first,
                }).eq('id', task['id']);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showEditEventDialog(Map<String, dynamic> event) async {
    final titleController = TextEditingController(text: event['title'] ?? '');
    final descController =
        TextEditingController(text: event['description'] ?? '');
    DateTime? eventDate = DateTime.tryParse(event['date'] ?? '');
    TimeOfDay? eventTime;
    if (event['time'] != null && event['time'].toString().contains(':')) {
      final parts = event['time'].split(':');
      eventTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: eventDate == null
                        ? ''
                        : eventDate?.toLocal().toString().split(' ')[0],
                  ),
                  decoration: InputDecoration(labelText: 'Event Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: eventDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        eventDate = picked;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: eventTime == null ? '' : eventTime?.format(context),
                  ),
                  decoration: InputDecoration(labelText: 'Event Time'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: eventTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        eventTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final formattedTime = eventTime == null
                    ? null
                    : '${eventTime?.hour.toString().padLeft(2, '0')}:${eventTime?.minute.toString().padLeft(2, '0')}:00';
                await Supabase.instance.client.from('team_events').update({
                  'title': titleController.text,
                  'description': descController.text,
                  'date': eventDate?.toIso8601String().split('T').first,
                  'time': formattedTime,
                }).eq('id', event['id']);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTask(Map<String, dynamic> task) async {

    await showEditTaskDialog(task);
    await _fetchAllTeamTasksEvents();
    _calculateTaskStats(teamTasks);
    setState(() {});
  }

  Future<void> _deleteTask(Map<String, dynamic> task) async {

    await Supabase.instance.client
        .from('TeamTask_user_rel')
        .delete()
        .eq('TaskID', task['id']);

    await Supabase.instance.client
        .from('team_tasks')
        .delete()
        .eq('id', task['id']);
    await _fetchAllTeamTasksEvents();
    _calculateTaskStats(teamTasks);
    setState(() {});
  }

  Future<void> _markTaskDone(Map<String, dynamic> task) async {
    await Supabase.instance.client
        .from('team_tasks')
        .update({'complete': true}).eq('id', task['id']);
    await _fetchMyAssignedTasksEvents();
    _calculateTaskStats(myTasks);
    setState(() {});
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    await showEditEventDialog(event);
    await _fetchAllTeamTasksEvents();
    setState(() {});
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {

    await Supabase.instance.client
        .from('teamEvent_user_rel')
        .delete()
        .eq('Event_ID', event['id']);

    await Supabase.instance.client
        .from('team_events')
        .delete()
        .eq('id', event['id']);
    await _fetchAllTeamTasksEvents();
    setState(() {});
  }

  Future<void> _removeMemberFromTeam(Map<String, dynamic> member) async {
    await Supabase.instance.client
        .from('TeamTask_user_rel')
        .delete()
        .eq('UID', member['UID'])
        .eq('TID', widget.tid);
    await Supabase.instance.client
        .from('teamEvent_user_rel')
        .delete()
        .eq('UID', member['UID'])
        .eq('TID', widget.tid);
    await Supabase.instance.client
        .from('team_user_rel')
        .delete()
        .eq('UID', member['UID'])
        .eq('TID', widget.tid);
  }

  Future<void> _markEventDone(Map<String, dynamic> event) async {
    await Supabase.instance.client
        .from('team_events')
        .update({'complete': true}).eq('id', event['id']);
    await Supabase.instance.client
        .from('teamEvent_user_rel')
        .delete()
        .eq('Event_ID', event['id']);
    await Supabase.instance.client
        .from('team_events')
        .delete()
        .eq('id', event['id']);
    await _fetchAllTeamTasksEvents();
    setState(() {});
  }

  Widget _buildEventList() {
    final eventsToShow = isLeader ? teamEvents : myEvents;
    if (eventsToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text('No events available.',
                style: TextStyle(color: Colors.grey))),
      );
    }
    final displayEvents =
        showAllEvents ? eventsToShow : eventsToShow.take(2).toList();
    return Column(
      
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: displayEvents.length,
          itemBuilder: (context, index) {
            final event = displayEvents[index];
            return EventCard(
              event: event,
              isTeamLeader: isLeader,
              onEdit: () => _editEvent(event),
              onDelete: () => _deleteEvent(event),
              onMarkDone: () => _markEventDone(event),
            );
          },
        ),
        if (!showAllEvents && eventsToShow.length > 2)
          TextButton(
            onPressed: () {
              _navigateToTaskList(context, filter: 'total');
            },
            child: Text('View More'),
          ),
      ],
    );
  }

  Widget _buildTaskList() {
    final now = DateTime.now();
    final tasksToShow = (isLeader ? teamTasks : myTasks).where((task) {
      final start = DateTime.tryParse(task['start_date'] ?? '');
      final due = DateTime.tryParse(task['due_date'] ?? '');
      if (start == null || due == null) return false;
      return !now.isBefore(start) && !now.isAfter(due);
    }).toList();

    if (tasksToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
              Text('No tasks available.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    final displayTasks =
        showAllTasks ? tasksToShow : tasksToShow.take(2).toList();
    return Column(
      
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: displayTasks.length,
          itemBuilder: (context, index) {
            final task = displayTasks[index];
            return TaskCard(
              task: task,
              isTeamLeader: isLeader,
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
              onMarkDone: () => _markTaskDone(task),
            );
          },
        ),
        if (!showAllTasks && tasksToShow.length > 2)
          TextButton(
            onPressed: () {
              _navigateToTaskList(context, filter: 'total');
            },
            child: Text('View More'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          teamInfo?['name'] ?? ' ',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 50, 0, 0),
                items: isLeader
                    ? [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Team'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Team'),
                        ),
                        PopupMenuItem(
                          value: 'show_code',
                          child: Text('Show Team Code'),
                        ),
                      ]
                    : [
                        PopupMenuItem(
                          value: 'leave',
                          child: Text('Leave Team'),
                        ),
                      ],
              ).then((value) {
                if (value == 'edit') {
                  showEditTeamDialog();
                } else if (value == 'delete') {
                  deleteTeam();
                } else if (value == 'leave') {
                  leaveTeam();
                } else if (value == 'show_code' && isLeader) {
                  showTeamCodeDialog();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _navigateToTaskList(context, filter: 'total'),
                      child: _buildStatCard('Total Tasks', '$totalTasks'),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () =>
                          _navigateToTaskList(context, filter: 'completed'),
                      child: _buildStatCard('Completed', '$completedTasks'),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () =>
                          _navigateToTaskList(context, filter: 'inprogress'),
                      child: _buildStatCard('In Progress', '$inProgressTasks'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamMembersPage(
                        teamMembers: teamMembers,
                        isLeader: isLeader,
                        teamId: widget.tid,
                      ),
                    ),
                  );
                },
                child: _buildTeamMembersPreview(),
              ),
              SizedBox(height: 10),
              _buildTaskList(),
              _buildEventList(),
            ],
          ),
        ),
      ),
      floatingActionButton: isLeader ? _buildFab(context) : null,
    );
  }

  Widget _buildStatCard(String title, String value) {
    return SizedBox(
      width: 128,
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
                            (teamMembers[i]['profileName']?.isNotEmpty ?? false)
                                ? teamMembers[i]['profileName'][0]
                                : '?',
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

  Widget _buildFab(BuildContext context) {
    return _TeamFab(
      onAddTask: () async {
        final result = await showAddTaskDialog();
        print(result);
        if (result == true) {
          await _fetchAllTeamTasksEvents();
          _calculateTaskStats(teamTasks);
          setState(() {});
        }
      },
      onAddEvent: () async {
        final result = await showAddEventDialog();
        print(result);
        if (result == true) {
          await _fetchAllTeamTasksEvents();
          setState(() {});
        }
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isTeamLeader;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkDone;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isTeamLeader,
    this.onEdit,
    this.onDelete,
    this.onMarkDone,
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
              color: task['complete'] == true ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'No Title',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task['description'] != null)
                  Text(
                    'Description: ${task['description'] ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  'Due: ${task['due_date'] ?? ''}',
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
          if (!isTeamLeader && !(task['complete'] ?? false))
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: onMarkDone,
            ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isTeamLeader;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkDone;

  const EventCard({
    Key? key,
    required this.event,
    required this.isTeamLeader,
    this.onEdit,
    this.onDelete,
    this.onMarkDone,
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
              color: event['complete'] == true ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'No Title',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (event['description'] != null)
                  Text(
                    'Description: ${event['description'] ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  'Date: ${event['date'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Time: ${event['time'] ?? ''}',
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
                if (!(event['complete'] ?? false))
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: onMarkDone,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TeamFab extends StatefulWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddEvent;

  const _TeamFab({required this.onAddTask, required this.onAddEvent});

  @override
  State<_TeamFab> createState() => _TeamFabState();
}

class _TeamFabState extends State<_TeamFab> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_showMenu)
          Padding(
            padding: const EdgeInsets.only(bottom: 70, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'addTask',
                  onPressed: () {
                    setState(() => _showMenu = false);
                    widget.onAddTask();
                  },
                  icon: Icon(Icons.task),
                  label: Text('Add Task'),
                ),
                SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'addEvent',
                  onPressed: () {
                    setState(() => _showMenu = false);
                    widget.onAddEvent();
                  },
                  icon: Icon(Icons.event),
                  label: Text('Add Event'),
                ),
              ],
            ),
          ),
        FloatingActionButton(
          heroTag: 'mainFab',
          onPressed: () => setState(() => _showMenu = !_showMenu),
          backgroundColor: Colors.indigo,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            color: Colors.white,
            progress: AlwaysStoppedAnimation(_showMenu ? 1 : 0),
          ),
        ),
      ],
    );
  }
}

class AssignToDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;

  const AssignToDropdown({
    required this.members,
    required this.selectedIds,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<AssignToDropdown> createState() => _AssignToDropdownState();
}

class _AssignToDropdownState extends State<AssignToDropdown> {
  late List<int> _selectedIds;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<int>.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _selectedIds.isEmpty
                        ? 'Assign to...'
                        : widget.members
                            .where((m) => _selectedIds.contains(m['UID']))
                            .map((m) => m['profileName'])
                            .join(', '),
                  ),
                ),
                Icon(_expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.members.map((member) {
            return CheckboxListTile(
              value: _selectedIds.contains(member['UID']),
              title: Text(member['profileName'] ?? ''),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedIds.add(member['UID']);
                  } else {
                    _selectedIds.remove(member['UID']);
                  }
                  widget.onChanged(_selectedIds);
                });
              },
            );
          }).toList(),
      ],
    );
  }
}
