import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'JobPortal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/onboard.png', 
                  height: 250,
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  children: [
                    TextSpan(text: 'Find Your '),
                    TextSpan(
                        text: 'Dream Job',
                        style: TextStyle(color: Color(0xFFFCA61F),
                      decoration: TextDecoration.underline,
                       decorationColor: Colors.blue, 
          decorationThickness: 2.0, 
          decorationStyle: TextDecorationStyle.wavy,
                        )),
                    TextSpan(text: ' Here!'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Explore all the most exciting job roles based on your interest and study major.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13005A),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Icon(Icons.arrow_forward_rounded, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
