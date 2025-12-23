import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math'; // ✅ Import for sqrt

import '../consts.dart'; // Your API key

class Suggestion extends StatefulWidget {
  final String gender;
  final String style;
  final String color;
  final String weather;
  final String bodyShape;
  final String skinTone;
  final String height;
  final String occasion;

  const Suggestion({
    super.key,
    required this.gender,
    required this.style,
    required this.color,
    required this.weather,
    required this.bodyShape,
    required this.skinTone,
    required this.height,
    required this.occasion,
  });

  @override
  State<Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {
  late OpenAI _openAI;
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'You');
  final ChatUser _suggestionSystemUser = ChatUser(id: '2', firstName: 'Assistant');
  List<ChatMessage> _messages = [];
  final List<ChatUser> _typingUsers = [];

  bool _isDarkMode = false;

  static const String suggestionMessagesKey = 'suggestion_messages';

  // Mock garment dataset for Virtual Try-On
  final List<Map<String, dynamic>> garmentDatabase = [
    {
      "name": "Summer Dress",
      "style": "Casual",
      "color": "Red",
      "occasion": "Day Out",
      "description": "Lightweight summer dress for warm weather",
    },
    {
      "name": "Formal Suit",
      "style": "Formal",
      "color": "Black",
      "occasion": "Business",
      "description": "Tailored black suit for formal events",
    },
    {
      "name": "Evening Gown",
      "style": "Elegant",
      "color": "Blue",
      "occasion": "Party",
      "description": "Elegant blue gown perfect for evening parties",
    },
    {
      "name": "Denim Jacket",
      "style": "Casual",
      "color": "Blue",
      "occasion": "Everyday",
      "description": "Classic denim jacket for casual wear",
    },
    {
      "name": "Trench Coat",
      "style": "Formal",
      "color": "Beige",
      "occasion": "Outdoor",
      "description": "Stylish beige trench coat for cooler weather",
    },
  ];

