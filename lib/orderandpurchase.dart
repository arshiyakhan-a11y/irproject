import 'package:fashionfusion/virtual.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:fashionfusion/login.dart';
import 'package:fashionfusion/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onlineorder.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  var slides = <Slide>[];
  int currentIndex = 0;

  // --------------------------
  // Data Mining Concept:
  // --------------------------
  // User information can be used for personalization:
  // - Collaborative Filtering: Recommend products based on similar users
  // - User Profiling: Track favorite styles/colors for tailored suggestions
  String userName = "Guest";
  String userEmail = "guest@example.com";

  @override
  void initState() {
    super.initState();

    // Get Firebase logged-in user info
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName = user.displayName ?? "User";
      userEmail = user.email ?? "user@example.com";
    }

    // Slide 1: Introduction to Virtual Try-On
    slides.add(
      Slide(
        title: "Virtual StyleMe",
        description:
        "Experience fashion like never before! Virtually try on outfits to find the perfect look without stepping into a store.",
        pathImage: "assets/lll.png",
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

    // Slide 2: Order & Purchase
    slides.add(
      Slide(
        widgetTitle: Column(
          children: <Widget>[
            Image.asset(
              "assets/lll.png",
              height: 350,
              width: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Order and Purchase",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                height: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Click the button below to start trying outfits and order it!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // --------------------------
            // Data Mining Concept:
            // --------------------------
            // This button triggers Virtual Try-On.
            // Backend can:
            // 1. Collect try-on data for the user (preferences, sizes, styles)
            // 2. Apply clustering on garments to suggest similar items
            // 3. Use recommendation algorithms (content-based + collaborative filtering)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AiStylistPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.teal,
                backgroundColor: Colors.white,
              ),
              child: const Text("Start Order and Purchase"),
            ),
          ],
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userName,
                userEmail: userEmail,
              ),
            ),
          );
        },
        onSkipPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userName,
                userEmail: userEmail,
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
