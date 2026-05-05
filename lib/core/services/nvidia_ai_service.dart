import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';
import '../utils/debug_logger.dart';

class NvidiaAiService {
  static const String _baseUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';
  static const String _textModel = 'meta/llama-3.1-8b-instruct';
  static const String _visionModel = 'meta/llama-3.2-11b-vision-instruct';

  /// Sends a query to NVIDIA NIM for Agricultural Advice with Context & Location
  static Future<String> getAgriAdvice(String query, {
    String userName = "SmartFruit User", 
    String? imagePath,
    List<Map<String, String>> history = const [],
    String location = "India",
    String? district,
    String? state,
    String? temp,
    String? humidity,
  }) async {
    logger.log("NVIDIA: Fetching advice for $userName | Loc: $district, $state | Weather: ${temp}°C | History: ${history.length}");

    if (ApiKeys.nvidiaApiKey.contains("PLACEHOLDER")) {
      return "⚠️ NVIDIA API Key not configured. Please add your key in `lib/core/constants/api_keys.dart`.";
    }

    try {
      final bool hasImage = imagePath != null;
      final String model = hasImage ? _visionModel : _textModel;
      
      // Construct Context-Aware Prompt
      String locContext = district != null && state != null ? "$district, $state" : location;
      String weatherContext = temp != null ? "Current Weather: $temp°C, Humidity: ${humidity ?? 'Unknown'}" : "Weather data unavailable";

      List<Map<String, dynamic>> messages = [
        {
          "role": "system",
          "content": "You are a professional agricultural AI assistant.\n\n"
              "STRICT RULES:\n"
              "* Always respond ONLY in English\n"
              "* Never use Telugu or any other language\n"
              "* Do not mix languages\n"
              "* Keep answers simple and practical\n"
              "* Limit response to 4–5 lines\n"
              "* Avoid AI-like sentences\n\n"
              "Style:\n"
              "* Friendly farmer advisor tone\n"
              "* Clear and direct answers"
        }
      ];

      // Add Conversation History (last 3 exchanges)
      for (var chat in history) {
        messages.add({"role": chat['role'], "content": chat['content']});
      }

      // Add Current Query
      if (hasImage) {
        final File file = File(imagePath);
        final List<int> imageBytes = await file.readAsBytes();
        final String base64Image = base64Encode(imageBytes);

        messages.add({
          "role": "user",
          "content": [
            {"type": "text", "text": query.isEmpty ? "Please analyze this crop/pest image." : query},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
            }
          ]
        });
      } else {
        messages.add({"role": "user", "content": query});
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.nvidiaApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": model,
          "messages": messages,
          "temperature": 0.2,
          "top_p": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        logger.log("NVIDIA: API Error - ${response.statusCode} | ${response.body}");
        return "Error: Unable to reach AI Advisor (Status ${response.statusCode}).";
      }
    } catch (e) {
      logger.log("NVIDIA: Network Exception - $e");
      return "Connection Error: Please check your internet and try again.";
    }
  }
}
