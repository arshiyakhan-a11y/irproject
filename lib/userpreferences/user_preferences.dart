// user_preferences.dart

class UserPreferences {
  final String name;
  final int age;
  final String gender;
  final String bodyType;
  final String skinTone;
  final List<String> preferredStyles;
  final List<String> favoriteColors;
  final List<String> avoidColors;
  final List<String> favoriteBrands;
  final Map<String, String> occasionPreferences;
  final String season;
  final List<String> preferredFabrics;
  final double budget;
  final List<String> dos;
  final List<String> donts;

  UserPreferences({
    required this.name,
    required this.age,
    required this.gender,
    required this.bodyType,
    required this.skinTone,
    required this.preferredStyles,
    required this.favoriteColors,
    required this.avoidColors,
    required this.favoriteBrands,
    required this.occasionPreferences,
    required this.season,
    required this.preferredFabrics,
    required this.budget,
    required this.dos,
    required this.donts,
  });

  // Factory method for easier construction
  static UserPreferences getInstance({
    required String name,
    required int age,
    required String gender,
    required String bodyType,
    required String skinTone,
    required List<String> preferredStyles,
    required List<String> favoriteColors,
    required List<String> avoidColors,
    required List<String> favoriteBrands,
    required Map<String, String> occasionPreferences,
    required String season,
    required List<String> preferredFabrics,
    required double budget,
    required List<String> dos,
    required List<String> donts,
  }) {
    return UserPreferences(
      name: name,
      age: age,
      gender: gender,
      bodyType: bodyType,
      skinTone: skinTone,
      preferredStyles: preferredStyles,
      favoriteColors: favoriteColors,
      avoidColors: avoidColors,
      favoriteBrands: favoriteBrands,
      occasionPreferences: occasionPreferences,
      season: season,
      preferredFabrics: preferredFabrics,
      budget: budget,
      dos: dos,
      donts: donts,
    );
  }

  // Stub for saving preferences (replace with actual implementation)
  Future<void> savePreferences() async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Saved User Preferences:');
    print('Name: $name');
    print('Age: $age');
    print('Gender: $gender');
    print('Body Type: $bodyType');
    print('Skin Tone: $skinTone');
    print('Season: $season');
    print('Budget: \$${budget.toStringAsFixed(2)}');
  }
}