  @override
  void initState() {
    super.initState();
    _openAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)),
      enableLog: true,
    );
    _loadMessages();
    _showIntroductionMessage();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messageStrings = prefs.getStringList(suggestionMessagesKey);

    if (messageStrings != null) {
      setState(() {
        _messages = messageStrings.map((messageString) {
          Map<String, dynamic> messageMap = jsonDecode(messageString);
          return ChatMessage(
            user: messageMap['user']['id'] == _currentUser.id ? _currentUser : _suggestionSystemUser,
            text: messageMap['text'],
            createdAt: DateTime.parse(messageMap['createdAt']),
          );
        }).toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messageStrings = _messages.map((message) {
      return jsonEncode({
        'user': {'id': message.user.id},
        'text': message.text,
        'createdAt': message.createdAt.toIso8601String(),
      });
    }).toList();

    await prefs.setStringList(suggestionMessagesKey, messageStrings);
  }

  void _showIntroductionMessage() {
    final introductionMessage = ChatMessage(
      user: _suggestionSystemUser,
      text: "👗 Welcome! Based on your profile, I'm preparing a personalized fashion suggestion...",
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, introductionMessage);
    });

    _saveMessages();
    _generateSuggestion();
  }

  Future<void> _generateSuggestion() async {
    String inputMessage = """
      Gender: ${widget.gender.trim()}, Style: ${widget.style.trim()}, Favorite Color: ${widget.color.trim()}, 
      Preferred Weather: ${widget.weather.trim()}, Body Shape: ${widget.bodyShape.trim()}, Skin Tone: ${widget.skinTone.trim()}, 
      Height: ${widget.height.trim()}, Occasion: ${widget.occasion.trim()}. 
      Please provide a detailed outfit suggestion, considering style tips, matching colors, and current trends.
    """.replaceAll('\n', ' ');

    setState(() {
      _messages.insert(0, ChatMessage(user: _currentUser, text: inputMessage, createdAt: DateTime.now()));
      _typingUsers.add(_suggestionSystemUser);
    });

    await _saveMessages();

    try {
      final request = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [Messages(role: Role.user, content: inputMessage)],
        maxToken: 500,
      );

      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        final replyText = response.choices.first.message?.content ?? "I'm not sure.";
        setState(() {
          _messages.insert(
            0,
            ChatMessage(user: _suggestionSystemUser, text: replyText.trim(), createdAt: DateTime.now()),
          );
        });
        await _saveMessages();
        await _showVirtualTryOnResults(); // Show Virtual Try-On results
      } else {
        _handleErrorMessage("⚠️ Sorry, couldn't generate a suggestion.");
      }
    } catch (e) {
      print("Error while generating suggestion: $e");
      _handleErrorMessage("⚠️ An error occurred while generating your suggestion.");
    } finally {
      setState(() {
        _typingUsers.remove(_suggestionSystemUser);
      });
    }
  }

  void _handleErrorMessage(String message) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(user: _suggestionSystemUser, text: message, createdAt: DateTime.now()),
      );
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> getChatResponse(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _typingUsers.add(_suggestionSystemUser);
    });

    await _saveMessages();

    try {
      List<Messages> chatHistory = _messages.reversed
          .where((m) => m.text.isNotEmpty)
          .take(6)
          .map((m) => Messages(
        role: m.user.id == _currentUser.id ? Role.user : Role.assistant,
        content: m.text,
      ))
          .toList();

      final request = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: chatHistory,
        maxToken: 200,
      );

      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        final replyText = response.choices.first.message?.content ?? "I'm not sure.";
        setState(() {
          _messages.insert(
            0,
            ChatMessage(user: _suggestionSystemUser, text: replyText.trim(), createdAt: DateTime.now()),
          );
        });
        await _saveMessages();
      } else {
        _handleErrorMessage("⚠️ Sorry, couldn't generate a reply.");
      }
    } catch (e) {
      print("Chat response error: $e");
      _handleErrorMessage("⚠️ An error occurred during the conversation.");
    } finally {
      setState(() {
        _typingUsers.remove(_suggestionSystemUser);
      });
    }
  }

  Future<void> _clearMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(suggestionMessagesKey);

    setState(() {
      _messages.clear();
    });
  }

  /// ---------------- Virtual Try-On Module ----------------

  Future<void> _showVirtualTryOnResults() async {
    final suggestions = await _performVirtualTryOn();
    String resultText = "👗 Virtual Try-On Suggestions:\n";
    for (var g in suggestions) {
      resultText += "- ${g['name']} (${g['style']}, ${g['color']}, ${g['occasion']})\n";
    }

    setState(() {
      _messages.insert(
        0,
        ChatMessage(user: _suggestionSystemUser, text: resultText, createdAt: DateTime.now()),
      );
    });
    await _saveMessages();
  }

  Future<List<Map<String, dynamic>>> _performVirtualTryOn() async {
    String query = """
      Gender: ${widget.gender}, Style: ${widget.style}, Color: ${widget.color},
      Weather: ${widget.weather}, Body Shape: ${widget.bodyShape},
      Skin Tone: ${widget.skinTone}, Height: ${widget.height}, Occasion: ${widget.occasion}
    """;

    // 1️⃣ Field-weighted BM25 (mocked with scoring key fields)
    List<Map<String, dynamic>> scoredGarments = garmentDatabase.map((garment) {
      double score = 0;
      if (garment['style'].toLowerCase() == widget.style.toLowerCase()) score += 3;
      if (garment['color'].toLowerCase() == widget.color.toLowerCase()) score += 2;
      if (garment['occasion'].toLowerCase() == widget.occasion.toLowerCase()) score += 2;
      return {...garment, 'score': score};
    }).toList();

    // 2️⃣ Fuzzy search (simple substring match)
    scoredGarments = scoredGarments.where((garment) {
      return garment['name'].toString().toLowerCase().contains(widget.style.toLowerCase()) ||
          garment['description'].toString().toLowerCase().contains(widget.occasion.toLowerCase());
    }).toList();

    // 3️⃣ TF-IDF & Cosine Similarity
    List<double> queryVector = _textToVector(query);
    scoredGarments = scoredGarments.map((garment) {
      double similarity = _cosineSimilarity(queryVector, _textToVector(garment['description']));
      return {...garment, 'score': garment['score'] + similarity * 5};
    }).toList();

    // Sort garments by score descending
    scoredGarments.sort((a, b) => (b['score']).compareTo(a['score']));

    return scoredGarments.take(5).toList(); // top 5 suggestions
  }

  List<double> _textToVector(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final Map<String, double> freq = {};
    for (var w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    return freq.values.toList().map((f) => f.toDouble()).toList();
  }

  double _cosineSimilarity(List<double> v1, List<double> v2) {
    final minLength = v1.length < v2.length ? v1.length : v2.length;
    double dot = 0;
    double mag1 = 0;
    double mag2 = 0;
    for (int i = 0; i < minLength; i++) {
      dot += v1[i] * v2[i];
      mag1 += v1[i] * v1[i];
      mag2 += v2[i] * v2[i];
    }
    if (mag1 == 0 || mag2 == 0) return 0;
    return dot / (sqrt(mag1) * sqrt(mag2)); // ✅ Fixed sqrt
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fashion Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Regenerate Suggestion",
            onPressed: _generateSuggestion,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear Chat",
            onPressed: _clearMessages,
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: "Toggle Theme",
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              typingUsers: _typingUsers,
              messageOptions: MessageOptions(
                currentUserContainerColor: Colors.teal,
                containerColor: Colors.grey.shade700,
                currentUserTextColor: Colors.white,
                textColor: Colors.white,
                borderRadius: 20,
                timePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                showTime: true,
              ),
              inputOptions: InputOptions(
                inputDecoration: InputDecoration(
                  hintText: "Type your question...",
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              onSend: (ChatMessage message) {
                getChatResponse(message);
              },
              messages: _messages,
            ),
          ),
        ],
      ),
    );
  }
}
