import 'package:flutter/material.dart';

class ColorPickerPopup extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;
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
  final GlobalKey _colorPickerKey = GlobalKey();
  bool _isColorPickerFixed = false;
  bool _isDragging = false;

  static const double _size = 200.0;
  static const double _sliderHeight = 30.0;
  static const double _sliderMargin = 2.0;
  double get _innerSliderWidth => _size - (_sliderMargin * 2);
  double get _innerSliderHeight => _sliderHeight - (_sliderMargin * 2);
  double get _sliderCenterY => _innerSliderHeight / 2;
  // Кешированный список цветов для градиента оттенков (360 значений)
  static final List<Color> _hueGradientColors = List<Color>.generate(
      360,
      (int index) =>
          HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0).toColor());

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateHSVFromColor(_selectedColor);
    _initializePositions();
  }

  void _initializePositions() {
    _colorPickerPosition = Offset(_saturation * _size, (1.0 - _value) * _size);
    const double radius = 10.0; // начальный радиус индикатора
    final double hueX = (_hue / 360.0 * _innerSliderWidth)
        .clamp(radius, _innerSliderWidth - radius);
    final double valX =
        (_value * _innerSliderWidth).clamp(radius, _innerSliderWidth - radius);
    final double alpX =
        (_alpha * _innerSliderWidth).clamp(radius, _innerSliderWidth - radius);
    _hueSliderPosition = Offset(hueX, _sliderCenterY);
    _valueSliderPosition = Offset(valX, _sliderCenterY);
    _alphaSliderPosition = Offset(alpX, _sliderCenterY);
  }

  void _updateHSVFromColor(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    // Безопасно получаем альфу (0..1)
    final int a8 = color.toARGB32() >> 24;
    _alpha = a8 / 255.0;
  }

  void _updateColorFromHSV() {
    final Color newColor =
        HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor();
    if (newColor.toARGB32() == _selectedColor.toARGB32()) {
      return;
    }
    _selectedColor = newColor;
    debugPrint(
        'ColorPickerPopup: updated color from HSV -> H:${_hue.toStringAsFixed(1)} S:${(_saturation * 100).toStringAsFixed(1)}% V:${(_value * 100).toStringAsFixed(1)}% => ${_selectedColor.toString()}');
    if (widget.onChanged != null) {
      widget.onChanged!.call(_selectedColor);
    }
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
        final RenderObject? ro =
            _colorPickerKey.currentContext?.findRenderObject();
        if (ro is RenderBox) {
          _updateColorPickerPosition(ro.globalToLocal(event.position));
        } else {
          debugPrint('ColorPickerPopup: renderObject not ready on hover');
        }
      });
    }
  }

  void _onColorPickerTap(TapDownDetails details) {
    setState(() {
      final RenderObject? ro =
          _colorPickerKey.currentContext?.findRenderObject();
      if (ro is RenderBox) {
        _updateColorPickerPosition(ro.globalToLocal(details.globalPosition));
      } else {
        debugPrint('ColorPickerPopup: renderObject not ready on tap');
      }
      _isColorPickerFixed = !_isColorPickerFixed;
      debugPrint('ColorPickerPopup: fixed state -> $_isColorPickerFixed');
    });
  }

  void _onColorPickerDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onColorPickerDragUpdate(DragUpdateDetails details) {
    setState(() {
      final RenderObject? ro =
          _colorPickerKey.currentContext?.findRenderObject();
      if (ro is RenderBox) {
        _updateColorPickerPosition(ro.globalToLocal(details.globalPosition));
      }
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
      final double rawX = currentPosition.dx + details.delta.dx;
      final double radius = _isDragging ? 14.0 : 10.0;
      final double newX = rawX.clamp(radius, _innerSliderWidth - radius);

      if (isHueSlider) {
        _hueSliderPosition = Offset(newX, _sliderCenterY);
        _hue = (newX - radius) / (_innerSliderWidth - 2 * radius) * 360.0;
        _hue = _hue.clamp(0.0, 360.0);
      } else {
        _valueSliderPosition = Offset(newX, _sliderCenterY);
        _value = (newX - radius) / (_innerSliderWidth - 2 * radius);
        _value = _value.clamp(0.0, 1.0);
      }
      _updateColorFromHSV();
    });
  }

  void _onSliderPanEnd(DragEndDetails details, bool isHueSlider) {
    setState(() {
      _isDragging = false;
    });
  }

  void _onAlphaPanStart(DragStartDetails details) {
    debugPrint('ColorPickerPopup: alpha slider drag started');
    setState(() {
      _isDragging = true;
    });
  }

  void _onAlphaPanUpdate(DragUpdateDetails details) {
    setState(() {
      final double rawX = _alphaSliderPosition.dx + details.delta.dx;
      final double radius = _isDragging ? 14.0 : 10.0;
      final double newX = rawX.clamp(radius, _innerSliderWidth - radius);
      _alphaSliderPosition = Offset(newX, _sliderCenterY);
      _alpha = (newX - radius) / (_innerSliderWidth - 2 * radius);
      _alpha = _alpha.clamp(0.0, 1.0);
      _updateColorFromHSV();
    });
  }

  void _onAlphaPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  Widget _buildSlider({
    required List<Color> colors,
    required Offset position,
    required bool isHueSlider,
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
                  )
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
            onPanStart: (details) => _onSliderPanStart(details, isHueSlider),
            onPanUpdate: (details) => _onSliderPanUpdate(details, isHueSlider),
            onPanEnd: (details) => _onSliderPanEnd(details, isHueSlider),
            child: CustomPaint(
              painter: SliderPainter(position, _isDragging),
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
                  )
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
            onPanStart: _onAlphaPanStart,
            onPanUpdate: _onAlphaPanUpdate,
            onPanEnd: _onAlphaPanEnd,
            child: CustomPaint(
              painter: SliderPainter(_alphaSliderPosition, _isDragging),
            ),
          ),
        ),
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
          if (widget.showAlpha) ...[
            const SizedBox(height: 4),
            _buildInfoRow('RGBA:',
                '${((_selectedColor.toARGB32() >> 24) & 0xFF)}, ${(_selectedColor.r * 255.0).round()}, ${(_selectedColor.g * 255.0).round()}, ${(_selectedColor.b * 255.0).round()}'),
            const SizedBox(height: 4),
            _buildInfoRow('HSVA:',
                '${_hue.round()}, ${(_saturation * 100).round()}%, ${(_value * 100).round()}%, ${(100 * _alpha).round()}%'),
          ],
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
              Tooltip(
                message: 'Color square: tap to toggle lock, drag to pick',
                child: MouseRegion(
                  key: const ValueKey('color_square'),
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
              ),
              const SizedBox(height: 12),

              // Индикатор состояния
              Container(
                key: const ValueKey('state_indicator'),
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
              const SizedBox(height: 8),
              // Иконка замка (упрощённый контрол, emoji для совместимости)
              Center(
                child: Tooltip(
                  message:
                      _isColorPickerFixed ? 'Unlock picker' : 'Lock picker',
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isColorPickerFixed = !_isColorPickerFixed;
                        debugPrint(
                            'ColorPickerPopup: lock toggled via emoji -> $_isColorPickerFixed');
                      });
                    },
                    child: Text(
                      _isColorPickerFixed ? '🔒' : '🔓',
                      style: TextStyle(
                        fontSize: 22,
                        color: _isColorPickerFixed
                            ? Colors.green[700]
                            : Colors.blue[700],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ползунки
              _buildSlider(
                colors: _hueGradientColors,
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
