# Collor

A **super lightweight** and elegant color picker library for Flutter applications.

## 🎮 Live Demo

Try the color picker in action: **[Live Demo](https://stanislavworldin.github.io/collor/)**

Experience the full functionality of the color picker with interactive sliders, real-time color display, and smooth color selection.

## 🚀 Super Lightweight

This color picker is designed to be as lightweight as possible while maintaining full functionality:
- **Only 1 file** - Single `color_picker_popup.dart` file
- **Only 16KB** - Ultra compact size
- **Only 414 lines of code**
- **Zero external dependencies**
- **Minimal memory footprint**
- **Fast rendering**

## Features

- Interactive color square with touch/drag support
- Hue and value sliders
- Real-time HEX, RGB, HSV display
- One-click copy to clipboard
- Mobile optimized
- Zero dependencies

## Installation

```yaml
dependencies:
  collor: ^1.1.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:collor/collor.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _selectedColor = Colors.blue;

  void _showColorPicker() async {
    final Color? result = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerPopup(
        initialColor: _selectedColor,
        onColorSelected: (color) {
          setState(() => _selectedColor = color);
        },
      ),
    );
    
    if (result != null) {
      setState(() => _selectedColor = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _showColorPicker,
          child: Text('Pick Color'),
        ),
      ),
    );
  }
}
```

## API

### ColorPickerPopup

```dart
ColorPickerPopup({
  required Color initialColor,    // Starting color
  required Function(Color) onColorSelected,  // Callback when color is selected
})
```

### Getting Color Values

```dart
// HEX
String hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

// RGB
String rgb = '${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}';

// HSV
HSVColor hsv = HSVColor.fromColor(color);
String hsvString = '${hsv.hue.round()}, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%';
```

## License

MIT License 