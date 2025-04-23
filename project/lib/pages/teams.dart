import 'package:flutter/material.dart';

class TaskvioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskvio',
      debugShowCheckedModeBanner: false,
      home: TeamsScreen(),
      routes: {
        '/home': (context) => Placeholder(), // Replace with actual home screen
        '/calendar': (context) => Placeholder(), // Replace with actual calendar screen
        '/teams': (context) => TeamsScreen(), // Current screen
        '/focus': (context) => Placeholder(), // Replace with actual focus mode screen
      },
    );
  }
}

class TeamsScreen extends StatefulWidget {
  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final String currentUser = "Noor Mohamed";
  final Color primaryBlue = const Color(0xFF133E87);
  int _currentIndex = 2;

  final List<Map<String, String>> teams = [
    {"name": "E-commerce project", "creator": "Noor Mohamed"},
    {"name": "Graduation project", "creator": "Noor Mohamed"},
    {"name": "Team Alpha", "creator": "Jeff"},
    {"name": "Team Beta", "creator": "Noor Mohamed"},
    {"name": "Team Omega", "creator": "Samir"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/calendar');
          } else if (index == 2) {
            // Already on Teams, do nothing
          } else if (index == 3) {
            Navigator.pushNamed(context, '/focus');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed_rounded), label: 'Focus Mode'),
        ],
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taskvio',
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none, color: Colors.black87),
                      SizedBox(width: 12),
                      Icon(Icons.settings, color: Colors.black87),
                      SizedBox(width: 12),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(Icons.person, size: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Teams',
                style: TextStyle(
                  fontSize: 28,
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue),
                  ),
                  child: Text('New Team'),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: teams.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final isUserTeam = team["creator"] == currentUser;

                    final card = Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: primaryBlue,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.folder, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    team["name"]!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isUserTeam)
                                  Icon(Icons.more_vert, color: Colors.white70),
                              ],
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'by ${team["creator"]!}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    return isUserTeam
                        ? InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(16),
                            child: card,
                          )
                        : card;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
