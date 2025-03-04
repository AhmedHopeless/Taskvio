
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      theme: ThemeData(
        primaryColor: Color(0xFF133E87), 
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255), 
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in your account', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF133E87), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF133E87)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF133E87)),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF133E87)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF133E87)),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF133E87))),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF133E87), 
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Text('Or login with', style: TextStyle(color: Color(0xFF133E87))),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Image.asset('google.png'),
                  onPressed: () {
                
                  },
                ),
                IconButton(
                  icon: Image.asset('facebook.png'),
                  onPressed: () {
                    
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle registration
              },
              child: Text('Don\'t have an account? Register', style: TextStyle(color: Color(0xFF133E87))),
            ),
          ],
        ),
      ),
    );
  }
}