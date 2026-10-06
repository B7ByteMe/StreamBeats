import 'package:flutter/material.dart';

enum GradientStyle {
  lightAndBreezy,

  warmAndRich,
}

class GradientGenerator {
  GradientGenerator._();

  static List<Color> fromAccentColor(
    Color accentColor, {
    GradientStyle style = GradientStyle.lightAndBreezy,
  }) {
    final HSLColor hsl = HSLColor.fromColor(accentColor);

    if (style == GradientStyle.warmAndRich) {

      double hueShift = 0.0;
      double lightnessAdjust = 0.0;
      double saturationAdjust = 0.0;

      if (hsl.hue >= 300 || hsl.hue <= 20) {
        hueShift = 25.0;
        lightnessAdjust = 0.05; // Only slightly lighter
        saturationAdjust = 0.1; // Boost saturation
      } else if (hsl.hue >= 20 && hsl.hue < 60) {
        hueShift = -15.0;
        lightnessAdjust = 0.05;
      } else {
        hueShift = 10.0;
        lightnessAdjust = 0.1;
      }

      final double newHue = (hsl.hue + hueShift) % 360;
      final double newLightness =
          (hsl.lightness + lightnessAdjust).clamp(0.2, 0.85);
      final double newSaturation =
          (hsl.saturation + saturationAdjust).clamp(0.0, 1.0);

      final Color startColor = HSLColor.fromAHSL(
        1.0,
        newHue < 0 ? newHue + 360 : newHue,
        newSaturation,
        newLightness,
      ).toColor();

      final Color endColor = HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        hsl.saturation,
        (hsl.lightness - 0.05).clamp(0.2, 0.8),
      ).toColor();

      return [startColor, endColor];
    } else {

      const double lightnessBoost = 0.18;
      const double saturationBoost = 0.08;

      final double newLightness =
          (hsl.lightness + lightnessBoost).clamp(0.0, 0.85);
      final double newSaturation =
          (hsl.saturation + saturationBoost).clamp(0.0, 1.0);

      double hueShift = 0.0;
      if (hsl.hue >= 180 && hsl.hue < 240) {
        hueShift = -10;
      } else if (hsl.hue >= 240 && hsl.hue < 300) {
        hueShift = -8;
      }

      final double newHue = (hsl.hue + hueShift) % 360;

      final Color startColor = HSLColor.fromAHSL(
        1.0,
        newHue < 0 ? newHue + 360 : newHue,
        newSaturation,
        newLightness,
      ).toColor();

      final Color endColor = HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        (hsl.saturation + 0.05).clamp(0.0, 1.0),
        (hsl.lightness - 0.05).clamp(0.2, 0.8),
      ).toColor();

      return [startColor, endColor];
    }
  }

  static List<Color> elegantGradient(
    Color accentColor, {
    double intensity = 1.0, // 0.0 = subtle, 1.0 = normal, 2.0 = intense
  }) {
    final HSLColor hsl = HSLColor.fromColor(accentColor);

    final double lightLightness =
        (hsl.lightness + (0.25 * intensity)).clamp(0.0, 0.9);
    final double lightSaturation =
        (hsl.saturation - (0.1 * intensity)).clamp(0.3, 1.0);

    final Color lightColor = HSLColor.fromAHSL(
      1.0,
      hsl.hue,
      lightSaturation,
      lightLightness,
    ).toColor();

    return [lightColor, accentColor];
  }
}

class GradientProgressBar extends StatefulWidget {
  final Duration progress;

  final Duration total;

  final Duration buffered;

  final ValueChanged<Duration>? onSeek;

  final List<Color> activeGradientColors;

  final List<Color> inactiveGradientColors;

  final bool isPlaying;

  final double trackHeight;

  final double thumbRadius;

  final bool showTimeLabels;

  final TextStyle? timeLabelStyle;

  final double timeLabelPadding;

  final TimeLabelLocation timeLabelLocation;

  final Color? inactiveTrackColor;

  final Color? bufferedTrackColor;

  final Duration animationDuration;

  final Curve animationCurve;

