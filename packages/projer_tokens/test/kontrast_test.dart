import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projer_tokens/projer_tokens.dart';

// Rechnet bei jeder Änderung nach, was die Farbdokumente behaupten.
//
// Nicht als Absichtserklärung, sondern als Test: Fällt ein Wert unter die
// Schwelle, ist die Kette rot. «Eine Regel, die man befolgen muss, ist keine
// Regel — sie muss ein Typ sein.» Hier ist sie ein Test.
//
// Die Schwellen stammen aus `Architektur\Design-Akzentfarben.md` und
// `Architektur\Design-Bedeutungsfarben.md` im Projekt Haus:
// - Kontrast Text auf Grundfläche ≥ 7:1 (AAA Fliesstext), beide Themen.
// - Bedeutungsfarben untereinander ΔE ≥ 15, auch bei Rot-Grün-Schwäche,
//   ≥ 8 bei Tritanopie — beide Themen.
// - Text auf getönter Fläche ≥ 4.5:1 (nur kurze Beschriftung).
//
// Bei den Akzenten unterscheiden sich die Themen, und das ist gemessen, nicht
// gewollt: Auf `#121212` müssen Farben hell sein, um 7:1 zu erreichen, und
// helle Farben haben weniger Buntheitsspielraum. Der nutzbare Farbraum ist
// dunkel kleiner. Deshalb:
// - Hell: Akzente untereinander ΔE ≥ 8.5 (Normal/Deut/Prot), ≥ 7 (Trit);
//   Akzent gegen Bedeutungsfarbe ΔE ≥ 10 (Normal/Deut). Das ist die Regel.
// - Dunkel: die Werte des erschöpfend gerechneten Optimums (22.09.2026) mit
//   kleiner Reserve. Das ist keine Regel, sondern eine Rückschrittsschranke:
//   Wer die Farben ändert, darf es nicht schlechter machen.
// Im dunklen Thema trägt deshalb das Symbol neben der Farbe mehr Last —
// «Bedeutung nie durch Farbe allein» ist dort keine Höflichkeit.

/// Schwellen je Thema. Hell = Regel, Dunkel = gemessene Untergrenze
/// (Optimum vom 22.09.2026: Akzente 5.89 / 6.15 / 6.43, Trit 4.85, gegen
/// Bedeutung 6.92; Bedeutung 28.1 / 14.8 / 16.4, Trit 19.1).
class _Schwellen {
  const _Schwellen({
    required this.bedeutungUntereinander,
    required this.bedeutungUntereinanderTrit,
    required this.akzentUntereinander,
    required this.akzentUntereinanderTrit,
    required this.akzentGegenBedeutung,
  });
  final double bedeutungUntereinander;
  final double bedeutungUntereinanderTrit;
  final double akzentUntereinander;
  final double akzentUntereinanderTrit;
  final double akzentGegenBedeutung;
}

const _schwellen = {
  Brightness.light: _Schwellen(
    bedeutungUntereinander: 15.0,
    bedeutungUntereinanderTrit: 8.0,
    akzentUntereinander: 8.5,
    akzentUntereinanderTrit: 7.0,
    akzentGegenBedeutung: 10.0,
  ),
  Brightness.dark: _Schwellen(
    bedeutungUntereinander: 14.0,
    bedeutungUntereinanderTrit: 8.0,
    akzentUntereinander: 5.5,
    akzentUntereinanderTrit: 4.5,
    akzentGegenBedeutung: 6.5,
  ),
};

// ---------------------------------------------------------------------------
// Farbrechnung — dieselben Formeln wie in Werkzeuge\farbrechnung im Projekt
// Haus, damit Skript und Test dasselbe sagen.

