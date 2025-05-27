import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamMembersPage extends StatefulWidget {
  final List<Map<String, dynamic>> teamMembers;
  final bool isLeader;
  final int teamId; 

  const TeamMembersPage({
    Key? key,
    required this.teamMembers,
    required this.isLeader,
    required this.teamId,
  }) : super(key: key);

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  late List<Map<String, dynamic>> _members;

  @override
  void initState() {
    super.initState();
    _members = List<Map<String, dynamic>>.from(widget.teamMembers);
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {

    await Supabase.instance.client
        .from('team_user_rel')
        .delete()
        .eq('UID', member['UID'])
        .eq('TID', widget.teamId);


    await Supabase.instance.client
        .from('TeamTask_user_rel')
        .delete()
        .eq('UID', member['UID']);

    await Supabase.instance.client
        .from('teamEvent_user_rel')
        .delete()
        .eq('UID', member['UID']);

    setState(() {
      _members.removeWhere((m) => m['UID'] == member['UID']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member['profileName']} removed from team')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Members')),
      body: ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                (member['profileName']?.isNotEmpty ?? false)
                    ? member['profileName'][0]
                    : '?',
              ),
            ),
            title: Text(member['profileName'] ?? ''),
            subtitle: Text(member['email'] ?? ''),
            trailing: widget.isLeader && !(member['team_leader'] ?? false)
                ? IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeMember(member),
                  )
                : null,
          );
        },
      ),
    );
  }
}
