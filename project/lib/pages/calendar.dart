import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentIndex = 2;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _popinfo() {
    showDialog(
      context: context,
      builder: (context) => Center(
    child: SizedBox(
      height: 300,
      child:  AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Remember that'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Tasks"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Events"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Team tasks and events"),
                ],
              ),
            ],
          ),
          
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.indigo,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
        ],
      ),
    ),
  ),
);
  }

  Future<void> _fetchAppointments() async {
    final client = Supabase.instance.client;
    List<Appointment> appointments = [];

    DateTime adjustEndTime(DateTime start, DateTime? end) {
      if (end == null || !end.isAfter(start)) {
        return start.add(const Duration(hours: 1));
      }
      return end;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final profileData = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    final profileId = profileData?['id'];
    if (profileId == null) return;

    // Personal tasks (blue)
    final tasksData = await client
        .from('tasks')
        .select()
        .eq('UID', profileId);
    if (tasksData != null && tasksData is List) {
      for (var task in tasksData) {
        final start = DateTime.tryParse(task['start_date'] ?? '');
        var end = DateTime.tryParse(task['end_date'] ?? '');
        if (start != null) {
          end = adjustEndTime(start, end);
          appointments.add(Appointment(

            startTime: start,
            endTime: end,
            subject: task['title'] ?? 'Task',
            color: Colors.blue,
            isAllDay: false,
          ));
        }
      }
    }

    // Personal events (red)
    final eventsData = await client
        .from('events')
        .select()
        .eq('UID', profileId);
    if (eventsData != null && eventsData is List) {
      for (var event in eventsData) {
          final dateStr = event['date'] ?? '';
          final timeStr = event['time'] ?? '';
          DateTime? start;
          if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
            start = DateTime.tryParse('$dateStr $timeStr');
          } else if (dateStr.isNotEmpty) {
            start = DateTime.tryParse(dateStr);
          }
          if (start != null) {
            final end = start.add(Duration(hours: 1)); // Default 1 hour duration
            appointments.add(Appointment(
              startTime: start,
              endTime: end,
              subject: event['title'] ?? 'Event',
              color: Colors.red,
              isAllDay: false,
            ));
          }
        }
    }

    // Team tasks assigned to user (green)
    final teamTaskRels = await client
        .from('TeamTask_user_rel')
        .select('TaskID')
        .eq('UID', profileId) as List<dynamic>?;
    final teamTaskIds = teamTaskRels?.map((e) => e['TaskID']).toList() ?? [];
    final teamTasksData = teamTaskIds.isEmpty
        ? []
        : await client
            .from('team_tasks')
            .select()
            .inFilter('id', teamTaskIds);
    if (teamTasksData != null && teamTasksData is List) {
      for (var teamTask in teamTasksData) {
        final start = DateTime.tryParse(teamTask['start_date'] ?? '');
        var end = DateTime.tryParse(teamTask['end_date'] ?? '');
        if (start != null) {
          end = adjustEndTime(start, end);
          appointments.add(Appointment(
            startTime: start,
            endTime: end,
            subject: teamTask['title'] ?? 'Team Task',
            color: Colors.green,
            isAllDay: false,
          ));
        }
      }
    }
      // Team events (green)
      final teamEventRels = await client
          .from('teamEvent_user_rel')
          .select('Event_ID')
          .eq('UID', profileId) as List<dynamic>?;

      final teamEventIds = teamEventRels?.map((e) => e['Event_ID']).toList() ?? [];

      final teamEventsData = teamEventIds.isEmpty
          ? []
          : await client
              .from('team_events')
              .select()
              .inFilter('id', teamEventIds);

      if (teamEventsData != null && teamEventsData is List) {
        for (var event in teamEventsData) {
          final dateStr = event['date'] ?? '';
          final timeStr = event['time'] ?? '';
          DateTime? start;
          if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
            start = DateTime.tryParse('$dateStr $timeStr');
          } else if (dateStr.isNotEmpty) {
            start = DateTime.tryParse(dateStr);
          }
          if (start != null) {
            final end = start.add(Duration(hours: 1)); 
            appointments.add(Appointment(
              startTime: start,
              endTime: end,
              subject: event['title'] ?? 'Team Event',
              color: Colors.green,
              isAllDay: false,
            ));
          }
        }
      }

    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          "Calendar",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded, color: Colors.indigo),
            onPressed: () {
              //pop info function
              _popinfo();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SfCalendar(
          backgroundColor: const Color(0xFFF9FAFB),
          headerStyle: const CalendarHeaderStyle(
            backgroundColor: Color(0xFFF9FAFB),
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          view: CalendarView.month,
          dataSource: _TaskDataSource(_appointments),
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            showAgenda: true,
            agendaItemHeight: 60,
          ),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.calendarCell) {
              DateTime selectedDate = details.date!;
            }
          },
        ),
      ),
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
          selectedItemColor: Colors.indigo, 
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          iconSize: 28,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
             if (index == 0) {
              Navigator.pushNamed(context, '/dashboard');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/teams');
            } else if (index == 3) {
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

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
