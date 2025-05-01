import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
   bool _isLoading = false; // Loading state


  bool _isPasswordVisible = false;
  String? _errorText;
  double _passwordStrength = 0;

  Future<void> _signUp() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final repeatPassword = _repeatPasswordController.text;

  setState(() => _errorText = null);

  if (name.isEmpty || email.isEmpty) {
    setState(() => _errorText = "Please fill all fields");
    return;
  }

  if (password != repeatPassword) {
    setState(() => _errorText = "Passwords do not match");
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Create the user in Supabase auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Registration failed. Please try again.");
    }

    final user = response.user;
    if (user != null) {
      // Insert additional profile data into your table "profiles"
      final insertResponse = await Supabase.instance.client
          .from('profiles')
          .insert({
            'user_id': user.id,
            'name': name, // full name
            'email': email,
            'password': password, // caution: storing raw passwords is not secure
            'created_at': DateTime.now().toIso8601String(),
          });

      // // Check for null or error in the response.
      // if (insertResponse == null || insertResponse.error != null) {
      //   throw insertResponse?.error ?? Exception("Insert failed");
      // }
    }


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Registration Successful"),
        content: Text("Your account has been created. You can now log in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to login
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  } catch (e) {
    _showSnackBar("An error occurred: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    setState(() {
      _passwordStrength = strength.clamp(0, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "logo",
                child: Icon(Icons.app_registration_outlined, size: 64, color: Color(0xFF3F51B5)),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: _checkPasswordStrength,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _passwordStrength,
                backgroundColor: Colors.grey[300],
                color: _passwordStrength > 0.7 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _repeatPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Repeat Password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorText!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 24),
              _isLoading
                ? CircularProgressIndicator()
              :SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Register',
                    style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to login with slide transition
                },
                child: Text(
                  "Already have an account? Log in",
                  style: GoogleFonts.roboto(color: Color(0xFF3F51B5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}