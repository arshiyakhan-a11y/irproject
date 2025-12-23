import 'package:flutter/material.dart';

import '../../userpreferences/selfpreference.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Advisor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Enter Preferences'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelfPreferenceScreen()),
              ),
            ),
            ElevatedButton(
              child: const Text('Get Suggestions'),
              onPressed: () {
                // You need to provide sample or fetched values for color, weather, style, bodyShape, height, occasion, and skinTone
                String color = "Red";       // Example
                String weather = "Sunny";    // Example
                String style = "Casual";     // Example
                String bodyShape = "Hourglass"; // Example
                String height = "Tall";       // Example
                String occasion = "Casual";   // Example
                String skinTone = "Fair";     // Example

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Suggestion(
                      color: color,
                      weather: weather,
                      style: style,
                      bodyShape: bodyShape,
                      height: height,
                      occasion: occasion,
                      skinTone: skinTone,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Suggestion extends StatelessWidget {
  final String color;
  final String weather;
  final String style;
  final String bodyShape;
  final String height;
  final String occasion;
  final String skinTone;

  const Suggestion({super.key, 
    required this.color,
    required this.weather,
    required this.style,
    required this.bodyShape,
    required this.height,
    required this.occasion,
    required this.skinTone,
  });

  @override
  Widget build(BuildContext context) {
    // You can customize the UI based on the suggestions here.
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Suggestions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Color: $color'),
            Text('Weather: $weather'),
            Text('Style: $style'),
            Text('Body Shape: $bodyShape'),
            Text('Height: $height'),
            Text('Occasion: $occasion'),
            Text('Skin Tone: $skinTone'),
            // Add more UI components to show fashion suggestions here
          ],
        ),
      ),
    );
  }
}
