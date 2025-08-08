# Collor

A super lightweight and elegant color picker library for Flutter applications.

## 🎮 Live Demo

Try the color picker in action: **[Live Demo](https://stanislavworldin.github.io/collor/)**

![Collor Color Picker Demo](https://raw.githubusercontent.com/stanislavworldin/collor/main/screenshots/1.png)

## 🚀 Super Lightweight

This color picker is designed to be as lightweight as possible while maintaining full functionality:
- Only 1 file - Single `color_picker_popup.dart` file
- Only ~16KB - Ultra compact size
- Zero external dependencies
- Minimal memory footprint
- Fast rendering

## Features

- Interactive color square with touch/drag support
- Hue and value sliders
- Optional alpha slider (transparency)
- Real-time HEX, RGB, HSV (and RGBA/HSVA when alpha is enabled)
- Optional onChanged callback for real-time updates
- Lock picker toggle (via switch or tap on color square)
- Mobile optimized
- Zero dependencies

## Installation

```yaml
dependencies:
  collor: ^1.1.2
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
        onChanged: (color) {
          // Optional: react to live updates
          // setState(() => _selectedColor = color);
        },
        showAlpha: true, // Enable alpha slider
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
          child: const Text('Pick Color'),
        ),
      ),
    );
  }
}
```

## API

```dart
ColorPickerPopup({
  required Color initialColor,                // Starting color
  required Function(Color) onColorSelected,   // Callback when color is selected (confirm)
  ValueChanged<Color>? onChanged,             // Optional: live updates while dragging/hovering
  bool showAlpha = false,                     // Optional: show alpha slider (transparency)
})
```

## Getting Color Values

```dart
// HEX (AA RR GG BB without alpha prefix)
String hex = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

// RGB
String rgb = '${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}';

// HSV
final hsv = HSVColor.fromColor(color);
String hsvString = '${hsv.hue.round()}, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%';

// When showAlpha is enabled (RGBA / HSVA)
int a = (color.toARGB32() >> 24) & 0xFF; // 0..255
String rgba = '$a, ${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}';
String hsva = '${hsv.hue.round()}, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%, ${(100 * (a / 255)).round()}%';
```

## Tips
- Tap on the color square to toggle the picker lock (freeze hover updates).
- Use the switch under the status indicator to lock/unlock the picker.
- Use `onChanged` to reflect color live while dragging.

## License

MIT License