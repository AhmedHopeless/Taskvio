import 'package:flutter/material.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<Dashboard> {
  final Color primaryColor = Color(0xFF133E87);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teams'),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed_rounded),
            label: 'Focus Mode',
          ),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taskvio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.black54),
                      SizedBox(width: 10),
                      Icon(Icons.settings, color: Colors.black54),
                      SizedBox(width: 10),
                      CircleAvatar(backgroundColor: Colors.grey.shade300),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Today's Goal Card
              Container(
                padding: EdgeInsets.only(
                  left: 30,
                  top: 16,
                  right: 30,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Goal",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "3/9 Objectives completed",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    Center(
                      child: Container(
                        child: Stack(
                          alignment: Alignment.center,

                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: 3 / 9,
                                backgroundColor: Colors.white38,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "3/9",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Tasks & Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularProgress('Tasks', 2, 7, 0xFF40C4FF),
                  _buildCircularProgress('Events', 1, 2, 0xFFFF5252),
                ],
              ),
              SizedBox(height: 20),
              // Calendar Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        int startNumber =
                            30; // Change this to any starting number you want
                        int displayIndex = (startNumber + index) % 31 + 1;
                        int count = index + 1;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  count == 4
                                      ? primaryColor
                                      : Colors.transparent,
                              child: Text(
                                "$displayIndex",
                                style: TextStyle(
                                  color:
                                      count == 4 ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 320, // Adjust the height as needed
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTaskItem("11:00 AM", const Color(0xFF40C4FF)),
                            _buildTaskItem("12:00 PM", Colors.lightBlueAccent),
                            _buildTaskItem("12:30 PM", const Color(0xFFFF5252)),
                            _buildTaskItem("1:00 PM", Colors.lightBlueAccent),
                            _buildTaskItem("2:00 PM", Colors.lightBlueAccent),
                            _buildTaskItem("5:30 PM", Colors.redAccent),
                            _buildTaskItem("7:00 PM", Colors.lightBlueAccent),
                            _buildTaskItem("10:00 PM", Colors.lightBlueAccent),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(String title, int completed, int total, int color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,

          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: completed / total,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(Color(color)),
              ),
            ),
            Text(
              "$completed/$total",
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time, style: TextStyle(fontSize: 16, color: Colors.white)),
            Icon(Icons.more_horiz, color: Colors.white),
          ],
        ),
      ),
    );
  }
}