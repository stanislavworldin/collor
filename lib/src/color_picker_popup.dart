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
      _isColorPickerFixed = true;
    });
  }

  void _onColorPickerDoubleTap(TapDownDetails details) {
    setState(() {
      _isColorPickerFixed = false;
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

  Widget _buildSlider({
    required List<Color> colors,
    required Offset position,
    required bool isHueSlider,
  }) {
    return Container(
      width: _size,
      height: _sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        gradient: LinearGradient(colors: colors),
      ),
      child: GestureDetector(
        onPanUpdate: (details) => _onSliderPanUpdate(details, isHueSlider),
        child: CustomPaint(painter: SliderPainter(position)),
      ),
    );
  }

  Widget _buildColorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.zero,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: 320,
        height: 580,
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  borderRadius: BorderRadius.zero,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.white,
                      HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor()
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                  child: GestureDetector(
                    onTapDown: _onColorPickerTap,
                    onDoubleTapDown: _onColorPickerDoubleTap,
                    child: CustomPaint(
                        painter: ColorPickerPainter(
                            _colorPickerPosition, _selectedColor)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Индикатор состояния
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _isColorPickerFixed ? Colors.green[100] : Colors.blue[100],
                borderRadius: BorderRadius.zero,
              ),
              child: Text(
                _isColorPickerFixed
                    ? 'Fixed - Double tap to unfix'
                    : 'Hover to select color',
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
                  (index) => HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0)
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
            const Spacer(),

            // Кнопка выбора
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onColorSelected(_selectedColor);
                  Navigator.of(context).pop(_selectedColor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Select', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerPainter extends CustomPainter {
  final Offset position;
  final Color currentColor;

  ColorPickerPainter(this.position, this.currentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 8, paint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(position, 8, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SliderPainter extends CustomPainter {
  final Offset position;

  SliderPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 10, paint);

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, 10, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
