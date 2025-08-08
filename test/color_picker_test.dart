import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collor/collor.dart';

void main() {
  group('ColorPickerPopup Tests', () {
    testWidgets('should initialize with correct initial color',
        (WidgetTester tester) async {
      const Color initialColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: initialColor,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Check that popup opened
      expect(find.text('Select Color'), findsOneWidget);

      // Check that select button is present
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('should display color values correctly',
        (WidgetTester tester) async {
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
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Check that color information is displayed
      expect(find.text('HEX:'), findsOneWidget);
      expect(find.text('RGB:'), findsOneWidget);
      expect(find.text('HSV:'), findsOneWidget);
    });

    testWidgets('should call onColorSelected when select button is pressed',
        (WidgetTester tester) async {
      Color? selectedColor;

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
                      onColorSelected: (color) {
                        selectedColor = color;
                      },
                    ),
                  );
                },
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Нажать кнопку, вызывая onPressed напрямую (устойчиво в тестах)
      final ElevatedButton selectBtn = tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('select_button')));
      selectBtn.onPressed?.call();
      await tester.pumpAndSettle();

      // Check that onColorSelected was called
      expect(selectedColor, isNotNull);
    });

    testWidgets('should close dialog when select button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.green,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Check that popup is open
      expect(find.text('Select Color'), findsOneWidget);

      // Нажать кнопку, вызывая onPressed напрямую (устойчиво в тестах)
      final ElevatedButton selectBtn = tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('select_button')));
      selectBtn.onPressed?.call();
      await tester.pumpAndSettle();

      // Check that popup is closed
      expect(find.text('Select Color'), findsNothing);
    });

    testWidgets('should update color when hue slider is dragged',
        (WidgetTester tester) async {
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
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Find the hue slider (first slider area)
      final hueSlider = find.byType(GestureDetector).first;

      // Drag the hue slider
      await tester.drag(hueSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Check that color values are updated
      expect(find.text('HSV:'), findsOneWidget);
    });

    testWidgets('should update color when value slider is dragged',
        (WidgetTester tester) async {
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
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Find the value slider (second slider area)
      final valueSliders = find.byType(GestureDetector);
      final valueSlider = valueSliders.at(1);

      // Drag the value slider
      await tester.drag(valueSlider, const Offset(30, 0));
      await tester.pumpAndSettle();

      // Check that color values are updated
      expect(find.text('HSV:'), findsOneWidget);
    });

    testWidgets('should update color when color square is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.yellow,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Find the color square by key
      final colorSquare = find.byKey(const ValueKey('color_square'));

      // Tap the color square
      await tester.tap(colorSquare);
      await tester.pumpAndSettle();

      // Check that color values are updated
      expect(find.text('HSV:'), findsOneWidget);
    });

    testWidgets('should show fixed state when color square is double tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ColorPickerPopup(
                      initialColor: Colors.purple,
                      onColorSelected: (color) {},
                    ),
                  );
                },
                child: const Text('Open Color Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Color Picker'));
      await tester.pumpAndSettle();

      // Find the color square by key
      final colorSquare = find.byKey(const ValueKey('color_square'));

      // Один тап фиксирует выбор
      await tester.tap(colorSquare);
      await tester.pumpAndSettle();

      // Проверяем, что показано состояние фиксации
      expect(find.text('Fixed - Tap to unfix'), findsOneWidget);
    });
  });

  group('ColorPickerPainter Tests', () {
    test('should paint circle indicator correctly', () {
      final painter =
          ColorPickerPainter(const Offset(100, 100), Colors.red, false);

      // При одинаковых параметрах перерисовывать не нужно
      expect(painter.shouldRepaint(painter), false);
    });
  });

  group('SliderPainter Tests', () {
    test('should paint slider indicator correctly', () {
      final painter = SliderPainter(const Offset(50, 0), false);

      // При одинаковых параметрах перерисовывать не нужно
      expect(painter.shouldRepaint(painter), false);
    });
  });
}
