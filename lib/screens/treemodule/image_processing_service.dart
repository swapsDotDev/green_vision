// lib/services/image_processing_service.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:collection/collection.dart';

class ImageProcessingService {
  static const int ZOOM_LEVEL = 18;
  static const double EARTH_RADIUS = 6378137.0;
  static const double PI = 3.141592653589793;
  static const double EQUATOR_CIRCUMFERENCE = 2 * PI * EARTH_RADIUS;
  static const double INITIAL_RESOLUTION = EQUATOR_CIRCUMFERENCE / 256.0;
  static const double ORIGIN_SHIFT = EQUATOR_CIRCUMFERENCE / 2.0;

  // Image segmentation parameters
  static const List<List<double>> TREE_HSV_RANGE = [
    [10, 0, 10],
    [180, 180, 75]
  ];
  static const List<List<double>> FIELD_HSV_RANGE = [
    [0, 20, 100],
    [50, 255, 255]
  ];

  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      // Load and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      // Convert to HSV and perform segmentation
      final segmentationResult = await _performSegmentation(image);

      // Calculate available land and tree capacity
      final analysisResults = _calculateLandArea(segmentationResult);

      return {
        'success': true,
        'totalLandArea': analysisResults['totalAreaAcres'],
        'potentialTrees': analysisResults['numberOfTrees'],
        'segmentationMap': segmentationResult['segmentationMap'],
        'greenCoverage': analysisResults['greenCoverage'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> _performSegmentation(img.Image image) async {
    // Convert RGB to HSV
    final hsvImage = _convertToHSV(image);

    // Create masks for different segments
    final treeMask = _createMask(hsvImage, TREE_HSV_RANGE[0], TREE_HSV_RANGE[1]);
    final fieldMask = _createMask(hsvImage, FIELD_HSV_RANGE[0], FIELD_HSV_RANGE[1]);

    // Combine masks and apply Gaussian blur for smoothing
    final combinedMask = _combineMasks([treeMask, fieldMask]);
    final smoothedMask = _applyGaussianBlur(combinedMask, sigma: 1.5);

    return {
      'segmentationMap': smoothedMask,
      'treeMask': treeMask,
      'fieldMask': fieldMask,
    };
  }

  Map<String, dynamic> _calculateLandArea(Map<String, dynamic> segmentationResult) {
    final segmentationMap = segmentationResult['segmentationMap'];
    final pixelCount = segmentationMap.length;
    final nonZeroPixels = segmentationMap.where((pixel) => pixel > 0).length;

    // Calculate area using Google Maps zoom level 18 scale
    // At zoom level 18, 1cm² = 516.5289256198347 m²
    const cmToSquareMeters = 516.5289256198347;
    const squareMetersToAcres = 0.000247105;
    const treesPerAcre = 10890; // Based on 2ft spacing between trees

    final percentageLand = nonZeroPixels / pixelCount;
    final totalAreaSquareMeters = (pixelCount * cmToSquareMeters) * percentageLand;
    final totalAreaAcres = totalAreaSquareMeters * squareMetersToAcres;
    final numberOfTrees = (totalAreaAcres * treesPerAcre).round();

    return {
      'totalAreaAcres': totalAreaAcres,
      'numberOfTrees': numberOfTrees,
      'greenCoverage': percentageLand * 100, // As percentage
    };
  }

  List<List<List<double>>> _convertToHSV(img.Image image) {
    final hsv = List.generate(
      image.height,
          (y) => List.generate(
        image.width,
            (x) => _rgbToHsv(image.getPixel(x, y)),
      ),
    );
    return hsv;
  }

  List<double> _rgbToHsv(int pixel) {
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;

    final max = [r, g, b].reduce(max);
    final min = [r, g, b].reduce(min);
    final delta = max - min;

    var h = 0.0;
    final s = max == 0 ? 0.0 : delta / max;
    final v = max / 255.0;

    if (delta != 0) {
      if (max == r) {
        h = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        h = 60 * (((b - r) / delta) + 2);
      } else {
        h = 60 * (((r - g) / delta) + 4);
      }
    }

    if (h < 0) h += 360;

    return [h, s * 100, v * 100];
  }

  List<List<bool>> _createMask(
      List<List<List<double>>> hsvImage,
      List<double> lower,
      List<double> upper,
      ) {
    return List.generate(
      hsvImage.length,
          (y) => List.generate(
        hsvImage[0].length,
            (x) => _isInRange(hsvImage[y][x], lower, upper),
      ),
    );
  }

  bool _isInRange(List<double> pixel, List<double> lower, List<double> upper) {
    return pixel[0] >= lower[0] &&
        pixel[0] <= upper[0] &&
        pixel[1] >= lower[1] &&
        pixel[1] <= upper[1] &&
        pixel[2] >= lower[2] &&
        pixel[2] <= upper[2];
  }

  List<List<bool>> _combineMasks(List<List<List<bool>>> masks) {
    final height = masks[0].length;
    final width = masks[0][0].length;

    return List.generate(
      height,
          (y) => List.generate(
        width,
            (x) => masks.any((mask) => mask[y][x]),
      ),
    );
  }

  List<List<double>> _applyGaussianBlur(List<List<bool>> mask, {double sigma = 1.5}) {
    // Implementation of Gaussian blur
    // This is a simplified version - you might want to use a proper image processing library
    final kernel = _createGaussianKernel(sigma);
    final result = List.generate(
      mask.length,
          (y) => List.generate(
        mask[0].length,
            (x) => _applyKernel(mask, x, y, kernel),
      ),
    );
    return result;
  }

  List<List<double>> _createGaussianKernel(double sigma) {
    final size = (sigma * 3).ceil() * 2 + 1;
    final kernel = List.generate(
      size,
          (y) => List.generate(
        size,
            (x) {
          final xDist = x - (size ~/ 2);
          final yDist = y - (size ~/ 2);
          return (1 / (2 * PI * sigma * sigma)) *
              exp(-(xDist * xDist + yDist * yDist) / (2 * sigma * sigma));
        },
      ),
    );
    return kernel;
  }

  double _applyKernel(List<List<bool>> image, int x, int y, List<List<double>> kernel) {
    var sum = 0.0;
    var weightSum = 0.0;

    for (var ky = 0; ky < kernel.length; ky++) {
      for (var kx = 0; kx < kernel[0].length; kx++) {
        final imageX = x + kx - (kernel.length ~/ 2);
        final imageY = y + ky - (kernel.length ~/ 2);

        if (imageX >= 0 && imageX < image[0].length && imageY >= 0 && imageY < image.length) {
          final weight = kernel[ky][kx];
          sum += image[imageY][imageX] ? weight : 0;
          weightSum += weight;
        }
      }
    }

    return sum / weightSum;
  }
}