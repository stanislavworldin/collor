import 'package:flutter/material.dart';
import 'package:collor/src/color_picker_popup.dart';

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

  void _showColorPicker() async {
    debugPrint('MyHomePage: showing color picker');
    
    final Color? result = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerPopup(
          initialColor: _selectedColor,
          onColorSelected: (Color color) {
            debugPrint('MyHomePage: color selected ${color.toString()}');
            setState(() {
              _selectedColor = color;
            });
          },
        );
      },
    );

    if (result != null) {
      debugPrint('MyHomePage: dialog returned color ${result.toString()}');
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
            const Text(
              'Select a color:',
              style: TextStyle(fontSize: 24),
            ),
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
            
            // Кнопка выбора цвета
            ElevatedButton(
              onPressed: _showColorPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Select Color',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
