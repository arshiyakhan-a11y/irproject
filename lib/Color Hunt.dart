import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashionfusion/home.dart';
import 'package:fashionfusion/recommendation_screen.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'color.dart';
import 'login.dart';

class ColorHuntExplorer extends StatefulWidget {
  const ColorHuntExplorer({Key? key}) : super(key: key);

  @override
  _ColorHuntExplorerState createState() => _ColorHuntExplorerState();
}

class _ColorHuntExplorerState extends State<ColorHuntExplorer> {
  var slides = <Slide>[];
  int currentIndex = 0;

  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();

    // --------------------------
    // IR / Data Mining Concept
    // --------------------------
    // Get logged-in user info from FirebaseAuth
    // This can act as a user profile for personalized recommendations.
    final user = FirebaseAuth.instance.currentUser;
    userName = user?.displayName ?? "Guest User";
    userEmail = user?.email ?? "guest@example.com";

    // --------------------------
    // Slide 1: Basic IR/Clustering Example
    // --------------------------
    // Show users a general introduction slide.
    slides.add(
      Slide(
        title: "Explore Color Schemes",
        description:
        "Discover vibrant color schemes to elevate your outfit choices. Perfect combinations to suit every style!",
        pathImage: "assets/ccc.png",
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

    // --------------------------
    // Slide 2: Personalized Recommendation (Data Mining Concepts)
    // --------------------------
    // This slide introduces IR (Information Retrieval) and Association Rules
    // to suggest color schemes based on previous user behavior.
    slides.add(
      Slide(
        widgetTitle: Container(
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/ccc.png",
                height: 350,
                width: 250,
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose Your Palette",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  height: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Click below to explore and select color schemes for your outfits.",
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
                  // --------------------------
                  // IR / Clustering Concept
                  // --------------------------
                  // This button navigates to a WebView where users can explore
                  // color palettes. Behind the scenes, the app could retrieve
                  // relevant palettes using IR techniques (matching user's favorite colors)
                  // or cluster colors based on similarity for better recommendations.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ColorHuntWebView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  backgroundColor: Colors.white,
                ),
                child: const Text("Explore Color Schemes"),
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
          // --------------------------
          // Classification / Personalization
          // --------------------------
          // After the intro, navigate to HomeScreen.
          // Here, the app could classify users based on profile info
          // or previous selections to recommend personalized palettes
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
          // Same as onDonePress, allows skipping intro
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
          // --------------------------
          // Tracking / Data Mining
          // --------------------------
          // Here you could track which slide the user is viewing
          // and use it as input for clustering or association rule mining
          // to improve future recommendations.
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
