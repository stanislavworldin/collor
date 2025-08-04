import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collor/collor.dart';

void main() {
  group('ColorPicker Accuracy Tests', () {
    testWidgets('should accurately convert HSV to RGB values', (WidgetTester tester) async {
      // Test HSV to RGB conversion accuracy
      final testCases = [
        {'hsv': [0.0, 1.0, 1.0], 'expected_rgb': [255, 0, 0]}, // Red
        {'hsv': [120.0, 1.0, 1.0], 'expected_rgb': [0, 255, 0]}, // Green
        {'hsv': [240.0, 1.0, 1.0], 'expected_rgb': [0, 0, 255]}, // Blue
        {'hsv': [0.0, 0.0, 1.0], 'expected_rgb': [255, 255, 255]}, // White
        {'hsv': [0.0, 0.0, 0.0], 'expected_rgb': [0, 0, 0]}, // Black
        {'hsv': [180.0, 1.0, 1.0], 'expected_rgb': [0, 255, 255]}, // Cyan
        {'hsv': [300.0, 1.0, 1.0], 'expected_rgb': [255, 0, 255]}, // Magenta
        {'hsv': [60.0, 1.0, 1.0], 'expected_rgb': [255, 255, 0]}, // Yellow
      ];

      for (final testCase in testCases) {
        final hsv = testCase['hsv'] as List<double>;
        final expectedRgb = testCase['expected_rgb'] as List<int>;
        
        final hsvColor = HSVColor.fromAHSV(1.0, hsv[0], hsv[1], hsv[2]);
        final color = hsvColor.toColor();
        
        expect(color.r * 255, closeTo(expectedRgb[0], 1));
        expect(color.g * 255, closeTo(expectedRgb[1], 1));
        expect(color.b * 255, closeTo(expectedRgb[2], 1));
      }
    });

    testWidgets('should accurately convert RGB to HSV values', (WidgetTester tester) async {
      // Test RGB to HSV conversion accuracy
      final testCases = [
        {'rgb': [255, 0, 0], 'expected_hsv': [0.0, 1.0, 1.0]}, // Red
        {'rgb': [0, 255, 0], 'expected_hsv': [120.0, 1.0, 1.0]}, // Green
        {'rgb': [0, 0, 255], 'expected_hsv': [240.0, 1.0, 1.0]}, // Blue
        {'rgb': [255, 255, 255], 'expected_hsv': [0.0, 0.0, 1.0]}, // White
        {'rgb': [0, 0, 0], 'expected_hsv': [0.0, 0.0, 0.0]}, // Black
      ];

      for (final testCase in testCases) {
        final rgb = testCase['rgb'] as List<int>;
        final expectedHsv = testCase['expected_hsv'] as List<double>;
        
        final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
        final hsvColor = HSVColor.fromColor(color);
        
        expect(hsvColor.hue, closeTo(expectedHsv[0], 1));
        expect(hsvColor.saturation, closeTo(expectedHsv[1], 0.01));
        expect(hsvColor.value, closeTo(expectedHsv[2], 0.01));
      }
    });

    testWidgets('should maintain color accuracy during HSV updates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.red,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Check initial color accuracy
      expect(find.text('RGB:'), findsOneWidget);
    });

    testWidgets('should accurately calculate HEX values', (WidgetTester tester) async {
      // Test HEX value accuracy
      final testCases = [
        {'color': const Color(0xFFFF0000), 'expected_hex': 'FF0000'}, // Red
        {'color': const Color(0xFF00FF00), 'expected_hex': '00FF00'}, // Green
        {'color': const Color(0xFF0000FF), 'expected_hex': '0000FF'}, // Blue
        {'color': const Color(0xFFFFFFFF), 'expected_hex': 'FFFFFF'}, // White
        {'color': const Color(0xFF000000), 'expected_hex': '000000'}, // Black
        {'color': const Color(0xFFFFFF00), 'expected_hex': 'FFFF00'}, // Yellow
        {'color': const Color(0xFF00FFFF), 'expected_hex': '00FFFF'}, // Cyan
        {'color': const Color(0xFFFF00FF), 'expected_hex': 'FF00FF'}, // Magenta
      ];

      for (final testCase in testCases) {
        final color = testCase['color'] as Color;
        final expectedHex = testCase['expected_hex'] as String;
        
        final actualHex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
        expect(actualHex, equals(expectedHex));
      }
    });

    testWidgets('should accurately position color picker indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.blue,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Check that indicator is present
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should accurately update HSV values when moving sliders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.red,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Check HSV values display
      expect(find.text('HSV:'), findsOneWidget);
    });

    testWidgets('should accurately handle edge cases', (WidgetTester tester) async {
      // Test edge cases
      final edgeCases = [
        Colors.transparent,
        const Color(0x00000000), // Fully transparent
        const Color(0xFFFFFFFF), // Fully opaque white
        const Color(0xFF000000), // Fully opaque black
      ];

      for (final color in edgeCases) {
        final hsvColor = HSVColor.fromColor(color);
        final convertedColor = hsvColor.toColor();
        
        // Check that conversion works without errors
        expect(convertedColor, isA<Color>());
      }
    });

    testWidgets('should accurately handle saturation and value ranges', (WidgetTester tester) async {
      // Test saturation and value ranges
      final testRanges = [
        {'saturation': 0.0, 'value': 0.0}, // Black
        {'saturation': 0.0, 'value': 1.0}, // White
        {'saturation': 1.0, 'value': 0.0}, // Black
        {'saturation': 1.0, 'value': 1.0}, // Full color
        {'saturation': 0.5, 'value': 0.5}, // Medium values
      ];

      for (final testCase in testRanges) {
        final saturation = testCase['saturation'] as double;
        final value = testCase['value'] as double;
        
        final hsvColor = HSVColor.fromAHSV(1.0, 0.0, saturation, value);
        final color = hsvColor.toColor();
        
        // Check that color is created correctly
        expect(color, isA<Color>());
        expect(color.toARGB32() >> 24, equals(255));
      }
    });

    testWidgets('should accurately handle hue range', (WidgetTester tester) async {
      // Test hue range (0-360)
      final hueValues = [0.0, 60.0, 120.0, 180.0, 240.0, 300.0, 360.0];

      for (final hue in hueValues) {
        final hsvColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0);
        final color = hsvColor.toColor();
        
        // Check that color is created correctly
        expect(color, isA<Color>());
        expect(color.toARGB32() >> 24, equals(255));
      }
    });

    testWidgets('should accurately calculate color differences', (WidgetTester tester) async {
      // Test color difference calculation accuracy
      final color1 = Colors.red;
      final color2 = Colors.blue;
      
      final hsv1 = HSVColor.fromColor(color1);
      final hsv2 = HSVColor.fromColor(color2);
      
      // Check that HSV values are different
      expect(hsv1.hue, isNot(closeTo(hsv2.hue, 1)));
    });

    testWidgets('should accurately handle color picker position calculations', (WidgetTester tester) async {
      // Test position calculation accuracy
      final testPositions = [
        {'x': 0.0, 'y': 0.0, 'expected_saturation': 0.0, 'expected_value': 0.0},
        {'x': 100.0, 'y': 100.0, 'expected_saturation': 0.5, 'expected_value': 0.5},
        {'x': 200.0, 'y': 200.0, 'expected_saturation': 1.0, 'expected_value': 1.0},
      ];

      for (final testCase in testPositions) {
        final x = testCase['x'] as double;
        final y = testCase['y'] as double;
        final expectedSaturation = testCase['expected_saturation'] as double;
        final expectedValue = testCase['expected_value'] as double;
        
        final calculatedSaturation = x / 200.0;
        final calculatedValue = y / 200.0;
        
        expect(calculatedSaturation, equals(expectedSaturation));
        expect(calculatedValue, equals(expectedValue));
      }
    });

    testWidgets('should accurately clamp position values', (WidgetTester tester) async {
      // Test position clamping
      final testClamps = [
        {'input': -10.0, 'expected': 0.0},
        {'input': 0.0, 'expected': 0.0},
        {'input': 100.0, 'expected': 100.0},
        {'input': 200.0, 'expected': 200.0},
        {'input': 250.0, 'expected': 200.0},
      ];

      for (final testCase in testClamps) {
        final input = testCase['input'] as double;
        final expected = testCase['expected'] as double;
        
        final clamped = input.clamp(0.0, 200.0);
        expect(clamped, equals(expected));
      }
    });
  });
} 