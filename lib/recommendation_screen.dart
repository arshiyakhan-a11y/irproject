import 'package:fashionfusion/userpreferences/user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Outfit extends StatelessWidget {
  final UserPreferences? userPreferences;

  Outfit({required this.userPreferences});

  @override
  Widget build(BuildContext context) {
    // If no preferences are provided, show a message prompting the user to set preferences
    if (userPreferences == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Outfit Recommendations'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text("Please set your preferences first."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Outfit Recommendations'),
        backgroundColor: Colors.teal,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 10, // Example: 10 recommended outfits
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      'https://via.placeholder.com/150', // Example image
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outfit ${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recommended for ${userPreferences!.preferredStyles.isNotEmpty ? userPreferences?.preferredStyles.first : "Casual"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
