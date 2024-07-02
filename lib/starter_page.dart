// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'sound_page.dart';

class StarterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Path to the background image in your project's assets folder
              fit: BoxFit.cover, // Cover the entire widget's area without distortion
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(42.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30),
                Text(
                  'Hi, I am EarAI,',
                  style: TextStyle(
                    fontSize: 34, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8), // Added space
                Text(
                  'your deaf assistant.',
                  style: TextStyle(
                    fontSize: 34, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18), // More space before the text field
                Text(
                  'To help you better, I would like to know your name.',
                  style: TextStyle(
                    fontSize: 12, // Adjusted for subtext
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 90), // Space before input field
                Text(
                  'How would you like me to call you?',
                  style: TextStyle(
                    fontSize: 18, // Adjusted for subtext
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    // fillcolor transparent to avoid background color
                    fillColor: Colors.transparent,
                    hintText: 'Please Enter',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16), // Space before the button
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SoundPage()),
                        );
                      },
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Correct property for background color
                        minimumSize: Size(double.infinity, 50), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Button border radius
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
