import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AiStylistApp());
}

class AiStylistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fashion Stylist 🇵🇰',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: AiStylistPage(),
    );
  }
}

class AiStylistPage extends StatefulWidget {
  @override
  _AiStylistPageState createState() => _AiStylistPageState();
}

class _AiStylistPageState extends State<AiStylistPage> {
  String? eventType;
  int? budget;
  List<String> selectedColors = [];
  String? ageGroup;
  List<String> selectedBrands = [];

  bool _loading = false;
  List<Map<String, String>> _realProducts = [];

  static const String googleApiKey = 'AIzaSyB0mVhYZ9VXajjN65I32I8XqCzpxTS0Mzg';
  static const String googleCseId = 'b35e13d52c4934751';

  final List<String> events = ['Wedding', 'Casual', 'Formal', 'Party', 'Office', 'Festive'];
  final List<String> colors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Pink', 'Yellow', 'Orange'];
  final List<String> ages = ['18-25', '26-35', '36-50', '50+'];
  final List<String> brands = ['Khaadi', 'Alkaram', 'Limelight', 'Bonanza Satrangi', 'Maria B'];

  final TextEditingController _budgetController = TextEditingController();

  Future<void> fetchRealProducts() async {
    if (eventType == null || ageGroup == null || budget == null || selectedColors.isEmpty || selectedBrands.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all preferences before searching products')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _realProducts.clear();
    });

    // Enhanced brand terms for Google search
    final brandTerms = selectedBrands.map((b) {
      if (b == 'Maria B') return 'Maria B OR Maria.B OR Mariab';
      if (b == 'Bonanza Satrangi') return 'Bonanza OR Satrangi';
      return b;
    }).join(" OR ");

    final query = '$brandTerms $eventType outfit ${selectedColors.join(" ")}';

    try {
      final url =
          'https://www.googleapis.com/customsearch/v1?key=$googleApiKey&cx=$googleCseId&q=${Uri.encodeComponent(query)}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          setState(() {
            _loading = false;
          });
          return;
        }

        final filteredProducts = items.map<Map<String, String>>((item) {
          final pagemap = item['pagemap'] ?? {};
          final cseImage = (pagemap['cse_image'] as List?)?.first?['src'] ?? '';

          return {
            "title": item['title'] ?? '',
            "link": item['link'] ?? '',
            "snippet": item['snippet'] ?? '',
            "thumbnail": cseImage,
          };
        }).where((product) {
          final title = product['title']!.toLowerCase();

          return selectedBrands.any((b) {
            final brandLower = b.toLowerCase();
            if (brandLower == 'maria b') {
              return title.contains('maria b') || title.contains('maria.b') || title.contains('mariab');
            } else if (brandLower == 'bonanza satrangi') {
              return title.contains('bonanza') || title.contains('satrangi');
            } else {
              return title.contains(brandLower);
            }
          });
        }).toList();

        setState(() {
          _realProducts = filteredProducts;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void openLink(String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WebViewScreen(url: url),
    ));
  }

  Widget buildChipSelection(String title, List<String> options, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.teal.shade800)),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: options.map((item) {
            final selected = selectedList.contains(item);
            return FilterChip(
              label: Text(item),
              selected: selected,
              selectedColor: Colors.teal.shade400,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    selectedList.add(item);
                  } else {
                    selectedList.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order and Purchase"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Select Event"),
                  value: eventType,
                  items: events.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                  onChanged: (val) => setState(() => eventType = val),
                ),
                SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Select Age Group"),
                  value: ageGroup,
                  items: ages.map((a) => DropdownMenuItem(child: Text(a), value: a)).toList(),
                  onChanged: (val) => setState(() => ageGroup = val),
                ),
                SizedBox(height: 14),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Budget (Rs)",
                    prefixIcon: Icon(Icons.money),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    setState(() {
                      budget = parsed;
                    });
                  },
                ),
                SizedBox(height: 16),
                buildChipSelection("Preferred Colors", colors, selectedColors),
                SizedBox(height: 16),
                buildChipSelection("Preferred Brands", brands, selectedBrands),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loading ? null : fetchRealProducts,
                  icon: Icon(Icons.search),
                  label: Text("Search Real Products"),
                ),
                SizedBox(height: 20),
                if (_loading) CircularProgressIndicator(),
                if (_realProducts.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _realProducts.length,
                    itemBuilder: (context, index) {
                      final product = _realProducts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: product['thumbnail'] != ''
                              ? Image.network(product['thumbnail']!, width: 50, height: 50, fit: BoxFit.cover)
                              : null,
                          title: Text(product['title'] ?? ''),
                          subtitle: Text(product['snippet'] ?? ''),
                          trailing: Icon(Icons.open_in_new, color: Colors.teal.shade700),
                          onTap: () => openLink(product['link']!),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoadingPage = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoadingPage = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Page'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          if (_isLoadingPage)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
