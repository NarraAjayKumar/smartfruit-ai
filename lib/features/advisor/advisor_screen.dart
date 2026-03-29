import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../core/services/nvidia_ai_service.dart';
import '../../core/services/custom_auth_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/animations/anti_gravity_widget.dart';
import '../../core/utils/debug_logger.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, String>> _history = []; // Conversation Context
  bool _isThinking = false; // New Thinking State
  
  // Personalization
  String _userName = "User";
  final CustomAuthService _authService = CustomAuthService();

  // Voice Assistant
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  // Media
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Context Data
  String? _district;
  String? _state;
  String? _temp;
  String? _humidity;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadContextData(); // Fetch Weather & Location
    _initSpeech();
    _initTts();
  }

  void _loadContextData() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      final weather = await WeatherService.getWeather(loc.latitude, loc.longitude);
      setState(() {
        _district = loc.district;
        _state = loc.state;
        _temp = weather.temp.toStringAsFixed(1);
        _humidity = weather.humidity.toString();
      });
    } catch (e) {
      logger.log("Advisor Context Error: $e");
    }
  }

  void _loadUserData() async {
    final name = await _authService.getUserName();
    setState(() => _userName = name);
  }

  void _initSpeech() async {
    _isSpeechEnabled = await _speechToText.initialize(
      onStatus: (status) => logger.log("STT Status: $status"),
      onError: (error) => logger.log("STT Error: $error"),
    );
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setCancelHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((_) => setState(() => _isSpeaking = false));
  }

  void _startListening() async {
    if (!_isSpeechEnabled) return;
    HapticFeedback.mediumImpact(); // Premium Haptic Feedback
    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _queryController.text = result.recognizedWords;
          if (result.finalResult) _isListening = false;
        });
      },
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  bool _isTelugu(String text) {
    return RegExp(r'[\u0C00-\u0C7F]').hasMatch(text);
  }

  void _speak(String text, {String? langCode}) async {
    await _flutterTts.stop(); // Auto-stop previous speech
    
    // Explicit lang code or auto-detect
    bool isTelugu = langCode != null ? langCode == "te-IN" : _isTelugu(text);
    
    if (isTelugu) {
      await _flutterTts.setLanguage("te-IN");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.42);
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
    }
    
    await _flutterTts.speak(text.trim());
  }

  bool _isAppQuery(String query) {
    final q = query.toLowerCase();
    return q.contains("how to use") ||
        q.contains("how to scan") ||
        q.contains("how this app works") ||
        q.contains("features") ||
        q.contains("upload image") ||
        q.contains("what is this app") ||
        q.contains("guide") ||
        q.contains("help") ||
        q.contains("ఎలా వాడాలి") ||
        q.contains("సహాయం");
  }

  String _getAppGuide(bool isTelugu) {
    if (isTelugu) {
      return """
స్మార్ట్ ఫ్రూట్ AI యాప్ ఉపయోగించే విధానం:

1. డాష్ బోర్డ్ ఓపెన్ చేయండి.
2. పంటను ఎంచుకోండి (ఉదా: పుచ్చకాయ, టమోటా).
3. ఫోటో తీయండి లేదా అప్ లోడ్ చేయండి.
4. ఫలితాన్ని చూడండి (పండినదా లేదా కాదు).
5. AI అడ్వైజర్ ద్వారా సలహాలు పొందండి.
""";
    } else {
      return """
How to use SmartFruit AI:

1. Open Dashboard.
2. Select a crop (Watermelon, Tomato, etc.).
3. Capture or upload image.
4. View ripeness result.
5. Use AI Advisor for suggestions.
""";
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _queryController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_isThinking) return; // Debounce
    
    String text = _queryController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final String? imagePath = _selectedImage?.path;
    final String timestamp = DateFormat('HH:mm').format(DateTime.now());

    setState(() {
      _messages.add({
        "role": "user", 
        "content": text.isEmpty ? "Sent an image" : text,
        "image": imagePath,
        "time": timestamp
      });
      _queryController.clear();
      _selectedImage = null;
      _isThinking = true;
    });

    _scrollToBottom();

    // 1. Check for App Guide Intent (No API call)
    final bool isTeluguInput = _isTelugu(text);
    if (_isAppQuery(text)) {
      final String guide = _getAppGuide(isTeluguInput);
      final String aiTime = DateFormat('HH:mm').format(DateTime.now());

      setState(() {
        _isThinking = false;
        _messages.add({
          "role": "advisor",
          "content": guide,
          "time": aiTime
        });
      });
      
      _speak(guide, langCode: isTeluguInput ? "te-IN" : "en-US");
      _scrollToBottom();
      return;
    }

    // 2. Agricultural Advice (NVIDIA AI)
    try {
      final String response = await NvidiaAiService.getAgriAdvice(
        text, 
        userName: _userName,
        imagePath: imagePath,
        history: _history,
        location: _district != null ? "$_district, $_state" : "Andhra Pradesh",
        district: _district,
        state: _state,
        temp: _temp,
        humidity: _humidity,
      );

      final String aiTime = DateFormat('HH:mm').format(DateTime.now());

      setState(() {
        _isThinking = false;
        _messages.add({
          "role": "advisor", 
          "content": response,
          "time": aiTime
        });
        
        // Update Conversation Context (strictly last 3 turns / 6 messages)
        _history.add({"role": "user", "content": text});
        _history.add({"role": "assistant", "content": response});
        if (_history.length > 6) _history.removeRange(0, _history.length - 6);
      });
    } catch (e) {
      setState(() {
        _isThinking = false;
        _messages.add({
          "role": "advisor", 
          "content": isTeluguInput 
              ? "సర్వర్ బిజీగా ఉంది. మళ్లీ ప్రయత్నించండి." 
              : "Server busy. Please try again.",
          "time": DateFormat('HH:mm').format(DateTime.now())
        });
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Agri-Advisor", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildBanner(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty ? _buildWelcome() : _buildChatList(),
                ),
                if (_messages.isNotEmpty) _buildSuggestionChips(),
              ],
            ),
          ),
          if (_isThinking) _buildThinkingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            "AI Powered Assistant",
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5
            ),
          ),
          if (_isSpeaking) ...[
            const SizedBox(width: 15),
            _buildSpeakingIndicator(),
          ]
        ],
      ),
    );
  }

  Widget _buildSpeakingIndicator() {
    return InkWell(
      onTap: _stopSpeaking,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.stop_circle, size: 14, color: Colors.pink),
            const SizedBox(width: 4),
            Text("STOP VOICE", style: TextStyle(fontSize: 10, color: Colors.pink[800], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AntiGravityWidget(
              amplitude: 10,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_rounded, size: 80, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome to SmartFruit AI, \n$_userName! 🇮🇳",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Hello ${_userName.split(' ')[0]}! How can I help you today?\nనేను మీకు ఎలా సహాయపడగలను?",
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildQuickPrompt("Identify Pests / తెగుళ్లను గుర్తించండి", Icons.bug_report_rounded, Colors.orange),
            _buildQuickPrompt("Weather Advice / వాతావరణ సలహా", Icons.wb_sunny_rounded, Colors.blue),
            _buildQuickPrompt("Crop Care / పంట సంరక్షణ", Icons.agriculture_rounded, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: InkWell(
        onTap: () {
          _queryController.text = label.split(" / ")[0];
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSuggestionChips() {
    final List<String> suggestions = [
      _isTelugu(_messages.lastOrNull?["content"] ?? "") ? "మరిన్ని వివరాలు" : "Tell me more",
      "How to use app?",
      "Weather Advice",
      "Pest Detection",
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestions[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              onPressed: () {
                _queryController.text = suggestions[index];
                _sendMessage();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        bool isUser = msg["role"] == "user";
        return Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                decoration: BoxDecoration(
                  color: isUser ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 20),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg["image"] != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(msg["image"]), height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      msg["content"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        msg["time"] ?? "",
                        style: TextStyle(fontSize: 10, color: isUser ? Colors.white70 : Colors.black45),
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => _speak(msg["content"]!),
                            child: Row(
                              children: [
                                Icon(_isSpeaking ? Icons.graphic_eq : Icons.volume_up_rounded, size: 18, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  _isSpeaking ? "Speaking..." : (_isTelugu(msg["content"]!) ? "Listen (Telugu)" : "Listen (English)"),
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (_isSpeaking)
                             IconButton(
                              icon: const Icon(Icons.stop_circle, size: 20, color: Colors.red),
                              onPressed: _stopSpeaking,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
            ),
            const SizedBox(width: 8),
            Text(
              _isTelugu(_messages.lastOrNull?["content"] ?? "") ? "ఆలోచిస్తున్నాను..." : "AI Thinking...",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      children: [
        if (_selectedImage != null) _buildImagePreview(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt_rounded, color: Colors.grey[600]),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: Icon(Icons.photo_library_rounded, color: Colors.grey[600]),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            decoration: InputDecoration(
                              hintText: _isListening ? "Listening..." : "Ask anything...", 
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: _isListening ? Theme.of(context).primaryColor : Colors.grey)
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        InkWell(
                          onTap: _isListening ? _stopListening : _startListening,
                          child: AntiGravityWidget(
                            amplitude: _isListening ? 5 : 0,
                            child: Icon(
                              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded, 
                              color: _isListening ? Colors.red : Colors.grey[600]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
                    onPressed: _sendMessage
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey[50],
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: _removeSelectedImage,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
