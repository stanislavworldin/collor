import 'package:flutter/material.dart';

class ColorPickerPopup extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerPopup({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerPopup> createState() => _ColorPickerPopupState();
}

class _ColorPickerPopupState extends State<ColorPickerPopup> {
  late Color _selectedColor;
  late double _hue, _saturation, _value;
  late Offset _colorPickerPosition, _hueSliderPosition, _valueSliderPosition;
  final GlobalKey _colorPickerKey = GlobalKey();
  bool _isColorPickerFixed = false;
  bool _isDragging = false;

  static const double _size = 200.0;
  static const double _sliderHeight = 30.0;
  static const double _sliderY = 15.0;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateHSVFromColor(_selectedColor);
    _initializePositions();
  }

  void _initializePositions() {
    _colorPickerPosition = Offset(_saturation * _size, (1.0 - _value) * _size);
    _hueSliderPosition = Offset(_hue / 360.0 * _size, _sliderY);
    _valueSliderPosition = Offset(_value * _size, _sliderY);
  }

  void _updateHSVFromColor(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColorFromHSV() {
    _selectedColor =
        HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  void _updateColorPickerPosition(Offset localPosition) {
    final double newX = localPosition.dx.clamp(0.0, _size);
    final double newY = localPosition.dy.clamp(0.0, _size);
    _colorPickerPosition = Offset(newX, newY);
    _saturation = newX / _size;
    _value = 1.0 - (newY / _size);
    _updateColorFromHSV();
  }

  void _onColorPickerHover(PointerEvent event) {
    if (!_isColorPickerFixed) {
      setState(() {
        final RenderBox renderBox =
            _colorPickerKey.currentContext!.findRenderObject() as RenderBox;
        _updateColorPickerPosition(renderBox.globalToLocal(event.position));
      });
    }
  }

  void _onColorPickerTap(TapDownDetails details) {
    setState(() {
      final RenderBox renderBox =
          _colorPickerKey.currentContext!.findRenderObject() as RenderBox;
      _updateColorPickerPosition(
          renderBox.globalToLocal(details.globalPosition));
      _isColorPickerFixed =
          !_isColorPickerFixed; // Переключаем состояние одним нажатием
    });
  }

  void _onColorPickerDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onColorPickerDragUpdate(DragUpdateDetails details) {
    setState(() {
      final RenderBox renderBox =
          _colorPickerKey.currentContext!.findRenderObject() as RenderBox;
      _updateColorPickerPosition(
          renderBox.globalToLocal(details.globalPosition));
    });
  }

  void _onColorPickerDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _onSliderPanStart(DragStartDetails details, bool isHueSlider) {
    debugPrint(
        'ColorPickerPopup: ${isHueSlider ? "hue" : "value"} slider drag started');
    setState(() {
      _isDragging = true;
    });
  }

  void _onSliderPanUpdate(DragUpdateDetails details, bool isHueSlider) {
    setState(() {
      final currentPosition =
          isHueSlider ? _hueSliderPosition : _valueSliderPosition;
      final double newX =
          (currentPosition.dx + details.delta.dx).clamp(0.0, _size);

      if (isHueSlider) {
        _hueSliderPosition = Offset(newX, _sliderY);
        _hue = newX / _size * 360.0;
      } else {
        _valueSliderPosition = Offset(newX, _sliderY);
        _value = newX / _size;
      }
      _updateColorFromHSV();
    });
  }

  void _onSliderPanEnd(DragEndDetails details, bool isHueSlider) {
    setState(() {
      _isDragging = false;
    });
  }

  Widget _buildSlider({
    required List<Color> colors,
    required Offset position,
    required bool isHueSlider,
  }) {
    return Container(
      width: _size,
      height: _sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sliderHeight / 2),
        gradient: LinearGradient(colors: colors),
        boxShadow: _isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: GestureDetector(
        onPanStart: (details) => _onSliderPanStart(details, isHueSlider),
        onPanUpdate: (details) => _onSliderPanUpdate(details, isHueSlider),
        onPanEnd: (details) => _onSliderPanEnd(details, isHueSlider),
        child: CustomPaint(painter: SliderPainter(position, _isDragging)),
      ),
    );
  }

  Widget _buildColorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('HEX:',
              '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}'),
          const SizedBox(height: 4),
          _buildInfoRow('RGB:',
              '${(_selectedColor.r * 255.0).round()}, ${(_selectedColor.g * 255.0).round()}, ${(_selectedColor.b * 255.0).round()}'),
          const SizedBox(height: 4),
          _buildInfoRow('HSV:',
              '${_hue.round()}, ${(_saturation * 100).round()}%, ${(_value * 100).round()}%'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Цветовой квадрат
              MouseRegion(
                onHover: _onColorPickerHover,
                child: Container(
                  key: _colorPickerKey,
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.white,
                        HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor()
                      ],
                    ),
                    boxShadow: _isDragging
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                    child: GestureDetector(
                      onTapDown: _onColorPickerTap,
                      onPanStart: _onColorPickerDragStart,
                      onPanUpdate: _onColorPickerDragUpdate,
                      onPanEnd: _onColorPickerDragEnd,
                      child: CustomPaint(
                          painter: ColorPickerPainter(_colorPickerPosition,
                              _selectedColor, _isDragging)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Индикатор состояния
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isColorPickerFixed
                      ? Colors.green[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isColorPickerFixed
                      ? 'Fixed - Tap to unfix'
                      : 'Touch and drag to select color',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isColorPickerFixed
                        ? Colors.green[800]
                        : Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ползунки
              _buildSlider(
                colors: List.generate(
                    360,
                    (index) =>
                        HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0)
                            .toColor()),
                position: _hueSliderPosition,
                isHueSlider: true,
              ),
              const SizedBox(height: 12),
              _buildSlider(
                colors: [
                  Colors.black,
                  HSVColor.fromAHSV(1.0, _hue, _saturation, 1.0).toColor()
                ],
                position: _valueSliderPosition,
                isHueSlider: false,
              ),
              const SizedBox(height: 12),

              _buildColorInfo(),
              const SizedBox(height: 16),

              // Кнопка выбора
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint(
                        'ColorPickerPopup: color selected ${_selectedColor.toString()}');
                    widget.onColorSelected(_selectedColor);
                    Navigator.of(context).pop(_selectedColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Select', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorPickerPainter extends CustomPainter {
  final Offset position;
  final Color currentColor;
  final bool isDragging;

  ColorPickerPainter(this.position, this.currentColor, this.isDragging);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = isDragging ? 12 : 8;

    // Внешняя тень при перетаскивании
    if (isDragging) {
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, radius + 2, shadowPaint);
    }

    // Основной круг
    final Paint paint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);

    // Белая граница
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragging ? 2 : 1;

    canvas.drawCircle(position, radius, borderPaint);

    // Дополнительная граница при перетаскивании
    if (isDragging) {
      final Paint outerBorderPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(position, radius + 1, outerBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SliderPainter extends CustomPainter {
  final Offset position;
  final bool isDragging;

  SliderPainter(this.position, this.isDragging);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = isDragging ? 14 : 10;

    // Основной круг
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
