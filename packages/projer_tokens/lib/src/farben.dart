/// Farben — gerechnet, nicht gewählt.
///
/// Jeder Wert erreicht auf seiner Grundfläche mindestens 7:1 (AAA für
/// Fliesstext). Die Sätze sind auch bei Rot-Grün-Schwäche unterscheidbar, und
/// kein Akzent sieht aus wie eine Statusfarbe. Herleitung, Zielkonflikte und
/// die verworfenen Alternativen stehen in `Architektur\Design-Akzentfarben.md`
/// und `Architektur\Design-Bedeutungsfarben.md` im Projekt Haus; der Test in
/// `test/kontrast_test.dart` rechnet alles bei jeder Änderung nach.
///
/// **Drei Typen, absichtlich nicht austauschbar:** [Akzent] für die Identität
/// einer App, [Bedeutungsfarbe] für Status, [Geldrichtung] für Beträge. Wer
/// eine Statusfarbe als Akzent einsetzen will, bekommt einen Übersetzerfehler
/// — das ist die Regel als Typ, nicht als Absprache.
///
/// **Zum dunklen Thema:** Auf `#121212` müssen Farben hell sein, um 7:1 zu
/// erreichen, und helle Farben haben weniger Buntheitsspielraum. Deshalb sind
/// die dunklen Werte blasser, und «fehler» ist dort eher Rosa als Rot — ein
/// sattes Rot in dieser Helligkeit ist für Deuteranopen von Bernstein nicht
/// unterscheidbar (gerechnet am 22.09.2026: null gültige Sätze). Im dunklen
/// Thema trägt das Symbol neben der Farbe deshalb mehr Last.
library;

import 'package:flutter/material.dart';

/// Die zwei Grundflächen, auf denen alles gerechnet ist.
abstract final class Grundflaeche {
  static const Color hell = Color(0xFFFFFFFF);
  static const Color dunkel = Color(0xFF121212);

  static Color fuer(Brightness helligkeit) =>
      helligkeit == Brightness.light ? hell : dunkel;
}

/// Drei Textstufen je Thema. «Stark» und «Mittel» erreichen ≥ 7:1,
/// «Schwach» ≥ 4.5:1 — Schwach ist nur für Nebensächliches, nie für etwas,
/// das jemand lesen *muss*.
abstract final class Textfarbe {
  static const Color hellStark = Color(0xFF1A1A1A);
  static const Color hellMittel = Color(0xFF585858);
  static const Color hellSchwach = Color(0xFF767676);
  static const Color dunkelStark = Color(0xFFF2F2F2);
  static const Color dunkelMittel = Color(0xFF9F9F9F);
  static const Color dunkelSchwach = Color(0xFF7D7D7D);

  static Color stark(Brightness h) =>
      h == Brightness.light ? hellStark : dunkelStark;
  static Color mittel(Brightness h) =>
      h == Brightness.light ? hellMittel : dunkelMittel;
  static Color schwach(Brightness h) =>
      h == Brightness.light ? hellSchwach : dunkelSchwach;
}

/// Ein Akzent ist die eine Farbe, an der Dani eine App erkennt. Je App wird
/// einer aus diesem Satz **gewählt**, nicht gemischt (E-004, E-006).
///
/// Ein Akzent trägt nie Bedeutung. Er ist für Hauptaktion, aktive Zustände
/// und die App-Leiste da — nicht für «erledigt», «Warnung» oder «Fehler».
final class Akzent {
  const Akzent._(this.name, this.hell, this.dunkel);

  final String name;

  /// Auf [Grundflaeche.hell].
  final Color hell;

  /// Auf [Grundflaeche.dunkel]. Derselbe Farbton wie [hell], heller und
  /// blasser — bei Fuchsie und Altrosa um 4° verschoben, weil sie sonst mit
  /// einer Statusfarbe kollidieren.
  final Color dunkel;

  Color fuer(Brightness helligkeit) =>
      helligkeit == Brightness.light ? hell : dunkel;

  /// Haus: Backstein und Dach.
  static const ziegel = Akzent._('Ziegel', Color(0xFF8C2835), Color(0xFFC49299));

  /// GrowApp: Pflanzen.
  static const wiese = Akzent._('Wiese', Color(0xFF316331), Color(0xFF76B576));

  /// Finanzapp: am nächsten am bisherigen Blaugrün, also kein Bruch.
  static const petrol = Akzent._('Petrol', Color(0xFF22606F), Color(0xFF53AABF));

