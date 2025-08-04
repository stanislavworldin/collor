# Collor

A **super lightweight** and elegant color picker library for Flutter applications.

## 🚀 Super Lightweight

This color picker is designed to be as lightweight as possible while maintaining full functionality:
- **Only 1 file** - Single `color_picker_popup.dart` file
- **Only 92KB** - Ultra compact size
- **Only 325 lines of code**
- **Zero external dependencies**
- **Minimal memory footprint**
- **Fast rendering**

## Features

- **Interactive Color Square**: A square gradient that allows you to select colors by clicking or dragging
- **Hue Slider**: A rainbow slider to select the base hue
- **Value Slider**: A slider to adjust the brightness/value of the selected color
- **Real-time Color Display**: Shows HEX, RGB, and HSV values in real-time
- **Clean UI**: Modern and intuitive interface with rectangular design
- **Customizable**: Easy to integrate into any Flutter app
- **No Close Button**: Minimalist design without unnecessary UI elements

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  collor: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:collor/collor.dart';

// Show color picker
void _showColorPicker() async {
  final Color? result = await showDialog<Color>(
    context: context,
    builder: (BuildContext context) {
      return ColorPickerPopup(
        initialColor: Colors.blue,
        onColorSelected: (Color color) {
          // Handle selected color
          print('Selected color: $color');
        },
      );
    },
  );
  
  if (result != null) {
    // Use selected color
    setState(() {
      _selectedColor = result;
    });
  }
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:collor/collor.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _selectedColor = Colors.blue;

  void _showColorPicker() async {
    final Color? result = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerPopup(
          initialColor: _selectedColor,
          onColorSelected: (Color color) {
            setState(() {
              _selectedColor = color;
            });
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedColor = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Select a color:', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            
            // Display selected color
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Color information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('HEX:'),
                      Text('#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RGB:'),
                      Text('${(_selectedColor.r * 255.0).round()}, ${(_selectedColor.g * 255.0).round()}, ${(_selectedColor.b * 255.0).round()}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Color picker button
            ElevatedButton(
              onPressed: _showColorPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Select Color', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### ColorPickerPopup

The main color picker widget.

#### Constructor

```dart
ColorPickerPopup({
  required Color initialColor,
  required Function(Color) onColorSelected,
})
```

#### Parameters

- `initialColor`: The initial color to display in the picker
- `onColorSelected`: Callback function called when a color is selected

## Testing

Run the tests to ensure everything works correctly:

```bash
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 