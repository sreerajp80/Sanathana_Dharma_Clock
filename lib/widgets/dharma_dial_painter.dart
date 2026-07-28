import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/dharma_time.dart';

/// One colored arc on the dial: a day window as fractions of the dharma day.
///
/// The caller (the clock screen) converts a window's civil start/end into
/// day fractions; the painter never sees `DateTime`s or the kāla rules
/// (architecture §9 — the painter stays a dumb renderer).
class DialArc {
  /// Where the arc starts, 0.0–1.0 from sunrise (top, clockwise).
  final double startFraction;

  /// Where the arc ends, 0.0–1.0 from sunrise.
  final double endFraction;

  final Color color;

  const DialArc({
    required this.startFraction,
    required this.endFraction,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialArc &&
          runtimeType == other.runtimeType &&
          startFraction == other.startFraction &&
          endFraction == other.endFraction &&
          color == other.color;

  @override
  int get hashCode => Object.hash(startFraction, endFraction, color);
}

/// Draws the analog dharma clock face from a [DharmaTime] reading
/// (idea doc §5). Outer → inner: a bevelled rim, a 30-Muhūrta ring, the
/// 60-Ghaṭikā main dial, the current Muhūrta name in the centre, three hands
/// (Ghaṭikā, Vināḍī, Prāṇa/fraction), and a "now" bead riding the rim with
/// sunrise fixed at the top.
///
/// The dial is given depth with plain canvas work — no packages: a drop shadow
/// under the disc, a radial-gradient face lit from the top-left, a
/// sweep-gradient bezel, blurred shadows under the hands, and a gradient hub
/// cap. All the light/dark shades are derived from the passed-in colours, so
/// the painter still knows nothing about the theme class.
///
/// The painter is pure UI: it takes the reading, the Muhūrta name, and its
/// colours, and knows nothing about the solar formula or providers
/// (architecture §9). It repaints only when the reading changes — once per
/// second — so it stays cheap (architecture §19).
///
/// Angles use the screen convention: 0 rad points up (12 o'clock, = sunrise) and
/// the sweep goes clockwise. Progress `f` in `0..1` through the day maps to
/// `2π·f` clockwise from the top.
class DharmaDialPainter extends CustomPainter {
  final DharmaTime dharma;

  /// The current Muhūrta's name, painted in the centre of the face. The caller
  /// looks it up (e.g. `MuhurtaNames.at`) so the painter stays a dumb renderer.
  final String muhurtaName;

  /// The count line under the name, e.g. `Muhūrta 8 / 30`. The caller builds
  /// it in the user's language, so the painter stays a dumb renderer and knows
  /// no UI wording of its own.
  final String countLabel;

  /// Bright vermillion — hands, ring, and the "now" marker.
  final Color accent;

  /// Darker vermillion — long ticks, labels, and the bezel.
  final Color foreground;

  /// Muted brown-red — the minor ticks.
  final Color muted;

  /// The face disc colour (chandan surface); the radial face gradient and the
  /// shadows are derived from it.
  final Color faceColor;

  /// Colored day-window arcs (kālas, Abhijit) drawn on a thin band just inside
  /// the Muhūrta ring. Empty on days without a sunset — then nothing is drawn.
  final List<DialArc> arcs;

  const DharmaDialPainter({
    required this.dharma,
    required this.muhurtaName,
    required this.countLabel,
    required this.accent,
    required this.foreground,
    required this.muted,
    required this.faceColor,
    this.arcs = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    _paintDropShadow(canvas, center, radius);
    _paintFace(canvas, center, radius);
    _paintBezel(canvas, center, radius);
    _paintWindowArcs(canvas, center, radius);
    _paintMuhurtaRing(canvas, center, radius);
    _paintGhatikaTicks(canvas, center, radius);
    _paintGhatikaNumbers(canvas, center, radius);
    _paintHands(canvas, center, radius);
    _paintMuhurtaName(canvas, center, radius);
    _paintNowMarker(canvas, center, radius);
  }

  /// A soft blurred shadow offset down-right, so the dial lifts off the page.
  void _paintDropShadow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.03);
    canvas.drawCircle(
      center + Offset(radius * 0.015, radius * 0.03),
      radius * 0.96,
      paint,
    );
  }

  /// The face disc: a radial gradient lit from the top-left, so the flat
  /// background becomes a gently domed surface.
  void _paintFace(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius * 0.98);
    final face = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 1.15,
        colors: [
          _lighten(faceColor, 0.35),
          faceColor,
          _darken(faceColor, 0.08),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.98, face);
  }

