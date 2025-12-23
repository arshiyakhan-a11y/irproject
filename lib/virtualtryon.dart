import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashionfusion/virtual.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:fashionfusion/login.dart';

import 'home.dart';  // Your home screen that expects userName and userEmail

class VirtualTryOnIntro extends StatefulWidget {
  const VirtualTryOnIntro({Key? key}) : super(key: key);

  @override
  _VirtualTryOnIntroState createState() => _VirtualTryOnIntroState();
}

class _VirtualTryOnIntroState extends State<VirtualTryOnIntro> {
  var slides = <Slide>[];
  int currentIndex = 0;

  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();

    // Get current logged-in user info
    final user = FirebaseAuth.instance.currentUser;
    userName = user?.displayName ?? "Guest User";
    userEmail = user?.email ?? "guest@example.com";

    slides.add(
      Slide(
        title: "Virtual StyleMe",
        description:
        "Experience fashion like never before! Virtually try on outfits to find the perfect look without stepping into a store.",
        pathImage: "assets/bb.png",
        heightImage: 350,
        widthImage: 250,
        backgroundColor: Colors.teal,
        styleTitle: const TextStyle(
          color: Colors.white,
          fontSize: 28.0,
          height: 2,
          fontWeight: FontWeight.bold,
        ),
        styleDescription: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    slides.add(
      Slide(
        widgetTitle: Container(
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/bb.png",
                height: 350,
                width: 250,
              ),
              const SizedBox(height: 20),
              const Text(
                "Virtual Try-On",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  height: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Click the button below to start trying outfits virtually!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyWebsite()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  backgroundColor: Colors.white,
                ),
                child: const Text("Start Virtual StyleMe"),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        slides: slides,
        colorActiveDot: Colors.white,
        showNextBtn: true,
        showSkipBtn: true,
        skipButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        nextButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        doneButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        onDonePress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userName!,
                userEmail: userEmail!,
              ),
            ),
          );
        },
        onSkipPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userName!,
                userEmail: userEmail!,
              ),
            ),
          );
        },
        onTabChangeCompleted: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
