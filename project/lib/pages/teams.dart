import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<Map<String, String>> teams = [];
  List<Map<String, String>> filteredTeams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a delay for loading teams
    // await Future.delayed(const Duration(seconds: 2));

    setState(() {
      teams = [
        {
          'name': 'Design Team',
          'description': 'Handles all UI/UX designs',
          'members': '5'
        },
        {
          'name': 'Development Team',
          'description': 'Builds the product',
          'members': '8'
        },
        {
          'name': 'Marketing Team',
          'description': 'Promotes the product',
          'members': '4'
        },
      ];
      filteredTeams = teams;
      isLoading = false;
    });
  }

  void _showCreateTeamDialog() {
    TextEditingController _teamNameController = TextEditingController();
    TextEditingController _teamDescController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create Team',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _teamDescController,
                  decoration: InputDecoration(
                    labelText: 'Team Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_teamNameController.text.isNotEmpty) {
                          setState(() {
                            teams.add({
                              'name': _teamNameController.text,
                              'description': _teamDescController.text,
                              'members': '0',
                            });
                            filteredTeams = teams;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTeamDialog(int index) {
    TextEditingController _teamNameController =
        TextEditingController(text: teams[index]['name']);
    TextEditingController _teamDescController =
        TextEditingController(text: teams[index]['description']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Team',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _teamDescController,
                  decoration: InputDecoration(
                    labelText: 'Team Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_teamNameController.text.isNotEmpty) {
                          setState(() {
                            teams[index] = {
                              'name': _teamNameController.text,
                              'description': _teamDescController.text,
                              'members': teams[index]['members'] ?? '0',
                            };
                            filteredTeams = teams;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTeam(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team'),
        content: Text('Are you sure you want to delete this team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                teams.removeAt(index);
                filteredTeams = teams;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

 Widget _buildTeamCard(Map<String, String> team, int index) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/team_dashboard');
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.indigo.shade100,
            child: Icon(Icons.group, color: Colors.indigo, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team['name'] ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  team['description'] ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 6),
                Text(
                  'Members: ${team['members'] ?? '0'}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditTeamDialog(index);
              } else if (value == 'delete') {
                _deleteTeam(index);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        title: Text("Teams (${filteredTeams.length})"),
        
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        filteredTeams = teams
                            .where((team) => team['name']!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search teams...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_off_outlined,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                "No teams available. Create one!",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            return _buildTeamCard(filteredTeams[index], index);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTeamDialog,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        iconSize: 28,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/calendar');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/focus');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: 'Focus'),
        ],
      ),
    );
  }
}
