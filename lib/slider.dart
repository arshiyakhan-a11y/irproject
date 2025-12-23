import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'home.dart'; // Make sure HomeScreen accepts userName and userEmail params

class SliderScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SliderScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _SliderScreenState createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  late List<Slide> slides;

  @override
  void initState() {
    super.initState();

    slides = [
      Slide(
        title: "Self Preference",
        description:
        "Customize your fashion preferences including your style, body shape, and skin tone.",
        pathImage: "assets/xxx.png",
        heightImage: 350,
        widthImage: 250,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "Outfit Suggestion",
        description:
        "Get AI-powered outfit suggestions based on weather, occasion, and your preferences.",
        pathImage: "assets/xxx.png",
        heightImage: 320,
        widthImage: 260,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "Virtual StyleMe",
        description:
        "Try on outfits in real-time using your phone camera and AR technology.",
        pathImage: "assets/xxx.png",
        heightImage: 330,
        widthImage: 250,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "Color Hunt",
        description:
        "Explore trendy color palettes curated to complement your personal style.",
        pathImage: "assets/xxx.png",
        heightImage: 320,
        widthImage: 260,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "Order and Purchase",
        description:
        "Seamlessly order your favorite outfits and track your purchases.",
        pathImage: "assets/xxx.png",
        heightImage: 320,
        widthImage: 260,
        backgroundColor:const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "AI Fashion Generator",
        description:
        "Create unique outfit ideas using AI-powered fashion generation tools.",
        pathImage: "assets/xxx.png",
        heightImage: 330,
        widthImage: 250,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Slide(
        title: "Explore More",
        description:
        "Discover new trends and keep your style fresh every day.",
        pathImage: "assets/xxx.png",
        heightImage: 320,
        widthImage: 260,
        backgroundColor: const Color(0xFFB2EBF2),
        styleTitle: const TextStyle(
          color: Colors.teal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];
  }

  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        slides: slides,
        colorActiveDot: Colors.teal.shade700,
        showNextBtn: true,
        showSkipBtn: true,
        skipButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.teal,
        ),
        nextButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.teal,
        ),
        doneButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.teal,
        ),
        onDonePress: navigateToHome,
        onSkipPress: navigateToHome,
        onTabChangeCompleted: (index) {
          // Optional: do something when slide changes
        },
      ),
    );
  }
}
