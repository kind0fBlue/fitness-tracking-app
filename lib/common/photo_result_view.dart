import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoResultView extends StatefulWidget {
  final File imageFile;

  const PhotoResultView({super.key, required this.imageFile});

  @override
  _PhotoResultViewState createState() => _PhotoResultViewState();
}

class _PhotoResultViewState extends State<PhotoResultView> {
  String? resultText;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    sendImageToApi(widget.imageFile);
  }

  Future<void> sendImageToApi(File imageFile) async {
    // Convert the image file to a base64 string
    final base64Image = base64Encode(imageFile.readAsBytesSync());

    // Your OpenAI API key
    const apiKey = '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';

    try {
      // OpenAI API endpoint
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      // Create the JSON body as per OpenAI’s GPT-4 Vision API
      final body = jsonEncode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "This is supposed to be an image for some food, if it is not an image of foods just say it is not, or else recognize the types of food in the image and estimate the calories in it"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image"
                }
              }
            ]
          }
        ]
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Check response status
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          resultText = responseData['choices'][0]['message']['content'];
          errorMessage = null;
        });
      } else {
        // Display error if status code is not 200
        setState(() {
          errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      // Display error if there's an exception
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
      print('Error details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calorie Analysis Result")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(widget.imageFile, width: 200, height: 200),
              const SizedBox(height: 20),
              if (resultText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Result: $resultText"),
                ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Error: $errorMessage",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (errorMessage == null && resultText == null)
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