  /// The raised bezel: a thick sweep-gradient ring (light at top-left, dark at
  /// bottom-right), a thin highlight on its inner edge, and a blurred inner
  /// shadow so the face sits recessed inside it.
  void _paintBezel(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Light source top-left: the sweep runs light → dark → light so the ring
    // reads as a rounded bevel. The rotation puts the light end at top-left.
    final bezel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.05
      ..shader = SweepGradient(
        colors: [
          _lighten(foreground, 0.35),
          _darken(foreground, 0.35),
          _lighten(foreground, 0.35),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-3 * math.pi / 4),
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.955, bezel);

    // Thin bright line on the bezel's inner edge — the catch-light.
    final innerHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.008
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(center, radius * 0.928, innerHighlight);

    // Blurred dark ring just inside the bezel — the recessed-face shadow.
    final innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03
      ..color = Colors.black.withValues(alpha: 0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.02);
    canvas.drawCircle(center, radius * 0.905, innerShadow);
  }

  /// The day-window arcs: a thin stroked band between the Muhūrta ring and the
  /// Ghaṭikā ticks, painted before both so ticks and hands stay on top. Angle
  /// convention matches the rest of the dial: fraction `f` → `2π·f` clockwise
  /// from the top (sunrise).
  void _paintWindowArcs(Canvas canvas, Offset center, double radius) {
    if (arcs.isEmpty) return;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.815);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.028
      ..strokeCap = StrokeCap.round;

