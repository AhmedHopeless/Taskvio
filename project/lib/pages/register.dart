import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _signUp() async {
  final name = _nameController.text;
  final email = _emailController.text;
  final password = _passwordController.text;
  final repeatPassword = _repeatPasswordController.text;

  if (name.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
    _showSnackBar("Please fill all fields");
    return;
  }

  if (password != repeatPassword) {
    _showSnackBar("Passwords do not match");
    return;
  }

  try {
    // Sign up using Supabase Auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.error != null) {
      // Handle error during sign-up
      _showSnackBar("Error signing up: ${response.error!.message}");
      return;
    }

    if (response.user != null) {
      // Insert into profiles table
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .insert({
            'user_id': userId,
            'name': name,
            'email': email,
            'password': password, // Avoid storing plain passwords in production
          })
          .select();

      if (profileResponse.error != null) {
        _showSnackBar("Error inserting into profiles: ${profileResponse.error!.message}");
        return;
      }

      // Show success popup
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Account successfully created!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, '/login'); // Redirect to login page
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    _showSnackBar("An error occurred: $e");
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0xFF133E87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: _repeatPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Repeat Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on PostgrestList {
  get error => null;
}

extension on AuthResponse {
  get error => null;
}