  /// Heineken: nüchtern und geschäftlich.
  static const enzian = Akzent._('Enzian', Color(0xFF6444AF), Color(0xFFC2B9D9));

  static const pflaume = Akzent._('Pflaume', Color(0xFF75458B), Color(0xFFB493C4));

  static const brombeere = Akzent._('Brombeere', Color(0xFF692963), Color(0xFFD1AACE));

  static const fuchsie = Akzent._('Fuchsie', Color(0xFF962D81), Color(0xFFC28FB4));

  /// Bienen — Honigfarbe ist nicht möglich, Bernstein gehört der Warnung.
  static const altrosa = Akzent._('Altrosa', Color(0xFF7B3C55), Color(0xFFDCB2C5));

  static const List<Akzent> alle = [
    ziegel, wiese, petrol, enzian, pflaume, brombeere, fuchsie, altrosa,
  ];

  @override
  String toString() => 'Akzent($name)';
}

/// Status. Immer mit Symbol und Wort — **Farbe trägt nie allein Bedeutung.**
///
/// [textHell]/[textDunkel] sind Textfarben auf der Grundfläche (≥ 7:1).
/// [flaecheHell]/[flaecheDunkel] sind getönte Flächen für Chips und Banner;
/// der Text darauf erreicht ≥ 4.5:1, also nur kurze Beschriftung, kein
/// Fliesstext.
final class Bedeutungsfarbe {
  const Bedeutungsfarbe._(
    this.name, {
    required this.textHell,
    required this.textDunkel,
    required this.flaecheHell,
    required this.flaecheDunkel,
  });

  final String name;
  final Color textHell;
  final Color textDunkel;
  final Color flaecheHell;
  final Color flaecheDunkel;

  Color text(Brightness h) => h == Brightness.light ? textHell : textDunkel;
  Color flaeche(Brightness h) =>
      h == Brightness.light ? flaecheHell : flaecheDunkel;

  /// Fehler, überfällig, verloren.
  static const fehler = Bedeutungsfarbe._(
    'fehler',
    textHell: Color(0xFFAD1F1A),
    textDunkel: Color(0xFFE5B1B1),
    flaecheHell: Color(0xFFFAE9E8),
    flaecheDunkel: Color(0xFF301F1F),
  );

  /// Warnung, Wartezeit, prüfen.
  static const warnung = Bedeutungsfarbe._(
    'warnung',
    textHell: Color(0xFF563E0F),
    textDunkel: Color(0xFFDE8D21),
    flaecheHell: Color(0xFFF9F4E9),
    flaecheDunkel: Color(0xFF34291B),
  );

  /// Erledigt, gemessen, bestätigt.
  static const erfolg = Bedeutungsfarbe._(
    'erfolg',
    textHell: Color(0xFF194B36),
    textDunkel: Color(0xFF3CB54C),
    flaecheHell: Color(0xFFEBF7F2),
    flaecheDunkel: Color(0xFF1F3021),
  );

  /// Hinweis ohne Handlungsdruck.
  static const info = Bedeutungsfarbe._(
    'info',
    textHell: Color(0xFF234EC6),
    textDunkel: Color(0xFF7BB0D3),
    flaecheHell: Color(0xFFE9EDF9),
    flaecheDunkel: Color(0xFF1F2930),
  );

  static const List<Bedeutungsfarbe> alle = [fehler, warnung, erfolg, info];

  @override
  String toString() => 'Bedeutungsfarbe($name)';
}

/// Geldrichtung — **kein Status.** Eine Ausgabenliste in Fehlerrot sieht aus
/// wie eine Liste von Fehlern (Befund Finanzapp). Deshalb gedeckt, und nie
/// allein: Vorzeichen und Spaltenlage sagen es zuerst, die Farbe bestätigt.
final class Geldrichtung {
  const Geldrichtung._(this.name, this.textHell, this.textDunkel);

  final String name;
  final Color textHell;
  final Color textDunkel;

  Color text(Brightness h) => h == Brightness.light ? textHell : textDunkel;

  /// Geld weg.
  static const belastung =
      Geldrichtung._('belastung', Color(0xFF8A4038), Color(0xFFD1958E));

  /// Geld da.
  static const gutschrift =
      Geldrichtung._('gutschrift', Color(0xFF37604F), Color(0xFF75B097));

  static const List<Geldrichtung> alle = [belastung, gutschrift];

  @override
  String toString() => 'Geldrichtung($name)';
}
