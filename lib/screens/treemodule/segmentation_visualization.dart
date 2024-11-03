import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';

class SegmentationVisualization extends StatelessWidget {
  final Map<String, dynamic> segmentationData;
  final double width;
  final double height;
  final File originalImage;

  const SegmentationVisualization({
    Key? key,
    required this.segmentationData,
    required this.width,
    required this.height,
    required this.originalImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: width,
            height: height,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Stack(
          children: [
            // Original image
            Image.file(
              originalImage,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
            // Segmentation overlay with dynamic colors
            CustomPaint(
              size: Size(width, height),
              painter: SegmentationPainter(
                segmentationData: segmentationData,
                originalImage: snapshot.data!,
                treeColor: Colors.green.withOpacity(0.5),
                fieldColor: Colors.yellow.withOpacity(0.5),
                landColor: Colors.blue.withOpacity(0.5),
              ),
            ),
            // Legend
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildLegend(),
            ),
          ],
        );
      },
    );
  }

  Future<ui.Image> _loadImage() async {
    final bytes = await originalImage.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(Colors.green.withOpacity(0.5), 'Trees'),
          SizedBox(height: 4),
          _legendItem(Colors.blue.withOpacity(0.5), 'Available Land'),
          SizedBox(height: 4),
          _legendItem(Colors.yellow.withOpacity(0.5), 'Fields'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class SegmentationPainter extends CustomPainter {
  final Map<String, dynamic> segmentationData;
  final ui.Image originalImage;
  final Color treeColor;
  final Color fieldColor;
  final Color landColor;

  SegmentationPainter({
    required this.segmentationData,
    required this.originalImage,
    this.treeColor = Colors.green,
    this.fieldColor = Colors.yellow,
    this.landColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final treeMask = segmentationData['treeMask'] as List<List<bool>>;
    final fieldMask = segmentationData['fieldMask'] as List<List<bool>>;
    final segmentationMap = segmentationData['segmentationMap'] as List<List<double>>;

    final scaleX = size.width / treeMask[0].length;
    final scaleY = size.height / treeMask.length;

    // Draw tree overlay
    _drawMask(
      canvas,
      treeMask,
      treeColor,
      scaleX,
      scaleY,
    );

    // Draw field overlay
    _drawMask(
      canvas,
      fieldMask,
      fieldColor,
      scaleX,
      scaleY,
    );

    // Draw available land overlay
    _drawHeatmap(
      canvas,
      segmentationMap,
      landColor,
      scaleX,
      scaleY,
    );
  }

  void _drawMask(Canvas canvas, List<List<bool>> mask, Color color, double scaleX, double scaleY) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int y = 0; y < mask.length; y++) {
      for (int x = 0; x < mask[y].length; x++) {
        if (mask[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * scaleX,
              y * scaleY,
              scaleX,
              scaleY,
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawHeatmap(Canvas canvas, List<List<double>> heatmap, Color baseColor, double scaleX, double scaleY) {
    for (int y = 0; y < heatmap.length; y++) {
      for (int x = 0; x < heatmap[y].length; x++) {
        final intensity = heatmap[y][x];
        if (intensity > 0) {
          final paint = Paint()
            ..color = baseColor.withOpacity(intensity * 0.5)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(
              x * scaleX,
              y * scaleY,
              scaleX,
              scaleY,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom widget to display analysis results with visualization
class AnalysisResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;
  final File originalImage;

  const AnalysisResultsWidget({
    Key? key,
    required this.results,
    required this.originalImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmentation visualization
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: SegmentationVisualization(
                segmentationData: results,
                width: double.infinity,
                height: double.infinity,
                originalImage: originalImage,
              ),
            ),
          ),

          // Analysis results
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                _buildResultRow(
                  context,
                  'Available Land',
                  '${results['totalLandArea'].toStringAsFixed(2)} acres',
                  Icons.landscape,
                ),
                SizedBox(height: 8),
                _buildResultRow(
                  context,
                  'Potential Trees',
                  '${results['potentialTrees']}',
                  Icons.nature,
                ),
                SizedBox(height: 8),
                _buildResultRow(
                  context,
                  'Green Coverage',
                  '${results['greenCoverage'].toStringAsFixed(1)}%',
                  Icons.eco,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
