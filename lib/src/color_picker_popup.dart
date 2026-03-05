import 'package:flutter/material.dart';

/// A simple, dependency-free color picker dialog with hue/value sliders
/// and an optional alpha slider.
class ColorPickerPopup extends StatefulWidget {
  final Color initialColor;

  /// Called when user confirms selection via the Select button
  final ValueChanged<Color> onColorSelected;
  // Вызывается при каждом изменении цвета (drag/hover/тап)
  final ValueChanged<Color>? onChanged;
  // Показать слайдер альфа-канала и включить расчёт RGBA/HSVA
  final bool showAlpha;

  const ColorPickerPopup({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
    this.onChanged,
    this.showAlpha = false,
  });

  @override
  State<ColorPickerPopup> createState() => _ColorPickerPopupState();
}

class _ColorPickerPopupState extends State<ColorPickerPopup> {
  late Color _selectedColor;
  late double _hue, _saturation, _value;
  late double _alpha;
  late Offset _colorPickerPosition, _hueSliderPosition, _valueSliderPosition;
  late Offset _alphaSliderPosition;
  bool _isColorPickerFixed = false;
  bool _isDragging = false;

  static const double _size = 200.0;
  static const double _sliderHeight = 30.0;
  static const double _sliderMargin = 2.0;
  static const double _sliderDragRadius = 14.0;
  double get _innerSliderWidth => _size - (_sliderMargin * 2);
  double get _innerSliderHeight => _sliderHeight - (_sliderMargin * 2);
  double get _sliderCenterY => _innerSliderHeight / 2;
  double get _sliderTrackStart => _sliderDragRadius;
  double get _sliderTrackEnd => _innerSliderWidth - _sliderDragRadius;
  double get _sliderTrackWidth => _sliderTrackEnd - _sliderTrackStart;
  // Кешированный список цветов для градиента оттенков (360 значений)
  static final List<Color> _hueGradientColors = List<Color>.generate(
    360,
    (int index) => HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0).toColor(),
  );

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateHSVFromColor(_selectedColor);
    _initializePositions();
  }

  @override
  void didUpdateWidget(covariant ColorPickerPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor.toARGB32() != widget.initialColor.toARGB32()) {
      setState(() {
        _selectedColor = widget.initialColor;
        _updateHSVFromColor(_selectedColor);
        _initializePositions();
      });
    }
  }

  void _initializePositions() {
    _colorPickerPosition = Offset(_saturation * _size, (1.0 - _value) * _size);
    _hueSliderPosition = Offset(_sliderXFromHue(_hue), _sliderCenterY);
    _valueSliderPosition = Offset(_sliderXFromUnit(_value), _sliderCenterY);
    _alphaSliderPosition = Offset(_sliderXFromUnit(_alpha), _sliderCenterY);
  }

  double _sliderXFromUnit(double value) {
    final double normalized = value.clamp(0.0, 1.0);
    return _sliderTrackStart + (normalized * _sliderTrackWidth);
  }

  double _sliderXFromHue(double hue) {
    final double normalized = hue.clamp(0.0, 360.0) / 360.0;
    return _sliderXFromUnit(normalized);
  }

  double _unitFromSliderX(double x) {
    return ((x - _sliderTrackStart) / _sliderTrackWidth).clamp(0.0, 1.0);
  }

  void _updateHSVFromColor(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    // Безопасно получаем альфу (0..1)
    final int a8 = (color.toARGB32() >> 24) & 0xFF;
    _alpha = a8 / 255.0;
  }

  bool _updateColorFromHSV() {
    final Color newColor = HSVColor.fromAHSV(
      _alpha,
      _hue,
      _saturation,
      _value,
    ).toColor();
    if (newColor.toARGB32() == _selectedColor.toARGB32()) {
      return false;
    }
    _selectedColor = newColor;
    widget.onChanged?.call(_selectedColor);
    return true;
  }

  bool _updateColorPickerPosition(Offset localPosition) {
    final double newX = localPosition.dx.clamp(0.0, _size);
    final double newY = localPosition.dy.clamp(0.0, _size);
    final Offset newPosition = Offset(newX, newY);
    if (newPosition == _colorPickerPosition) {
      return false;
    }
    _colorPickerPosition = newPosition;
    _saturation = newX / _size;
    _value = 1.0 - (newY / _size);
    _updateColorFromHSV();
    return true;
  }

  bool _updateSliderByPosition(double dx, {required bool isHueSlider}) {
    final double newX = dx.clamp(_sliderTrackStart, _sliderTrackEnd);
    if (isHueSlider) {
      if ((newX - _hueSliderPosition.dx).abs() < 0.001) {
        return false;
      }
      _hueSliderPosition = Offset(newX, _sliderCenterY);
      _hue = _unitFromSliderX(newX) * 360.0;
    } else {
      if ((newX - _valueSliderPosition.dx).abs() < 0.001) {
        return false;
      }
      _valueSliderPosition = Offset(newX, _sliderCenterY);
      _value = _unitFromSliderX(newX);
    }
    _updateColorFromHSV();
    return true;
  }

  bool _updateAlphaByPosition(double dx) {
    final double newX = dx.clamp(_sliderTrackStart, _sliderTrackEnd);
    if ((newX - _alphaSliderPosition.dx).abs() < 0.001) {
      return false;
    }
    _alphaSliderPosition = Offset(newX, _sliderCenterY);
    _alpha = _unitFromSliderX(newX);
    _updateColorFromHSV();
    return true;
  }

  void _onColorPickerHover(PointerEvent event) {
    if (_isColorPickerFixed || _isDragging) {
      return;
    }
    if (_updateColorPickerPosition(event.localPosition)) {
      setState(() {});
    }
  }

  void _onColorPickerTap(TapDownDetails details) {
    setState(() {
      _updateColorPickerPosition(details.localPosition);
      _isColorPickerFixed = !_isColorPickerFixed;
    });
  }

  void _onColorPickerDragStart(DragStartDetails details) {
    if (_isDragging) {
      return;
    }
    setState(() {
      _isDragging = true;
    });
  }

  void _onColorPickerDragUpdate(DragUpdateDetails details) {
    if (_updateColorPickerPosition(details.localPosition)) {
      setState(() {});
    }
  }

  void _onColorPickerDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }
    setState(() {
      _isDragging = false;
    });
  }

  void _onSliderPanStart(DragStartDetails details, bool isHueSlider) {
    if (_isDragging) {
      return;
    }
    setState(() {
      _isDragging = true;
    });
  }

  void _onSliderPanUpdate(DragUpdateDetails details, bool isHueSlider) {
    if (_updateSliderByPosition(details.localPosition.dx,
        isHueSlider: isHueSlider)) {
      setState(() {});
    }
  }

  void _onSliderPanEnd(DragEndDetails details, bool isHueSlider) {
    if (!_isDragging) {
      return;
    }
    setState(() {
      _isDragging = false;
    });
  }

  void _onAlphaPanStart(DragStartDetails details) {
    if (_isDragging) {
      return;
    }
    setState(() {
      _isDragging = true;
    });
  }

  void _onAlphaPanUpdate(DragUpdateDetails details) {
    if (_updateAlphaByPosition(details.localPosition.dx)) {
      setState(() {});
    }
  }

  void _onAlphaPanEnd(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }
    setState(() {
      _isDragging = false;
    });
  }

  Widget _buildSlider({
    required List<Color> colors,
    required Offset position,
    required bool isHueSlider,
    required Key sliderKey,
  }) {
    return Tooltip(
      message: isHueSlider ? 'Hue' : 'Value',
      child: Container(
        width: _size,
        height: _sliderHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(_sliderHeight / 2),
          boxShadow: _isDragging
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((_sliderHeight / 2) - 2),
            gradient: LinearGradient(colors: colors),
          ),
          child: GestureDetector(
            key: sliderKey,
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) => _onSliderPanStart(details, isHueSlider),
            onPanUpdate: (details) => _onSliderPanUpdate(details, isHueSlider),
            onPanEnd: (details) => _onSliderPanEnd(details, isHueSlider),
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SliderPainter(position, _isDragging),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlphaSlider(Color baseColor) {
    final List<Color> colors = [
      baseColor.withValues(alpha: 0.0),
      baseColor.withValues(alpha: 1.0),
    ];
    return Tooltip(
      message: 'Alpha',
      child: Container(
        width: _size,
        height: _sliderHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(_sliderHeight / 2),
          boxShadow: _isDragging
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((_sliderHeight / 2) - 2),
            gradient: LinearGradient(colors: colors),
          ),
          child: GestureDetector(
            key: const ValueKey('alpha_slider_gesture'),
            behavior: HitTestBehavior.opaque,
            onPanStart: _onAlphaPanStart,
            onPanUpdate: _onAlphaPanUpdate,
            onPanEnd: _onAlphaPanEnd,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SliderPainter(_alphaSliderPosition, _isDragging),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorInfo() {
    final int argb = _selectedColor.toARGB32();
    final int alpha = (argb >> 24) & 0xFF;
    final int red = (argb >> 16) & 0xFF;
    final int green = (argb >> 8) & 0xFF;
    final int blue = argb & 0xFF;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'HEX:',
            '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            'RGB:',
            '$red, $green, $blue',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            'HSV:',
            '${_hue.round()}, ${(_saturation * 100).round()}%, ${(_value * 100).round()}%',
          ),
          if (widget.showAlpha) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              'RGBA:',
              '$alpha, $red, $green, $blue',
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              'HSVA:',
              '${_hue.round()}, ${(_saturation * 100).round()}%, ${(_value * 100).round()}%, ${(100 * _alpha).round()}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
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
              // Заголовок удалён по требованию

              // Цветовой квадрат
              Tooltip(
                message: 'Color square: tap to toggle lock, drag to pick',
                child: MouseRegion(
                  key: const ValueKey('color_square'),
                  onHover: _onColorPickerHover,
                  child: Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.white,
                          HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
                        ],
                      ),
                      boxShadow: _isDragging
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
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
                        behavior: HitTestBehavior.opaque,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: ColorPickerPainter(
                              _colorPickerPosition,
                              _selectedColor,
                              _isDragging,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Индикатор состояния
              Container(
                key: const ValueKey('state_indicator'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                colors: _hueGradientColors,
                position: _hueSliderPosition,
                isHueSlider: true,
                sliderKey: const ValueKey('hue_slider_gesture'),
              ),
              const SizedBox(height: 12),
              _buildSlider(
                colors: [
                  Colors.black,
                  HSVColor.fromAHSV(1.0, _hue, _saturation, 1.0).toColor(),
                ],
                position: _valueSliderPosition,
                isHueSlider: false,
                sliderKey: const ValueKey('value_slider_gesture'),
              ),
              if (widget.showAlpha) ...[
                const SizedBox(height: 12),
                _buildAlphaSlider(
                  HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor(),
                ),
              ],
              const SizedBox(height: 12),

              _buildColorInfo(),
              const SizedBox(height: 16),

              // Кнопка выбора
              SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: 'Confirm selected color',
                  child: ElevatedButton(
                    key: const ValueKey('select_button'),
                    onPressed: () {
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
  bool shouldRepaint(covariant ColorPickerPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.isDragging != isDragging;
  }
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
  bool shouldRepaint(covariant SliderPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.isDragging != isDragging;
  }
}
