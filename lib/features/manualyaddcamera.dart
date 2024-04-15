import 'package:flutter/material.dart';

class ManualAddCamera extends StatelessWidget {
  const ManualAddCamera({Key? key});

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Color(0xFF005697);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Handle back button pressed
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 0,
                  ), // Adjust spacing between back button and title
                  Text(
                    'Setup Camera',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Positioned.fill(
            top: kToolbarHeight + 50, // Adjust top position for content
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Camera Name',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    _buildInputField("Camera Name"),
                    SizedBox(height: 20),
                    Text(
                      'IP Address',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    _buildInputField("IP Address"),
                    SizedBox(height: 20),
                    Text(
                      'Username',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    _buildInputField("Username"),
                    SizedBox(height: 20),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    _buildInputField("Password", isObscureText: true),
                    SizedBox(height: 20),
                    ElevatedButton( // Add Camera Button
                      onPressed: () {
                        // Add camera logic here
                      },
                      child: Text(
                        'Add Camera',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: 'Montserrat'),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, {bool isObscureText = false}) {
    return TextField(
      obscureText: isObscureText,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
    );
  }
}
