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

  Future<void> _fetchAppointments() async {
    final client = Supabase.instance.client;
    List<Appointment> appointments = [];

    // Helper to adjust end time if needed
    DateTime adjustEndTime(DateTime start, DateTime? end) {
      if (end == null || !end.isAfter(start)) {
        // If end is null or not after the start, add one hour
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
            final end = start.add(Duration(hours: 1)); // Default 1 hour duration
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

    // Debug print to check appointments
    print("Loaded appointments: $appointments");

    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Calendar",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: Colors.black)),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_outline, color: Colors.black)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SfCalendar(
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
              // TODO: Future - Navigate to detailed tasks/events page
              print('Tapped on: $selectedDate');
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
          selectedItemColor: Colors.indigo, // Replace with your desired color
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

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
