import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4EC6B8), // Teal background, match your template
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // White circle with app initials or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'SDP', // Student Dropout Predictor initials, or use an Icon if you prefer
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4EC6B8),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Student Dropout Predictor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}