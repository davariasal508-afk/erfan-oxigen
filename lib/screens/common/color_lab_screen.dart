import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/formula_model.dart';
import '../../services/formula_service.dart';
import '../../theme/app_theme.dart';

/// «Color Lab» — چرخ رنگ واقعی + اسلایدرهای فرمول + ذخیره فرمول.
class ColorLabScreen extends StatefulWidget {
  const ColorLabScreen({super.key});

  @override
  State<ColorLabScreen> createState() => _ColorLabScreenState();
}

class _ColorLabScreenState extends State<ColorLabScreen> {
  double _hue = 28;
  double _saturation = .72;
  double _lightener = 40;
  double _toner = 30;
  double _baseColor = 20;
  double _ratio = 10;

  Color get _pickedColor => HSVColor.fromAHSV(1, _hue, _saturation, .82).toColor();

  @override
  Widget build(BuildContext context) {
    return OxygenPage(
      title: 'Color Lab',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColorWheel(
                hue: _hue,
                saturation: _saturation,
                onChanged: (hue, sat) => setState(() {
                  _hue = hue;
                  _saturation = sat;
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: _pickedColor,
                        border: Border.all(color: AppTheme.gold.withValues(alpha: .3)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('رنگ انتخابی', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                    Text('#${_pickedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'ترکیب فرمول', subtitle: 'درصد اجزای فرمول رنگ'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glass(radius: 20),
            child: Column(
              children: [
                _formulaSlider('روشن‌کننده', _lightener, AppTheme.gold, (v) => setState(() => _lightener = v)),
                _formulaSlider('دهنده رنگ', _toner, AppTheme.info, (v) => setState(() => _toner = v)),
                _formulaSlider('رنگ پایه', _baseColor, AppTheme.success, (v) => setState(() => _baseColor = v)),
                _formulaSlider('اکسیدان (نسبت)', _ratio, AppTheme.danger, (v) => setState(() => _ratio = v)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _saveFormula,
              icon: const Icon(Icons.save_rounded),
              label: const Text('ذخیره فرمول'),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'فرمول‌های ذخیره‌شده'),
          const SizedBox(height: 10),
          if (FormulaService.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('هنوز فرمولی ذخیره نشده است.', style: TextStyle(color: AppTheme.muted))),
            )
          else
            ...FormulaService.items.map(_savedFormulaTile),
        ],
      ),
    );
  }

  Widget _formulaSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 82, child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: color, thumbColor: color, overlayColor: color.withValues(alpha: .2)),
              child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
            ),
          ),
          SizedBox(width: 36, child: Text('${value.round()}%', textAlign: TextAlign.end, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _savedFormulaTile(FormulaModel f) {
    final color = HSVColor.fromAHSV(1, f.hue, .72, .82).toColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glass(radius: 16),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  'روشن‌کننده ${f.lightener.round()}٪ • دهنده ${f.toner.round()}٪ • پایه ${f.baseColor.round()}٪',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20),
            onPressed: () async {
              await FormulaService.remove(f.id);
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveFormula() async {
    final nameCtrl = TextEditingController(text: 'فرمول ${FormulaService.items.length + 1}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نام‌گذاری فرمول'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام فرمول')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره')),
        ],
      ),
    );
    if (ok != true) return;
    await FormulaService.save(FormulaModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      name: nameCtrl.text.trim().isEmpty ? 'فرمول بدون‌نام' : nameCtrl.text.trim(),
      hue: _hue,
      lightener: _lightener,
      toner: _toner,
      baseColor: _baseColor,
      ratio: _ratio,
    ));
    if (mounted) setState(() {});
  }
}

class _ColorWheel extends StatelessWidget {
  final double hue;
  final double saturation;
  final void Function(double hue, double saturation) onChanged;
  static const double _size = 150;

  const _ColorWheel({required this.hue, required this.saturation, required this.onChanged});

  void _handle(Offset local) {
    const center = Offset(_size / 2, _size / 2);
    final vector = local - center;
    final radius = math.min(_size, _size) / 2;
    final dist = vector.distance.clamp(0, radius);
    final angle = math.atan2(vector.dy, vector.dx);
    final hue = (angle * 180 / math.pi + 360) % 360;
    final sat = (dist / radius).clamp(0.0, 1.0);
    onChanged(hue, sat);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _handle(d.localPosition),
      onPanUpdate: (d) => _handle(d.localPosition),
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: const Size(_size, _size), painter: _WheelPainter()),
            Builder(builder: (context) {
              final radius = _size / 2;
              final rad = hue * math.pi / 180;
              final dist = saturation * radius;
              final pos = Offset(radius + dist * math.cos(rad), radius + dist * math.sin(rad));
              return Positioned(
                left: pos.dx - 9,
                top: pos.dy - 9,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HSVColor.fromAHSV(1, hue, saturation, .82).toColor(),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const steps = 360;
    for (int i = 0; i < steps; i++) {
      final hue = i.toDouble();
      final rad = hue * math.pi / 180;
      final paint = Paint()
        ..shader = SweepGradient(
          colors: List.generate(steps, (j) => HSVColor.fromAHSV(1, j.toDouble(), 1, .95).toColor())..add(HSVColor.fromAHSV(1, 0, 1, .95).toColor()),
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), rad, (1.2 * math.pi / 180), true, paint);
    }
    canvas.drawCircle(center, radius * .28, Paint()..color = AppTheme.background);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
