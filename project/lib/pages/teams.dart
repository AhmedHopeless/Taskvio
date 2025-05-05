import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/pages/team_dashboard.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> filteredTeams = [];
  bool isLoading = false;
  bool _isFabExpanded = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserTeams() async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    final data = await Supabase.instance.client
        .from('team_user_rel')
        .select('rel_ID, TID, team_leader, teams(id, code, name, description)')
        .eq('UID', profileId) as List<dynamic>?;
    setState(() {
      teams = data
          ?.map((e) => {
                'rel_ID': e['rel_ID'],
                'TID': e['TID'],
                'team_leader': e['team_leader'],
                'team': e['teams'],
              })
          .toList() ??
          [];
      filteredTeams = teams;
    });
    print('Fetched teams: $teams');
  }

  Future<int?> _getProfileId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .limit(1) as List<dynamic>?;
    if (data != null && data.isNotEmpty) {
      return data.first['id'] as int;
    }
    return null;
  }

  Future<void> _joinTeam(String code) async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    final teamData = await Supabase.instance.client
        .from('teams')
        .select('id')
        .eq('code', code)
        .maybeSingle();
    if (teamData == null) {
      _showSnackBar('Team not found');
      return;
    }
    final teamId = teamData['id'];
    // Check if already a member
    final existing = await Supabase.instance.client
        .from('team_user_rel')
        .select()
        .eq('UID', profileId)
        .eq('TID', teamId) as List<dynamic>?;
    if (existing != null && existing.isNotEmpty) {
      _showSnackBar('Already a member');
      return;
    }
    await Supabase.instance.client.from('team_user_rel').insert({
      'UID': profileId,
      'TID': teamId,
      'team_leader': false,
    });
    _showSnackBar('Joined team!');
    await _fetchUserTeams();
  }

  Future<void> _createTeam(String name, String description) async {
    final profileId = await _getProfileId();
    if (profileId == null) return;

    final code = _generateTeamCode();

    // Insert the team and get the inserted row (with id)
    final teamInsert = await Supabase.instance.client
        .from('teams')
        .insert({
          'code': code,
          'name': name,
          'description': description,
        })
        .select()
        .single();

    final teamId = teamInsert['id'];

    // Now insert into team_user_rel
    await Supabase.instance.client.from('team_user_rel').insert({
      'UID': profileId,
      'TID': teamId,
      'team_leader': true,
    });

    _showSnackBar('Team created!');
    await _fetchUserTeams();
  }

  Future<void> _deleteTeam(int teamId) async {
    final profileId = await _getProfileId();
    if (profileId == null) return;
    // Check if user is leader
    final rel = await Supabase.instance.client
        .from('team_user_rel')
        .select('team_leader')
        .eq('UID', profileId)
        .eq('TID', teamId)
        .maybeSingle();
    if (rel == null || rel['team_leader'] != true) {
      _showSnackBar('Only the team leader can delete the team.');
      return;
    }
    await Supabase.instance.client.from('teams').delete().eq('id', teamId);
    await Supabase.instance.client.from('team_user_rel').delete().eq('TID', teamId);
    _showSnackBar('Team deleted!');
    await _fetchUserTeams();
  }

  String _generateTeamCode() {
    // Simple random code generator
    final rand = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return 'T$rand';
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
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
                          _createTeam(
                              _teamNameController.text, _teamDescController.text);
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

  void _showJoinTeamDialog() {
    TextEditingController _joinTeamCodeController = TextEditingController();

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
                Text('Join Team',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _joinTeamCodeController,
                  decoration: InputDecoration(
                    labelText: 'Team Code',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_joinTeamCodeController.text.isNotEmpty) {
                          _joinTeam(_joinTeamCodeController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Join'),
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
                            filteredTeams = teams.cast<Map<String, String>>();
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

  void _deleteTeamDialog(int index) {
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
            onPressed: () async {
              final teamId = teams[index]['TID'];
              if (teamId != null) {
                await _deleteTeam(teamId);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _filterTeams(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTeams = teams;
      } else {
        filteredTeams = teams.where((teamMap) {
          final team = teamMap['team'];
          final name = (team['name'] ?? '').toLowerCase();
          final desc = (team['description'] ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildTeamCard(Map<String, dynamic> teamMap, int index) {
    final team = teamMap['team']; // This is the nested map with name, code, etc.

    return ListTile(
      title: Text(team['name'] ?? ''),
      subtitle: Text(team['description'] ?? ''),
      // ...other widgets
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                      _filterTeams(value);
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
                            final teamMap = filteredTeams[index];
                            final team = teamMap['team'];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Icon(Icons.group, color: Colors.indigo),
                                ),
                                title: Text(
                                  team['name'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  team['description'] ?? '',
                                  style: GoogleFonts.poppins(),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TeamDashboard(tid: team['id'])),
                                  );
                                  if (result == true) {
                                    // Team was deleted or left, so refresh the list
                                    _fetchUserTeams();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ScaleTransition(
            scale: _fabAnimation,
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140.0),
              child: FloatingActionButton.extended(
                heroTag: 'joinTeam',
                onPressed: () {
                  _toggleFab();
                  _showJoinTeamDialog();
                },
                label: Text('Join Team'),
                icon: Icon(Icons.group_add),
              ),
            ),
          ),
          ScaleTransition(
            scale: _fabAnimation,
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton.extended(
                heroTag: 'createTeam',
                onPressed: () {
                  _toggleFab();
                  _showCreateTeamDialog();
                },
                label: Text('Create Team'),
                icon: Icon(Icons.add),
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: _toggleFab,
            backgroundColor: Colors.indigo,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _fabAnimationController,
            ),
          ),
        ],
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