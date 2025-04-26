import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = _generateAppointments();
  }

  List<Appointment> _generateAppointments() {
    return <Appointment>[
      Appointment(
        startTime: DateTime.now().add(Duration(hours: 2)),
        endTime: DateTime.now().add(Duration(hours: 3)),
        subject: 'Task 1',
        color: Colors.red,
      ),
      Appointment(
        startTime: DateTime.now().add(Duration(days: 1, hours: 2)),
        endTime: DateTime.now().add(Duration(days: 1, hours: 3)),
        subject: 'Event 1',
        color: Colors.blue,
      ),
      Appointment(
        startTime: DateTime.now().add(Duration(days: 1, hours: 5)),
        endTime: DateTime.now().add(Duration(days: 1, hours: 6)),
        subject: 'Task 2',
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Calendar", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none, color: Colors.black)),
          IconButton(onPressed: () {}, icon: Icon(Icons.person_outline, color: Colors.black)),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Set the current index to Calendar
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home page
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // Navigate to Teams page
            Navigator.pushNamed(context, '/teams');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Focus'),
        ],
      ),
    );
  }
}

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
