import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: FashionDesignerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FashionDesignerScreen extends StatefulWidget {
  const FashionDesignerScreen({super.key});

  @override
  _FashionDesignerScreenState createState() => _FashionDesignerScreenState();
}

class _FashionDesignerScreenState extends State<FashionDesignerScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _generatedImageUrl;
  bool _loading = false;
  List<Map<String, String>> _searchResults = [];

  final String openAIKey = '<YOUR_OPENAI_KEY>';

  final List<String> _categories = [
    'Lehanga',
    'Western',
    'Casual',
    'Formal',
    'Informal',
  ];
  String _selectedCategory = 'Lehanga';

  // ---------------- Generate AI Fashion Design ----------------
  Future<void> generateImage(String prompt) async {
    setState(() {
      _loading = true;
      _generatedImageUrl = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedImageUrl = data['data'][0]['url'];
        });
      } else {
        throw Exception('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onGeneratePressed() {
    final userPrompt = _promptController.text.trim();
    if (userPrompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a fashion idea prompt.')),
      );
      return;
    }

    final effectiveCategory =
        _selectedCategory.toLowerCase() == 'informal'
            ? 'informal'
            : _selectedCategory.toLowerCase();
    final prompt =
        'Fashion outfit in $effectiveCategory style. $userPrompt. Focus only on fashion design and clothing.';

    generateImage(prompt);
  }

  void _onSharePressed() {
    if (_generatedImageUrl != null) {
      Share.share('Check out my AI fashion design! $_generatedImageUrl');
    }
  }

  // ---------------- Save Design (Data Mining: track saved items) ----------------
  Future<void> _onSavePressed() async {
    if (_generatedImageUrl == null) return;

    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_images') ?? [];

    final newEntry = jsonEncode({
      'url': _generatedImageUrl,
      'category': _selectedCategory,
      'prompt': _promptController.text.trim(),
    });

    if (!savedData.contains(newEntry)) {
      savedData.add(newEntry);
      await prefs.setStringList('saved_images', savedData);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Design saved!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Design already saved.')));
    }
  }

  void _goToGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIGalleryScreen()),
    );
  }

  // ---------------- IR Search in saved designs ----------------
  Future<void> _searchDesigns(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_images') ?? [];

    List<Map<String, String>> results = [];

    for (var entry in savedData) {
      try {
        final data = jsonDecode(entry);
        final prompt = (data['prompt'] ?? '').toLowerCase();
        if (prompt.contains(query.toLowerCase())) {
          results.add({
            'url': data['url'],
            'category': data['category'] ?? 'Informal',
            'prompt': data['prompt'] ?? ''
          });
        }
      } catch (_) {}
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final teal = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        title: const Text(
          'AI Fashion Designer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            tooltip: 'View Saved Designs',
            onPressed: _goToGallery,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Prompt Input ----------------
            Text(
              'Describe your fashion idea:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: teal.shade800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. A sleek red gown with metallic accents...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 15),

            // ---------------- Category Selection ----------------
            Row(
              children: [
                const Text(
                  'Select Category:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),

            // ---------------- Generate Button ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _onGeneratePressed,
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: Text(
                  _loading ? 'Generating...' : 'Generate Design',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- Generated Image ----------------
            if (_generatedImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_generatedImageUrl!),
              ),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CircularProgressIndicator(color: Colors.teal),
                ),
              ),

            const SizedBox(height: 20),

            // ---------------- Save / Share ----------------
            if (_generatedImageUrl != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save', style: TextStyle(color: Colors.white)),
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal.shade700,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Share', style: TextStyle(color: Colors.white)),
                    onPressed: _onSharePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal.shade700,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),

            // ---------------- IR Search ----------------
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Saved Designs (Keyword)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchDesigns(_searchController.text.trim());
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Search Results ----------------
            if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _searchResults.map((res) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(res['prompt'] ?? ''),
                      subtitle: Text('Category: ${res['category']}'),
                      leading: Image.network(res['url']!, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Gallery Screen ----------------
class AIGalleryScreen extends StatefulWidget {
  const AIGalleryScreen({super.key});

  @override
  _AIGalleryScreenState createState() => _AIGalleryScreenState();
}

class _AIGalleryScreenState extends State<AIGalleryScreen> {
  Map<String, List<String>> categoryImages = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_images') ?? [];

    Map<String, List<String>> tempMap = {};

    for (var entry in savedData) {
      try {
        final data = jsonDecode(entry);
        final url = data['url'] as String;
        final category = data['category'] as String? ?? 'Informal';

        tempMap.putIfAbsent(category, () => []);
        tempMap[category]!.add(url);
      } catch (_) {}
    }

    setState(() {
      categoryImages = tempMap;
      _loading = false;
    });
  }

  void _confirmDelete(String category, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design'),
        content: const Text('Are you sure you want to delete this design?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(category, url);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String category, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_images') ?? [];

    savedData.removeWhere((entry) {
      try {
        final data = jsonDecode(entry);
        return data['url'] == url && data['category'] == category;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList('saved_images', savedData);
    await _loadSavedImages();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teal = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'AI Design Gallery',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadSavedImages,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : categoryImages.isEmpty
              ? Center(
                  child: Text(
                    'No saved designs yet.',
                    style: TextStyle(fontSize: 18, color: teal.shade700),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedImages,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: categoryImages.entries.map((entry) {
                      final category = entry.key;
                      final images = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final url = images[index];
                              return Stack(
                                children: [
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(category, url),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
