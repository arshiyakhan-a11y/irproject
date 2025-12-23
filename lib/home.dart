// Make sure to import your packages and screens as usual

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashionfusion/suggestion%20system/pages/chat_page.dart';
import 'package:fashionfusion/userpreferences/selfpreference.dart';
import 'package:fashionfusion/userpreferences/user_preferences.dart';
import 'aifashiongenerator.dart';
import 'recommendation_screen.dart';
import 'virtualtryon.dart';
import 'Color Hunt.dart';
import 'feedback.dart';
import 'login.dart';
import 'orderandpurchase.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({Key? key, required this.userName, required this.userEmail})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> featureButtons = [
    {
      'title': 'Self Preference',
      'icon': Icons.person,
      'screen': SelfPreferenceScreen(),
      'description': 'Customize your fashion preferences and style choices.',
    },
    {
      'title': 'Outfit Suggestion',
      'icon': Icons.checkroom,
      'screen': const Suggestion(
        color: "Red",
        weather: "Sunny",
        style: "Casual",
        bodyShape: "Hourglass",
        height: "Tall",
        occasion: "Casual",
        skinTone: "Fair", gender: 'Male',
      ),
      'description': 'Get AI-powered outfit suggestions.',
    },
    {
      'title': 'Virtual StyleMe',
      'icon': Icons.camera,
      'screen': const VirtualTryOnIntro(),
      'description': 'Try outfits virtually using augmented reality.',
    },
    {
      'title': 'Color Hunt',
      'icon': Icons.color_lens,
      'screen': const ColorHuntExplorer(),
      'description': 'Explore color schemes for your outfits.',
    },
    {
      'title': 'Order & Purchase',
      'icon': Icons.shopping_cart,
      'screen': const Order(),
      'description': 'Shop for your favorite outfits seamlessly.',
    },
    {
      'title': 'AI Fashion Generator',
      'icon': Icons.brush,
      'screen': FashionDesignerScreen(),
      'description': 'Create unique fashion designs with AI.',
    },
    {
      'title': 'AI Gallery',
      'icon': Icons.photo_library,
      'screen': const AIGalleryScreen(),
      'description': 'View and manage your saved AI fashion designs.',
    },
    {
      'title': 'Feedback',
      'icon': Icons.feedback,
      'screen': const FeedbackModule(),
      'description': 'Share your feedback and help us improve.',
    },
  ];

  final List<String> dressImages = [
    'assets/aaa.jpg',
    'assets/ab.jpg',
    'assets/abc.jpg',
    'assets/download.jpeg',
  ];

  late final ScrollController _scrollController;
  late Timer _timer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 2;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
          _scrollController.jumpTo(_scrollPosition);
        } else  {
          _scrollController.animateTo(
            _scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridFeatures = featureButtons.sublist(0, 6);
    final sliderFeatures = featureButtons.sublist(6);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fashion Fusion',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal.shade100,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.teal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.userEmail,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.contact_support, color: Colors.teal),
                title: const Text('Contact Us'),
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: const Text('About Us'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.teal),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const Login()));
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: dressImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(dressImages[index]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Core Features',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: gridFeatures.length,
              itemBuilder: (context, index) {
                final feature = gridFeatures[index];
                return InkWell(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => feature['screen'])),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.teal.shade400, width: 2),
                    ),
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(feature['icon'], size: 36.0, color: Colors.teal),
                          const SizedBox(height: 10.0),
                          Text(
                            feature['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6.0),
                          Flexible(
                            child: Text(
                              feature['description'],
                              style: const TextStyle(
                                  fontSize: 11.0, color: Colors.black54),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              "More Features",
              style: TextStyle(
                color: Colors.teal.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.75),
                itemCount: sliderFeatures.length,
                itemBuilder: (context, index) {
                  final feature = sliderFeatures[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => feature['screen'])),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.teal.shade500, width: 2),
                        ),
                        elevation: 6,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(feature['icon'], size: 38, color: Colors.teal),
                              const SizedBox(height: 10),
                              Text(
                                feature['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  feature['description'],
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
