import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Displays a value such as `08+`, `60K+`, `4th`, `8.14` or `10K+ downloads`
/// and counts its number up from zero the first time it scrolls into view.
///
/// Text around the number is kept as-is, as are leading zeros and decimal
/// places. Values without a number are shown unchanged.
class CountUpText extends StatefulWidget {
  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.duration = const Duration(milliseconds: 1400),
  });

  final String value;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final Duration duration;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  static final _numberPattern = RegExp(
    r'^(.*?)(\d+(?:\.\d+)?)(.*)$',
    dotAll: true,
  );

  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Key _visibilityKey;
  _ParsedValue? _parsed;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _parsed = _parse(widget.value);
  }

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parsed = _parse(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ParsedValue? _parse(String value) {
    final match = _numberPattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    final digits = match.group(2)!;
    final dot = digits.indexOf('.');
    return _ParsedValue(
      prefix: match.group(1)!,
      target: double.parse(digits),
      decimals: dot == -1 ? 0 : digits.length - dot - 1,
      // Keeps the zero padding of values like "08+".
      minIntegerDigits: dot == -1 ? digits.length : dot,
      suffix: match.group(3)!,
    );
  }

  void _start() {
    if (_started || !mounted) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    final style = (widget.style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (parsed == null) {
      return Text(
        widget.value,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.4) {
          _start();
        }
      },
      child: Semantics(
        // Screen readers get the final value, not every animation frame.
        label: widget.value,
        excludeSemantics: true,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            return Text(
              parsed.format(_progress.value),
              style: style,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
            );
          },
        ),
      ),
    );
  }
}

class _ParsedValue {
  const _ParsedValue({
    required this.prefix,
    required this.target,
    required this.decimals,
    required this.minIntegerDigits,
    required this.suffix,
  });

  final String prefix;
  final double target;
  final int decimals;
  final int minIntegerDigits;
  final String suffix;

  String format(double progress) {
    final current = target * progress;
    final text = decimals == 0
        ? current.round().toString()
        : current.toStringAsFixed(decimals);
    final dot = text.indexOf('.');
    final integerPart = dot == -1 ? text : text.substring(0, dot);
    final padded = integerPart.padLeft(minIntegerDigits, '0');
    return '$prefix$padded${dot == -1 ? '' : text.substring(dot)}$suffix';
  }
}
