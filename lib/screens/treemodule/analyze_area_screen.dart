
  import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AnalyzeAreaScreen extends StatefulWidget {
  const AnalyzeAreaScreen({Key? key}) : super(key: key);

  @override
  State<AnalyzeAreaScreen> createState() => _AnalyzeAreaScreenState();
}

class _AnalyzeAreaScreenState extends State<AnalyzeAreaScreen> {
  bool isAnalyzing = false;
  String? selectedImage;
  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? documentId;

  static const int maxImageSize = 10 * 1024 * 1024;
  final List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'tiff'];
  final uuid = const Uuid();

  // ... (keep all the existing UI widget methods)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Analyze Area', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadSection(),
              const SizedBox(height: 24),
              const Text(
                'Analysis Parameters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAnalysisParameters(),
              const SizedBox(height: 24),
              const Text(
                'Previous Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPreviousAnalysisList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildUploadBox(),
          if (selectedImage != null) ...[
            const SizedBox(height: 16),
            _buildSelectedImagePreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Upload Satellite Image',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported formats: JPEG, PNG, TIFF',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _selectImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final String extension = path.extension(pickedFile.path).toLowerCase().replaceAll('.', '');
        if (!supportedFormats.contains(extension)) {
          _showErrorDialog('Unsupported file format', 'Please select an image in one of the supported formats.');
          return;
        }

        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        if (fileSize > maxImageSize) {
          _showErrorDialog('File too large', 'Please select an image smaller than 10MB');
          return;
        }

        setState(() {
          imageFile = file;
          selectedImage = path.basename(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to pick image: $e');
    }
  }

  Widget _buildSelectedImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (imageFile != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedImage ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    FutureBuilder<int>(
                      future: imageFile?.length(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final size = snapshot.data! / (1024 * 1024);
                          return Text('Size: ${size.toStringAsFixed(2)} MB', style: TextStyle(color: Colors.grey[600]));
                        }
                        return const Text('Calculating size...');
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                    imageFile = null;
                  });
                },
              ),
            ],
          ),
          if (imageFile != null) ...[
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(imageFile!, fit: BoxFit.contain),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisParameters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildParameterItem('Vegetation Detection', 'Identify trees and green areas', Icons.nature, Colors.green),
          const Divider(),
          _buildParameterItem('Area Calculation', 'Calculate total green coverage', Icons.calculate, Colors.blue),
          const Divider(),
          _buildParameterItem('Health Assessment', 'Evaluate vegetation health', Icons.healing, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildParameterItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          Switch(value: true, onChanged: (value) {}, activeColor: color),
        ],
      ),
    );
  }

  Widget _buildPreviousAnalysisList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreviousAnalysisItem('North Area Analysis', 'October 15, 2024', 'Healthy vegetation with minor patches needing attention'),
          const Divider(),
          _buildPreviousAnalysisItem('South Sector Greenery', 'September 30, 2024', 'Sparse coverage, high need for reforestation'),
          const Divider(),
          _buildPreviousAnalysisItem('West Land Assessment', 'August 12, 2024', 'High density of green coverage, low need for intervention'),
        ],
      ),
    );
  }

  Widget _buildPreviousAnalysisItem(String title, String date, String summary) {
    return ListTile(
      leading: Icon(Icons.insights, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$date\n$summary', style: TextStyle(color: Colors.grey[600])),
      isThreeLine: true,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: () {
        // Placeholder for detailed analysis view
        _showAnalysisDetail(title, date, summary);
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : _analyzeImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isAnalyzing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Analyze Area', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }




  // Convert File to base64
  Future<String> _fileToBase64(File file) async {
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  // Upload image data to Firestore
  Future<String?> _uploadImageToFirestore(File imageFile) async {
    try {
      // Generate a unique ID for the document
      String docId = uuid.v4();

      // Convert image to base64
      String base64Image = await _fileToBase64(imageFile);

      // Create document data
      Map<String, dynamic> imageData = {
        'imageData': base64Image,
        'filename': path.basename(imageFile.path),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // Status for tracking analysis state
        'fileSize': await imageFile.length(),
        'fileType': path.extension(imageFile.path).toLowerCase(),
      };

      // Upload to Firestore
      await _firestore.collection('analysis_images').doc(docId).set(imageData);

      return docId;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Listen to analysis status changes
  void _listenToAnalysisStatus(String docId) {
    _firestore.collection('analysis_images').doc(docId).snapshots().listen(
            (snapshot) {
          if (snapshot.exists) {
            String status = snapshot.data()?['status'] ?? 'pending';
            Map<String, dynamic>? results = snapshot.data()?['results'];

            if (status == 'completed' && results != null) {
              setState(() {
                isAnalyzing = false;
              });
              _showSuccessDialog(
                  'Analysis Complete',
                  'The analysis has been completed. View details on the results screen.'
              );
            } else if (status == 'failed') {
              setState(() {
                isAnalyzing = false;
              });
              _showErrorDialog(
                  'Analysis Failed',
                  snapshot.data()?['error'] ?? 'An unknown error occurred'
              );
            }
          }
        },
        onError: (error) {
          print('Error listening to analysis status: $error');
        }
    );
  }


  Future<void> _analyzeImage() async {
    if (imageFile == null) {
      _showErrorDialog('No Image Selected', 'Please upload an image before starting the analysis.');
      return;
    }

    setState(() {
      isAnalyzing = true;
    });

    try {
      // Upload image to Firebase Storage
      String? docId = await _uploadImageToFirestore(imageFile!);

      if (docId == null) {
        _showErrorDialog('Upload Failed', 'Failed to upload image to storage.');
        setState(() {
          isAnalyzing = false;
        });
        return;
      }

      // Store the document ID
      setState(() {
        documentId = docId;
      });

      // Start listening to analysis status
      _listenToAnalysisStatus(docId);
      _showSuccessDialog(
          'Analysis Complete',
          'The image has been uploaded and analysis has been completed. View details on the results screen.'
      );
    } catch (e) {
      _showErrorDialog('Analysis Failed', 'An error occurred during analysis: $e');
    } finally {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('View Results'),
              onPressed: () {
                Navigator.of(context).pop();
                // Add navigation to the results screen here
              },
            ),
          ],
        );
      },
    );
  }



  Future<void> _showErrorDialog(String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAnalysisDetail(String title, String date, String summary) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('$date\n\n$summary'),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class _showHelpDialog {
}