    for (final arc in arcs) {
      final sweep = (arc.endFraction - arc.startFraction).clamp(0.0, 1.0);
      if (sweep <= 0) continue;
      // Canvas angle 0 is the +x axis; the dial's zero (sunrise) is straight
      // up, so shift by −π/2.
      paint.color = arc.color;
      canvas.drawArc(
        rect,
        2 * math.pi * arc.startFraction - math.pi / 2,
        2 * math.pi * sweep,
        false,
        paint,
      );
    }
  }

  /// The outer ring of 30 Muhūrta ticks; the current Muhūrta is highlighted.
  void _paintMuhurtaRing(Canvas canvas, Offset center, double radius) {
    final outer = radius * 0.895;
    final tickLen = radius * 0.055;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < AppConstants.muhurtaPerDay; i++) {
      final angle = 2 * math.pi * i / AppConstants.muhurtaPerDay;
      final isCurrent = i == dharma.muhurta;
      paint
        ..color = isCurrent ? accent : muted
        ..strokeWidth = isCurrent ? radius * 0.03 : radius * 0.012;
      _drawTick(canvas, center, angle, outer, outer - tickLen, paint);
    }
  }

  /// The 60 Ghaṭikā ticks; every fifth is longer and darker.
  void _paintGhatikaTicks(Canvas canvas, Offset center, double radius) {
    final outer = radius * 0.80;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < AppConstants.ghatikaPerDay; i++) {
      final angle = 2 * math.pi * i / AppConstants.ghatikaPerDay;
      final isMajor = i % 5 == 0;
      final tickLen = isMajor ? radius * 0.07 : radius * 0.04;
      paint
        ..color = isMajor ? foreground : muted
        ..strokeWidth = isMajor ? radius * 0.014 : radius * 0.008;
      _drawTick(canvas, center, angle, outer, outer - tickLen, paint);
    }
  }

  /// Ghaṭikā numbers at every fifth tick (0, 5, 10 … 55), sitting just inside
  /// the Ghaṭikā ring. `0` is at the top (sunrise); numbers grow clockwise, like
  /// a normal clock face, so the dial can be read at a glance.
  void _paintGhatikaNumbers(Canvas canvas, Offset center, double radius) {
    final labelRadius = radius * 0.655;
    final fontSize = radius * 0.08;

    for (var i = 0; i < AppConstants.ghatikaPerDay; i += 5) {
      final angle = 2 * math.pi * i / AppConstants.ghatikaPerDay;
      final painter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            color: foreground,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final point = _pointOnCircle(center, labelRadius, angle);
      painter.paint(
        canvas,
        point - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  /// The current Muhūrta name in the middle of the dial: the count line just
  /// above the centre hub and the name just above the count, so the hands'
  /// pivot never hides the count digits. Painted after the hands so the text
  /// is always readable, whatever the hands' angle.
  void _paintMuhurtaName(Canvas canvas, Offset center, double radius) {
    if (muhurtaName.isEmpty) return;

    // Both lines use darkened shades of the theme foreground so they stay
    // readable even when a hand passes through them: the name a clearly
    // darker red-brown, the count near black.
    final nameColor = Color.lerp(foreground, Colors.black, 0.35)!;
    final countColor = Color.lerp(foreground, Colors.black, 0.75)!;

    // Long names ("Dyumadgadyuti") must never overflow the dial: cap the text
    // width at 0.6 × diameter and shrink the font to fit if needed.
    final maxWidth = radius * 1.2;
    var fontSize = radius * 0.11;
    var name = _layoutText(muhurtaName, fontSize, nameColor, FontWeight.w700);
    if (name.width > maxWidth) {
      fontSize *= maxWidth / name.width;
      name = _layoutText(muhurtaName, fontSize, nameColor, FontWeight.w700);
    }

    final count = _layoutText(
      countLabel,
      radius * 0.065,
      countColor,
      FontWeight.w500,
    );

    // Both lines sit just above the central dot, so the hands' pivot never
    // covers the count digits: count right above the hub, name above the count.
    final countCenter = center - Offset(0, radius * 0.11);
    count.paint(
      canvas,
      countCenter - Offset(count.width / 2, count.height / 2),
    );
    final nameCenter = center - Offset(0, radius * 0.21);
    name.paint(canvas, nameCenter - Offset(name.width / 2, name.height / 2));
  }

  TextPainter _layoutText(
    String text,
    double fontSize,
    Color color,
    FontWeight weight,
  ) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// The three hands: Ghaṭikā (slow, thick), Vināḍī (medium), and the smooth
  /// Prāṇa fast hand. Each casts a soft shadow; the faster hands sit "higher"
  /// above the face, so their shadows fall a little further.
  void _paintHands(Canvas canvas, Offset center, double radius) {
    // Ghaṭikā hand: the slow "hour" hand. It creeps smoothly across the whole
    // day (one turn per dharma day) using the whole-day fraction.
    final ghatikaAngle = 2 * math.pi * dharma.fraction;
    _drawHand(
      canvas,
      center,
      ghatikaAngle,
      radius * 0.48,
      radius * 0.020,
      foreground,
      shadowLift: radius * 0.015,
    );

    // Vināḍī hand: the "minute" hand. It sweeps smoothly once per Ghaṭikā
    // (~24 min) using progress through the current Ghaṭikā.
    final vinadiAngle = 2 * math.pi * dharma.vinadiFraction;
    _drawHand(
      canvas,
      center,
      vinadiAngle,
      radius * 0.64,
      radius * 0.014,
      accent,
      shadowLift: radius * 0.022,
    );

    // Fast hand: the "second" hand. It turns once per Vināḍī (~24 s) using
    // progress through the current Vināḍī, so it visibly moves every tick.
    final fastAngle = 2 * math.pi * dharma.pranaFraction;
    _drawHand(
      canvas,
      center,
      fastAngle,
      radius * 0.76,
      radius * 0.006,
      accent,
      shadowLift: radius * 0.03,
    );

    _paintCentreCap(canvas, center, radius);
  }

  /// The hub: a small radial-gradient cap with a top-left highlight and a
  /// darker edge, like a real clock's centre boss.
  void _paintCentreCap(Canvas canvas, Offset center, double radius) {
    final capRadius = radius * 0.035;
    final rect = Rect.fromCircle(center: center, radius: capRadius);

    // Its own little shadow first.
    canvas.drawCircle(
      center + Offset(radius * 0.008, radius * 0.012),
      capRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.01),
    );

    final cap = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          _lighten(foreground, 0.4),
          foreground,
          _darken(foreground, 0.3),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, capRadius, cap);

    canvas.drawCircle(
      center,
      capRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.004
        ..color = _darken(foreground, 0.4),
    );
  }

  /// The rim markers, riding the bezel like beads: a small fixed sunrise dot at
  /// the top and the "now" sun disc at the day fraction, so day/night is
  /// readable at a glance.
  void _paintNowMarker(Canvas canvas, Offset center, double radius) {
    // Sunrise sits at the top (angle 0).
    final sunrisePoint = _pointOnCircle(center, radius * 0.955, 0);
    canvas.drawCircle(
      sunrisePoint,
      radius * 0.02,
      Paint()..color = _lighten(foreground, 0.45),
    );

    // "Now" travels clockwise from the top by the day fraction. A soft shadow
    // under the bead keeps it in the same lit world as the rest of the dial.
    final nowAngle = 2 * math.pi * dharma.fraction;
    final nowPoint = _pointOnCircle(center, radius * 0.955, nowAngle);
    canvas.drawCircle(
      nowPoint + Offset(radius * 0.008, radius * 0.012),
      radius * 0.035,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.012),
    );
    final rect = Rect.fromCircle(center: nowPoint, radius: radius * 0.035);
    canvas.drawCircle(
      nowPoint,
      radius * 0.035,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [_lighten(accent, 0.35), accent, _darken(accent, 0.2)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect),
    );
  }

  // --- geometry & colour helpers ---

  /// A point on a circle where angle 0 is straight up and rotation is clockwise.
  Offset _pointOnCircle(Offset center, double r, double angle) {
    return Offset(
      center.dx + r * math.sin(angle),
      center.dy - r * math.cos(angle),
    );
  }

  void _drawTick(
    Canvas canvas,
    Offset center,
    double angle,
    double rOuter,
    double rInner,
    Paint paint,
  ) {
    canvas.drawLine(
      _pointOnCircle(center, rInner, angle),
      _pointOnCircle(center, rOuter, angle),
      paint,
    );
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double width,
    Color color, {
    required double shadowLift,
  }) {
    final tip = _pointOnCircle(center, length, angle);

    // Blurred dark copy offset down-right — the hand's shadow on the face.
    final shadowOffset = Offset(shadowLift * 0.7, shadowLift);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowLift * 0.5);
    canvas.drawLine(center + shadowOffset, tip + shadowOffset, shadow);

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, paint);
  }

  Color _lighten(Color c, double t) => Color.lerp(c, Colors.white, t)!;

  Color _darken(Color c, double t) => Color.lerp(c, Colors.black, t)!;

  @override
  bool shouldRepaint(covariant DharmaDialPainter oldDelegate) {
    // Repaint only when the reading or the colours change — once per second.
    return oldDelegate.dharma != dharma ||
        oldDelegate.muhurtaName != muhurtaName ||
        oldDelegate.countLabel != countLabel ||
        oldDelegate.accent != accent ||
        oldDelegate.foreground != foreground ||
        oldDelegate.muted != muted ||
        oldDelegate.faceColor != faceColor ||
        !listEquals(oldDelegate.arcs, arcs);
  }
}
