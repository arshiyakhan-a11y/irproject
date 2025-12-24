import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

/// Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Preference App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SelfPreferenceScreen(),
    );
  }
}

/// Multi-step preference form screen
class SelfPreferenceScreen extends StatefulWidget {
  const SelfPreferenceScreen({super.key});

  @override
  _SelfPreferenceScreenState createState() => _SelfPreferenceScreenState();
}

class _SelfPreferenceScreenState extends State<SelfPreferenceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isDarkMode = false;

  final _formKeys = List.generate(8, (index) => GlobalKey<FormState>());

  // Dropdown values
  String? selectedGender, selectedStyle, selectedColor, selectedWeather;
  String? selectedBodyShape, selectedSkinTone, selectedHeight, selectedOccasion;

  // Custom input controllers
  final customGenderController = TextEditingController();
  final customStyleController = TextEditingController();
  final customColorController = TextEditingController();
  final customWeatherController = TextEditingController();
  final customBodyShapeController = TextEditingController();
  final customSkinToneController = TextEditingController();
  final customHeightController = TextEditingController();
  final customOccasionController = TextEditingController();

  // Options
  final genderOptions = ['Female', 'Male'];
  final styleOptions = ['Casual','Formal','Sporty','Streetwear','Vintage','Bohemian','Business Casual'];
  final colorOptions = ['Red','Blue','Green','Black','White','Yellow','Purple','Gray','Brown'];
  final weatherOptions = ['Summer','Winter','Rainy','All Seasons','Spring','Autumn'];
  final bodyShapeOptions = ['Slim','Athletic','Average','Plus Size','Petite','Curvy'];
  final skinToneOptions = ['Fair','Olive','Dark','Medium','Tan'];
  final heightOptions = ['Tall','Short','Average','Very Tall','Petite'];
  final occasionOptions = ['Party','Work','Casual Outing','Formal Event','Vacation','Date Night'];

  // Invalid inputs (Anomaly Detection in Data Mining)
  final Map<String, List<String>> invalidInputs = {
    'Gender': ['unknown','other'],
    'Skin Tone': ['pink','transparent','blue'],
    'Height': ['round','wide'],
    'Body Shape': ['triangle','sphere'],
    'Weather': ['ice','lava'],
    'Color': ['invisible'],
    'Style': ['lazy'],
    'Occasion': ['sleep'],
  };

  /// Validation method implementing Anomaly Detection
  bool _isValidInput(String label, String? selected, TextEditingController controller) {
    final input = controller.text.trim().toLowerCase();
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (input.isNotEmpty) {
      if (!regex.hasMatch(input)) return false;
      if (invalidInputs[label]?.contains(input) ?? false) return false; // anomaly
      return true;
    }
    return selected != null && selected.isNotEmpty;
  }

  /// Returns validation messages (Anomaly Detection)
  String? _getValidationMessage(String label, String? selected, TextEditingController controller) {
    final input = controller.text.trim();
    if (input.isEmpty && (selected == null || selected.isEmpty)) {
      return 'Please select or enter a valid $label';
    }
    if (input.isNotEmpty && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(input)) {
      return 'Only letters allowed in $label';
    }
    if (invalidInputs[label]?.contains(input.toLowerCase()) ?? false) {
      return 'The value "$input" is not valid for $label';
    }
    return null;
  }

  /// Move to next page or save preferences
  void _goToNextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage == 7) {
        savePreferences(); // Save & move to suggestion (IR & Data Mining)
      } else {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please correct the errors"))
      );
    }
  }

  /// Save preferences to SharedPreferences (acts as data storage for IR & classification)
  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('gender', customGenderController.text.isNotEmpty ? customGenderController.text : selectedGender ?? '');
    await prefs.setString('style', customStyleController.text.isNotEmpty ? customStyleController.text : selectedStyle ?? '');
    await prefs.setString('color', customColorController.text.isNotEmpty ? customColorController.text : selectedColor ?? '');
    await prefs.setString('weather', customWeatherController.text.isNotEmpty ? customWeatherController.text : selectedWeather ?? '');
    await prefs.setString('bodyShape', customBodyShapeController.text.isNotEmpty ? customBodyShapeController.text : selectedBodyShape ?? '');
    await prefs.setString('skinTone', customSkinToneController.text.isNotEmpty ? customSkinToneController.text : selectedSkinTone ?? '');
    await prefs.setString('height', customHeightController.text.isNotEmpty ? customHeightController.text : selectedHeight ?? '');
    await prefs.setString('occasion', customOccasionController.text.isNotEmpty ? customOccasionController.text : selectedOccasion ?? '');

    // Navigate to Suggestion Page where Data Mining concepts will be applied
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionPage(
          gender: prefs.getString('gender')!,
          style: prefs.getString('style')!,
          color: prefs.getString('color')!,
          weather: prefs.getString('weather')!,
          bodyShape: prefs.getString('bodyShape')!,
          skinTone: prefs.getString('skinTone')!,
          height: prefs.getString('height')!,
          occasion: prefs.getString('occasion')!,
        ),
      ),
    );
  }

  /// Hybrid dropdown + custom input field
  Widget _buildHybridDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required TextEditingController customController,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    bool isCustomEntered = customController.text.isNotEmpty;
    bool isDropdownSelected = selectedValue != null && selectedValue.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: isCustomEntered ? null : selectedValue,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: isDarkMode ? Colors.white : Colors.teal),
            filled: true,
            fillColor: isCustomEntered ? Colors.grey[300] : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: isCustomEntered
              ? null
              : (val) {
                  onChanged(val);
                  customController.clear();
                  setState(() {});
                },
          validator: (_) => _getValidationMessage(label, selectedValue, customController),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: customController,
          enabled: !isDropdownSelected,
          onChanged: (val) {
            if (val.isNotEmpty) {
              onChanged(null);
              setState(() {});
            }
          },
          decoration: InputDecoration(
            hintText: 'Or enter custom $label',
            filled: true,
            fillColor: isDropdownSelected ? Colors.grey[300] : (isDarkMode ? Colors.grey[900] : Colors.grey[100]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
          style: TextStyle(color: isDropdownSelected ? Colors.grey[600] : (isDarkMode ? Colors.white : Colors.black87)),
          validator: (_) => _getValidationMessage(label, selectedValue, customController),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPreferencePage({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required TextEditingController customController,
    required Function(String?) onChanged,
    required IconData icon,
    required int index,
  }) {
    return Form(
      key: _formKeys[index],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Step ${index + 1} of 8", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal)),
            const SizedBox(height: 24),
            _buildHybridDropdown(
              label: label,
              items: options,
              selectedValue: selectedValue,
              customController: customController,
              onChanged: onChanged,
              icon: icon,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.teal,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Fashion Preferences", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.dark_mode, color: Colors.white), onPressed: () => setState(() => isDarkMode = !isDarkMode)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildPreferencePage(label: "Gender", options: genderOptions, selectedValue: selectedGender, customController: customGenderController, onChanged: (val) => selectedGender = val, icon: Icons.person, index: 0),
                _buildPreferencePage(label: "Style", options: styleOptions, selectedValue: selectedStyle, customController: customStyleController, onChanged: (val) => selectedStyle = val, icon: Icons.style, index: 1),
                _buildPreferencePage(label: "Favorite Color", options: colorOptions, selectedValue: selectedColor, customController: customColorController, onChanged: (val) => selectedColor = val, icon: Icons.color_lens, index: 2),
                _buildPreferencePage(label: "Preferred Weather", options: weatherOptions, selectedValue: selectedWeather, customController: customWeatherController, onChanged: (val) => selectedWeather = val, icon: Icons.wb_sunny, index: 3),
                _buildPreferencePage(label: "Body Shape", options: bodyShapeOptions, selectedValue: selectedBodyShape, customController: customBodyShapeController, onChanged: (val) => selectedBodyShape = val, icon: Icons.accessibility, index: 4),
                _buildPreferencePage(label: "Skin Tone", options: skinToneOptions, selectedValue: selectedSkinTone, customController: customSkinToneController, onChanged: (val) => selectedSkinTone = val, icon: Icons.face, index: 5),
                _buildPreferencePage(label: "Height", options: heightOptions, selectedValue: selectedHeight, customController: customHeightController, onChanged: (val) => selectedHeight = val, icon: Icons.height, index: 6),
                _buildPreferencePage(label: "Occasion", options: occasionOptions, selectedValue: selectedOccasion, customController: customOccasionController, onChanged: (val) => selectedOccasion = val, icon: Icons.event, index: 7),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], foregroundColor: Colors.white),
                    child: const Text("Back"),
                  ),
                ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: Text(_currentPage == 7 ? "Save & Continue" : "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggestion Page implementing Data Mining concepts
class SuggestionPage extends StatelessWidget {
  final String gender, style, color, weather, bodyShape, skinTone, height, occasion;
  const SuggestionPage({super.key, required this.gender, required this.style, required this.color, required this.weather, required this.bodyShape, required this.skinTone, required this.height, required this.occasion});

  // Dummy dataset representing historical fashion data
  static final List<Map<String, String>> dataset = [
    {'style':'Casual','color':'Red','occasion':'Party','gender':'Female'},
    {'style':'Formal','color':'Blue','occasion':'Work','gender':'Male'},
    {'style':'Sporty','color':'Green','occasion':'Casual Outing','gender':'Female'},
    {'style':'Vintage','color':'Purple','occasion':'Vacation','gender':'Female'},
    {'style':'Business Casual','color':'Black','occasion':'Work','gender':'Male'},
  ];

  /// Association Rules Example
  /// Data Mining Concept: Association Rule Mining
  String getAssociatedColor(String style) {
    final Map<String,String> rules = {'Formal':'Blue','Casual':'Red','Sporty':'Green','Vintage':'Purple','Business Casual':'Black'};
    return rules[style] ?? color;
  }

  /// IR (Information Retrieval) & Clustering Example:
  /// Retrieve similar outfits based on style, color, or occasion
  List<Map<String,String>> searchOutfits() {
    return dataset.where((item) => item['style'] == style || item['color'] == color || item['occasion'] == occasion).toList();
  }

  @override
  Widget build(BuildContext context) {
    final associatedColor = getAssociatedColor(style); // Association Rule
    final results = searchOutfits(); // IR & Clustering

    return Scaffold(
      appBar: AppBar(title: const Text("Fashion Suggestions")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classification/Association
            Text("Predicted Associations:", style: Theme.of(context).textTheme.titleMedium),
            Text("Recommended Color for your style ($style): $associatedColor"),
            const SizedBox(height: 20),

            // IR & Clustering
            Text("Matching Outfits (IR & Clustering):", style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Card(
                    child: ListTile(
                      title: Text("${item['style']} - ${item['color']}"),
                      subtitle: Text("Occasion: ${item['occasion']} | Gender: ${item['gender']}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