  const GradientProgressBar({
    super.key,
    required this.progress,
    required this.total,
    this.buffered = Duration.zero,
    this.onSeek,
    this.activeGradientColors = const [Color(0xFFFF6B8B), Color(0xFFFF2E63)],
    this.inactiveGradientColors = const [Colors.white, Color(0xFF0EA5E0)],
    this.isPlaying = true,
    this.trackHeight = 6.0,
    this.thumbRadius = 8.0,
    this.showTimeLabels = true,
    this.timeLabelStyle,
    this.timeLabelPadding = 5.0,
    this.timeLabelLocation = TimeLabelLocation.above,
    this.inactiveTrackColor,
    this.bufferedTrackColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  factory GradientProgressBar.fromAccentColors({
    Key? key,
    required Duration progress,
    required Duration total,
    Duration buffered = Duration.zero,
    ValueChanged<Duration>? onSeek,
    required Color activeAccentColor,
    required Color inactiveAccentColor,
    GradientStyle activeGradientStyle = GradientStyle.lightAndBreezy,
    GradientStyle inactiveGradientStyle = GradientStyle.warmAndRich,
    bool isPlaying = true,
    double trackHeight = 6.0,
    double thumbRadius = 8.0,
    bool showTimeLabels = true,
    TextStyle? timeLabelStyle,
    double timeLabelPadding = 5.0,
    TimeLabelLocation timeLabelLocation = TimeLabelLocation.above,
    Color? inactiveTrackColor,
    Color? bufferedTrackColor,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
  }) {
    return GradientProgressBar(
      key: key,
      progress: progress,
      total: total,
      buffered: buffered,
      onSeek: onSeek,
      activeGradientColors: GradientGenerator.fromAccentColor(activeAccentColor,
          style: activeGradientStyle),
      inactiveGradientColors: GradientGenerator.fromAccentColor(
          inactiveAccentColor,
          style: inactiveGradientStyle),
      isPlaying: isPlaying,
      trackHeight: trackHeight,
      thumbRadius: thumbRadius,
      showTimeLabels: showTimeLabels,
      timeLabelStyle: timeLabelStyle,
      timeLabelPadding: timeLabelPadding,
      timeLabelLocation: timeLabelLocation,
      inactiveTrackColor: inactiveTrackColor,
      bufferedTrackColor: bufferedTrackColor,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }

  @override
  State<GradientProgressBar> createState() => _GradientProgressBarState();
}

enum TimeLabelLocation { above, below, sides, none }

class _GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  double _dragValue = 0.0;
  late AnimationController _animationController;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _colorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );
    if (widget.isPlaying) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _progressRatio {
    if (widget.total.inMilliseconds == 0) return 0.0;
    if (_isDragging) return _dragValue.clamp(0.0, 1.0);
    return (widget.progress.inMilliseconds / widget.total.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  double get _bufferedRatio {
    if (widget.total.inMilliseconds == 0) return 0.0;
    return (widget.buffered.inMilliseconds / widget.total.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Duration get _displayProgress {
    if (_isDragging) {
      final ms = (_dragValue.clamp(0.0, 1.0) * widget.total.inMilliseconds)
          .round()
          .clamp(0, widget.total.inMilliseconds);
      return Duration(milliseconds: ms);
    }
    return widget.progress;
  }

  void _handleDragStart(DragStartDetails details, BoxConstraints constraints) {
    final trackWidth = constraints.maxWidth;
    final localX = details.localPosition.dx;
    final newValue = (localX / trackWidth).clamp(0.0, 1.0);

    setState(() {
      _isDragging = true;
      _dragValue = newValue;
    });
  }

  void _handleDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isDragging) return;

    final trackWidth = constraints.maxWidth;
    final localX = details.localPosition.dx;
    final newValue = (localX / trackWidth).clamp(0.0, 1.0);

    setState(() {
      _dragValue = newValue;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final seekPosition = Duration(
      milliseconds: (_dragValue.clamp(0.0, 1.0) * widget.total.inMilliseconds)
          .round()
          .clamp(0, widget.total.inMilliseconds),
    );
    widget.onSeek?.call(seekPosition);

    setState(() {
      _isDragging = false;
    });
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    final trackWidth = constraints.maxWidth;
    final localX = details.localPosition.dx;
    final tapValue = (localX / trackWidth).clamp(0.0, 1.0);

    final seekPosition = Duration(
      milliseconds: (tapValue * widget.total.inMilliseconds)
          .round()
          .clamp(0, widget.total.inMilliseconds),
    );
    widget.onSeek?.call(seekPosition);
  }

  List<Color> _lerpColorList(List<Color> a, List<Color> b, double t) {
    if (a.length != b.length) return t < 0.5 ? a : b;
    return List.generate(
      a.length,
      (i) => Color.lerp(a[i], b[i], t) ?? a[i],
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = widget.timeLabelStyle ??
        TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        );

    Widget progressBar = LayoutBuilder(
      builder: (context, constraints) {
        return _buildProgressBar(constraints, defaultLabelStyle);
      },
    );

    if (widget.showTimeLabels) {
      switch (widget.timeLabelLocation) {
        case TimeLabelLocation.above:
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeLabelsRow(defaultLabelStyle),
              SizedBox(height: widget.timeLabelPadding),
              progressBar,
            ],
          );
        case TimeLabelLocation.below:
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              progressBar,
              SizedBox(height: widget.timeLabelPadding),
              _buildTimeLabelsRow(defaultLabelStyle),
            ],
          );
        case TimeLabelLocation.sides:
          return Row(
            children: [
              Text(_formatDuration(_displayProgress), style: defaultLabelStyle),
              SizedBox(width: widget.timeLabelPadding),
              Expanded(child: progressBar),
              SizedBox(width: widget.timeLabelPadding),
              Text(_formatDuration(widget.total), style: defaultLabelStyle),
            ],
          );
        case TimeLabelLocation.none:
          return progressBar;
      }
    }

    return progressBar;
  }

  Widget _buildTimeLabelsRow(TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatDuration(_displayProgress), style: style),
        Text(_formatDuration(widget.total), style: style),
      ],
    );
  }

  Widget _buildProgressBar(BoxConstraints constraints, TextStyle labelStyle) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) =>
          _handleDragStart(details, constraints),
      onHorizontalDragUpdate: (details) =>
          _handleDragUpdate(details, constraints),
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: () {
        if (_isDragging) {
          setState(() {
            _isDragging = false;
          });
        }
      },
      onTapUp: (details) => _handleTap(details, constraints),
      child: Container(
        height: widget.thumbRadius * 2 + 16,
        width: double.infinity,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            final currentGradient = _lerpColorList(
              widget.inactiveGradientColors,
              widget.activeGradientColors,
              _colorAnimation.value,
            );
            final currentThumbColor = Color.lerp(
              widget.inactiveGradientColors.last,
              widget.activeGradientColors.last,
              _colorAnimation.value,
            )!;
            final currentColor = Color.lerp(
              widget.inactiveGradientColors.last,
              widget.activeGradientColors.last,
              _colorAnimation.value,
            )!;
            final currentBufferedColor = Color.lerp(
              Colors.white.withValues(alpha: 0.1),
              currentColor.withValues(alpha: 0.02),
              0.08, // Mostly white with subtle color hint
            );

            return CustomPaint(
              size: Size(constraints.maxWidth, widget.thumbRadius * 2 + 16),
              painter: _GradientProgressBarPainter(
                progressRatio: _progressRatio,
                bufferedRatio: _bufferedRatio,
                gradientColors: currentGradient,
                thumbInnerColor: currentThumbColor,
                trackHeight: widget.trackHeight,
                thumbRadius: widget.thumbRadius,
                inactiveTrackColor:
                    widget.inactiveTrackColor ?? const Color(0xFF252525),
                bufferedTrackColor:
                    widget.bufferedTrackColor ?? currentBufferedColor!,
                isDragging: _isDragging,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GradientProgressBarPainter extends CustomPainter {
  final double progressRatio;
  final double bufferedRatio;
  final List<Color> gradientColors;
  final Color thumbInnerColor;
  final double trackHeight;
  final double thumbRadius;
  final Color inactiveTrackColor;
  final Color bufferedTrackColor;
  final bool isDragging;

  _GradientProgressBarPainter({
    required this.progressRatio,
    required this.bufferedRatio,
    required this.gradientColors,
    required this.thumbInnerColor,
    required this.trackHeight,
    required this.thumbRadius,
    required this.inactiveTrackColor,
    required this.bufferedTrackColor,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double trackTop = centerY - trackHeight / 2;
    final double trackBottom = centerY + trackHeight / 2;

    final double trackStartX = 0;
    final double trackEndX = size.width;
    final double trackWidth = trackEndX - trackStartX;

    final double thumbMinX = thumbRadius;
    final double thumbMaxX = size.width - thumbRadius;
    final double thumbRange = thumbMaxX - thumbMinX;

    final double thumbX =
        thumbMinX + (thumbRange * progressRatio.clamp(0.0, 1.0));
    final double bufferedX =
        trackStartX + (trackWidth * bufferedRatio.clamp(0.0, 1.0));

    final inactivePaint = Paint()
      ..color = inactiveTrackColor
      ..style = PaintingStyle.fill;

    final inactiveRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(trackStartX, trackTop, trackEndX, trackBottom),
      Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(inactiveRect, inactivePaint);

    if (bufferedRatio > 0 && bufferedX > trackStartX) {
      final bufferedPaint = Paint()
        ..color = bufferedTrackColor
        ..style = PaintingStyle.fill;

      final bufferedRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(trackStartX, trackTop, bufferedX, trackBottom),
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(bufferedRect, bufferedPaint);
    }

    if (progressRatio > 0) {
      final fullGradientRect =
          Rect.fromLTRB(trackStartX, trackTop, trackEndX, trackBottom);
      final activeRect =
          Rect.fromLTRB(trackStartX, trackTop, thumbX, trackBottom);

      final activePaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(fullGradientRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, Radius.circular(trackHeight / 2)),
        activePaint,
      );
    }

    if (isDragging) {
      final glowPaint = Paint()
        ..color = thumbInnerColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(thumbX, centerY), thumbRadius * 2, glowPaint);
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(thumbX, centerY + 1),
      thumbRadius,
      shadowPaint,
    );

    final thumbOuterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, centerY), thumbRadius, thumbOuterPaint);

    final thumbInnerPaint = Paint()
      ..color = thumbInnerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(thumbX, centerY),
      thumbRadius * 0.5,
      thumbInnerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientProgressBarPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio ||
        oldDelegate.bufferedRatio != bufferedRatio ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.thumbInnerColor != thumbInnerColor ||
        oldDelegate.inactiveTrackColor != inactiveTrackColor ||
        oldDelegate.bufferedTrackColor != bufferedTrackColor;
  }
}

class ProgressBarGradients {
  ProgressBarGradients._();

  static const iconicPlayPink = [Color(0xFFFF6B8B), Color(0xFFFF2E63)];

  static const skyBlueWhite = [Colors.white, Color(0xFF0EA5E0)];

  static const electricWatermelon = [Color(0xFFFF512F), Color(0xFFDD2476)];

  static const hotMagentaGlow = [Color(0xFFFF4081), Color(0xFFF50057)];

  static const vaporwaveSunset = [Color(0xFF00C6FF), Color(0xFFFF00CC)];

  static const cottonCandySkies = [Color(0xFF89F7FE), Color(0xFFF68084)];

  static const cyberTwilight = [Color(0xFF0072FF), Color(0xFFFF2E63)];

  static const electricBubblegum = [Color(0xFF00DBDE), Color(0xFFFC00FF)];

  static const malibuDrive = [Color(0xFF43CBFF), Color(0xFFFF96F9)];

  static const cyberBlue = [Color(0xFF00F2FF), Color(0xFF007BFF)];

  static const neonLime = [Color(0xFF81FF8A), Color(0xFF1DB954)];

  static const solarFlare = [Color(0xFFFFD200), Color(0xFFFF7B00)];
}