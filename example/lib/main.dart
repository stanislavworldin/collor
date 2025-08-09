import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collor/collor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Collor Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _selectedColor = Colors.blue;

  // Функция для получения HSV значений
  Map<String, int> _getHSVValues(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    return {
      'h': hsv.hue.round(),
      's': (hsv.saturation * 100).round(),
      'v': (hsv.value * 100).round(),
    };
  }

  // Функция для получения RGBA/HSVA значений
  Map<String, int> _getRGBAValues(Color color) {
    final int a = (color.a * 255.0).round() & 0xFF;
    return {
      'a': a,
      'r': (color.r * 255.0).round(),
      'g': (color.g * 255.0).round(),
      'b': (color.b * 255.0).round(),
    };
  }

  Map<String, int> _getHSVAValues(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    final int aPercent = ((color.a * 100.0)).round();
    return {
      'h': hsv.hue.round(),
      's': (hsv.saturation * 100).round(),
      'v': (hsv.value * 100).round(),
      'a': aPercent,
    };
  }

  // Функция для копирования в буфер обмена
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
          onChanged: (Color color) {
            debugPrint('Example: onChanged -> $color');
            setState(() {
              _selectedColor = color;
            });
          },
          showAlpha: true,
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Select a color:', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),

            // Отображение выбранного цвета
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

            // Информация о цвете
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // HEX формат
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('HEX:'),
                      Row(
                        children: [
                          Text(
                              '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                                '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                            child: const Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // RGB формат
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RGB:'),
                      Row(
                        children: [
                          Text(
                              '${(_selectedColor.r * 255.0).round()}, ${(_selectedColor.g * 255.0).round()}, ${(_selectedColor.b * 255.0).round()}'),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                                '${(_selectedColor.r * 255.0).round()}, ${(_selectedColor.g * 255.0).round()}, ${(_selectedColor.b * 255.0).round()}'),
                            child: const Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // HSV формат
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('HSV:'),
                      Row(
                        children: [
                          Text(
                            '${_getHSVValues(_selectedColor)['h']}, ${_getHSVValues(_selectedColor)['s']}%, ${_getHSVValues(_selectedColor)['v']}%',
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                              '${_getHSVValues(_selectedColor)['h']}, ${_getHSVValues(_selectedColor)['s']}%, ${_getHSVValues(_selectedColor)['v']}%',
                            ),
                            child: const Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // RGBA формат
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('RGBA:'),
                      Row(
                        children: [
                          Text(
                            '${_getRGBAValues(_selectedColor)['a']}, ${_getRGBAValues(_selectedColor)['r']}, ${_getRGBAValues(_selectedColor)['g']}, ${_getRGBAValues(_selectedColor)['b']}',
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                              '${_getRGBAValues(_selectedColor)['a']}, ${_getRGBAValues(_selectedColor)['r']}, ${_getRGBAValues(_selectedColor)['g']}, ${_getRGBAValues(_selectedColor)['b']}',
                            ),
                            child: const Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // HSVA формат
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('HSVA:'),
                      Row(
                        children: [
                          Text(
                            '${_getHSVAValues(_selectedColor)['h']}, ${_getHSVAValues(_selectedColor)['s']}%, ${_getHSVAValues(_selectedColor)['v']}%, ${_getHSVAValues(_selectedColor)['a']}%',
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                              '${_getHSVAValues(_selectedColor)['h']}, ${_getHSVAValues(_selectedColor)['s']}%, ${_getHSVAValues(_selectedColor)['v']}%, ${_getHSVAValues(_selectedColor)['a']}%',
                            ),
                            child: const Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Кнопка выбора цвета
            ElevatedButton(
              onPressed: _showColorPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Select Color', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
