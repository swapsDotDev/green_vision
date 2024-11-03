import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String uploadedImageUrl;

  const ResultScreen({Key? key, required this.uploadedImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Image:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Image.network(uploadedImageUrl), // Display the uploaded image
            SizedBox(height: 20),
            Text(
              'Analysis Results:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Add your analysis results here
            // For example:
            // Text('Detected Vegetation: 80%'),
            // Text('Area Calculated: 1500 sq. meters'),
          ],
        ),
      ),
    );
  }
}