double _linear(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _delinear(double c) => c <= 0.0031308
    ? c * 12.92
    : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;

List<double> _rgb(Color c) => [c.r, c.g, c.b];

double _leuchtdichte(List<double> rgb) =>
    0.2126 * _linear(rgb[0]) + 0.7152 * _linear(rgb[1]) + 0.0722 * _linear(rgb[2]);

/// Kontrastverhältnis nach WCAG 2.1.
double kontrast(Color a, Color b) {
  final l1 = _leuchtdichte(_rgb(a));
  final l2 = _leuchtdichte(_rgb(b));
  final hell = math.max(l1, l2);
  final dunkel = math.min(l1, l2);
  return (hell + 0.05) / (dunkel + 0.05);
}

List<double> _lab(List<double> rgb) {
  final r = _linear(rgb[0]), g = _linear(rgb[1]), b = _linear(rgb[2]);
  var x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  var y = (0.2126 * r + 0.7152 * g + 0.0722 * b);
  var z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  double f(double t) =>
      t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
  x = f(x);
  y = f(y);
  z = f(z);
  return [116 * y - 16, 500 * (x - y), 200 * (y - z)];
}

/// Farbabstand nach CIEDE2000.
double _deltaE(List<double> l1, List<double> l2) {
  const rad = math.pi / 180, deg = 180 / math.pi;
  final lStar1 = l1[0], a1 = l1[1], b1 = l1[2];
  final lStar2 = l2[0], a2 = l2[1], b2 = l2[2];
  double hypot(double a, double b) => math.sqrt(a * a + b * b);
  double p7(double v) => math.pow(v, 7).toDouble();
  final c1 = hypot(a1, b1), c2 = hypot(a2, b2), cm = (c1 + c2) / 2;
  final gG = 0.5 * (1 - math.sqrt(p7(cm) / (p7(cm) + p7(25))));
  final a1p = (1 + gG) * a1, a2p = (1 + gG) * a2;
  final c1p = hypot(a1p, b1), c2p = hypot(a2p, b2);
  var h1p = math.atan2(b1, a1p) * deg;
  if (h1p < 0) h1p += 360;
  var h2p = math.atan2(b2, a2p) * deg;
  if (h2p < 0) h2p += 360;
  final dLp = lStar2 - lStar1, dCp = c2p - c1p;
  var dhp = 0.0;
  if (c1p * c2p != 0) {
    dhp = h2p - h1p;
    if (dhp > 180) {
      dhp -= 360;
    } else if (dhp < -180) {
      dhp += 360;
    }
  }
  final dHp = 2 * math.sqrt(c1p * c2p) * math.sin((dhp * rad) / 2);
  final lBar = (lStar1 + lStar2) / 2, cBar = (c1p + c2p) / 2;
  var hBar = h1p + h2p;
  if (c1p * c2p != 0) {
    if ((h1p - h2p).abs() > 180) hBar += hBar < 360 ? 360 : -360;
    hBar /= 2;
  }
  final t = 1 -
      0.17 * math.cos((hBar - 30) * rad) +
      0.24 * math.cos(2 * hBar * rad) +
      0.32 * math.cos((3 * hBar + 6) * rad) -
      0.20 * math.cos((4 * hBar - 63) * rad);
  final dTheta = 30 * math.exp(-math.pow((hBar - 275) / 25, 2));
  final rC = 2 * math.sqrt(p7(cBar) / (p7(cBar) + p7(25)));
  final sL = 1 + (0.015 * math.pow(lBar - 50, 2)) / math.sqrt(20 + math.pow(lBar - 50, 2));
  final sC = 1 + 0.045 * cBar;
  final sH = 1 + 0.015 * cBar * t;
  final rT = -math.sin(2 * dTheta * rad) * rC;
  return math.sqrt(math.pow(dLp / sL, 2) +
      math.pow(dCp / sC, 2) +
      math.pow(dHp / sH, 2) +
      rT * (dCp / sC) * (dHp / sH));
}

/// Simulation von Farbsehschwäche in linearem RGB (Viénot/Brettel).
enum Sehweise { normal, deuteranopie, protanopie, tritanopie }

const _matrizen = <Sehweise, List<List<double>>?>{
  Sehweise.normal: null,
  Sehweise.deuteranopie: [
    [0.625, 0.375, 0],
    [0.7, 0.3, 0],
    [0, 0.3, 0.7],
  ],
  Sehweise.protanopie: [
    [0.567, 0.433, 0],
    [0.558, 0.442, 0],
    [0, 0.242, 0.758],
  ],
  Sehweise.tritanopie: [
    [0.95, 0.05, 0],
    [0, 0.433, 0.567],
    [0, 0.475, 0.525],
  ],
};

List<double> _gesehen(Color c, Sehweise s) {
  final m = _matrizen[s];
  final rgb = _rgb(c);
  if (m == null) return rgb;
  final l = rgb.map(_linear).toList();
  return m
      .map((z) => _delinear((z[0] * l[0] + z[1] * l[1] + z[2] * l[2]).clamp(0.0, 1.0)))
      .toList();
}

/// Farbabstand zweier Farben, so wie ein Auge mit [sehweise] sie sieht.
double abstand(Color a, Color b, Sehweise sehweise) =>
    _deltaE(_lab(_gesehen(a, sehweise)), _lab(_gesehen(b, sehweise)));

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

// ---------------------------------------------------------------------------

void main() {
  const grundflaechen = {
    Brightness.light: Grundflaeche.hell,
    Brightness.dark: Grundflaeche.dunkel,
  };

  group('Kontrast ≥ 7:1 auf der Grundfläche', () {
    for (final entry in grundflaechen.entries) {
      final seite = entry.key == Brightness.light ? 'hell' : 'dunkel';
      final flaeche = entry.value;

      for (final a in Akzent.alle) {
        test('Akzent ${a.name} $seite', () {
          final k = kontrast(a.fuer(entry.key), flaeche);
          expect(k, greaterThanOrEqualTo(7.0),
              reason: '${a.name} ${_hex(a.fuer(entry.key))} auf ${_hex(flaeche)}: $k');
        });
      }
      for (final b in Bedeutungsfarbe.alle) {
        test('Bedeutung ${b.name} $seite', () {
          final k = kontrast(b.text(entry.key), flaeche);
          expect(k, greaterThanOrEqualTo(7.0),
              reason: '${b.name} ${_hex(b.text(entry.key))} auf ${_hex(flaeche)}: $k');
        });
        test('Bedeutung ${b.name} $seite: Text auf getönter Fläche ≥ 4.5', () {
          final k = kontrast(b.text(entry.key), b.flaeche(entry.key));
          expect(k, greaterThanOrEqualTo(4.5),
              reason: '${b.name}: ${_hex(b.text(entry.key))} auf ${_hex(b.flaeche(entry.key))}: $k');
        });
      }
      for (final g in Geldrichtung.alle) {
        test('Geldrichtung ${g.name} $seite', () {
          final k = kontrast(g.text(entry.key), flaeche);
          expect(k, greaterThanOrEqualTo(7.0),
              reason: '${g.name} ${_hex(g.text(entry.key))} auf ${_hex(flaeche)}: $k');
        });
      }
      test('Textstufen $seite', () {
        expect(kontrast(Textfarbe.stark(entry.key), flaeche), greaterThanOrEqualTo(7.0));
        expect(kontrast(Textfarbe.mittel(entry.key), flaeche), greaterThanOrEqualTo(7.0));
        expect(kontrast(Textfarbe.schwach(entry.key), flaeche), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('Unterscheidbarkeit', () {
    for (final helligkeit in grundflaechen.keys) {
      final seite = helligkeit == Brightness.light ? 'hell' : 'dunkel';
      final sw = _schwellen[helligkeit]!;

      for (final s in Sehweise.values) {
        final trit = s == Sehweise.tritanopie;
        final schwelleBed =
            trit ? sw.bedeutungUntereinanderTrit : sw.bedeutungUntereinander;
        test('Bedeutungsfarben untereinander ≥ $schwelleBed · $seite · ${s.name}', () {
          final alle = Bedeutungsfarbe.alle;
          for (var i = 0; i < alle.length; i++) {
            for (var j = i + 1; j < alle.length; j++) {
              final d = abstand(alle[i].text(helligkeit), alle[j].text(helligkeit), s);
              expect(d, greaterThanOrEqualTo(schwelleBed),
                  reason: '${alle[i].name}/${alle[j].name} ($seite, ${s.name}): ΔE $d');
            }
          }
        });

        final schwelleAkz =
            trit ? sw.akzentUntereinanderTrit : sw.akzentUntereinander;
        test('Akzente untereinander ≥ $schwelleAkz · $seite · ${s.name}', () {
          final alle = Akzent.alle;
          for (var i = 0; i < alle.length; i++) {
            for (var j = i + 1; j < alle.length; j++) {
              final d = abstand(alle[i].fuer(helligkeit), alle[j].fuer(helligkeit), s);
              expect(d, greaterThanOrEqualTo(schwelleAkz),
                  reason: '${alle[i].name}/${alle[j].name} ($seite, ${s.name}): ΔE $d');
            }
          }
        });
      }

      for (final s in const [Sehweise.normal, Sehweise.deuteranopie]) {
        test('Akzent gegen Bedeutungsfarbe ≥ ${sw.akzentGegenBedeutung} · $seite · ${s.name}', () {
          for (final a in Akzent.alle) {
            for (final b in Bedeutungsfarbe.alle) {
              final d = abstand(a.fuer(helligkeit), b.text(helligkeit), s);
              expect(d, greaterThanOrEqualTo(sw.akzentGegenBedeutung),
                  reason: '${a.name}/${b.name} ($seite, ${s.name}): ΔE $d');
            }
          }
        });
      }
    }
  });

  group('Thema', () {
    for (final a in Akzent.alle) {
      for (final h in Brightness.values) {
        test('projerThema(${a.name}, ${h.name}) baut und trägt die Erweiterung', () {
          final t = projerThema(akzent: a, helligkeit: h);
          final f = t.extension<ProjerFarben>();
          expect(f, isNotNull);
          expect(f!.akzent, same(a));
          expect(t.colorScheme.primary, a.fuer(h));
          expect(kontrast(t.colorScheme.primary, t.colorScheme.onPrimary),
              greaterThanOrEqualTo(7.0));
        });
      }
    }
  });
}
