import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      resizeToAvoidBottomInset: false, // Prevents the body from resizing
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          // padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
              padding: EdgeInsets.only(top: 50, left: 20),
              color: Color(0xFF0A3875),
              height: 180,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    "Sign in to your",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "Welcome back!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [

              SizedBox(height: 70),
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

            SizedBox(height: 30), // Space after email field

            // Password Field
            TextField(
              obscureText: _obscureText, // Use _obscureText here
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF133E87)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF133E87)),
                ),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _obscureText
                        ? 'assets/icons/hidden.png'
                        : 'assets/icons/visible.png', // Custom icons
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 1), // Space after password field

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF133E87)),
                ),
              ),
            ),
            SizedBox(height: 20), // Space after forgot password

            // Login Button
            SizedBox(
              width: double.infinity, // Full-width button
              child: ElevatedButton(
                onPressed: () {
                  // Handle login
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF133E87), // Text color set to white
                  padding: EdgeInsets.symmetric(vertical: 16), // Button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                ),
                child: Text('Login'),
              ),
            ),
            SizedBox(height: 60), // Space after login button

            // Divider with "Or login with"
            Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.grey, // Gray split line
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Or login with',
                    style: TextStyle(color: Colors.grey), // Gray text
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey, // Gray split line
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 60), // Space after divider

            // Google and Facebook Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Google Button
                ElevatedButton(
                  onPressed: () {
                    _handleGoogleLogin(); // Handle Google login
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // Text color set to black
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Rounded corners
                      side: BorderSide(color: Colors.grey), // Gray border
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/google.png', // Google icon
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 14, // Smaller font size
                          color: Colors.black, // Text color set to black
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16), // Space between Google and Facebook
                // Facebook Button
                ElevatedButton(
                  onPressed: () {
                    _handleFacebookLogin(); // Handle Facebook login
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // Text color set to black
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Rounded corners
                      side: BorderSide(color: Colors.grey), // Gray border
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/facebook.png', // Facebook icon
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Facebook',
                        style: TextStyle(
                          fontSize: 14, // Smaller font size
                          color: Colors.black, // Text color set to black
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Space after buttons

            // "Don't have an account? Register"
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                'Don\'t have an account? Register',
                style: TextStyle(
                  color: Color(0xFF133E87), // Text color set to #133E87
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

  // Function to handle Google login
  void _handleGoogleLogin() {
    print('Google login pressed');
    // Add your Google login logic here
  }

  // Function to handle Facebook login
  void _handleFacebookLogin() {
    print('Facebook login pressed');
    // Add your Facebook login logic here
  }
}
