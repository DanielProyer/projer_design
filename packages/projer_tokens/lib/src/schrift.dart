/// Schrift: fünf Grössenstufen, zwei Gewichte.
///
/// Aus dem Design-System vom 31.07.2026: «5 Grössenstufen, 2 Gewichte.
/// Wichtiges nie im Leichtschnitt.» Beträge und Zahlen stehen oft
/// untereinander und sollen sauber ausgerichtet sein — deshalb Tabellenziffern
/// überall, nicht nur dort, wo jemand daran gedacht hat.
library;

import 'package:flutter/material.dart';

/// Die zwei erlaubten Gewichte. Ein drittes gibt es nicht; wer «etwas
/// dazwischen» braucht, hat ein Layoutproblem, kein Schriftproblem.
abstract final class Gewicht {
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight betont = FontWeight.w600;
}

/// Die fünf Stufen als fertige Stile. Jede Stufe hat eine Aufgabe; die
/// Namen sagen, wofür, nicht wie gross.
abstract final class Schrift {
  /// Tabellenziffern für alles — Beträge, Nummern, Zeiten stehen bündig.
  static const List<FontFeature> _ziffern = [FontFeature.tabularFigures()];

  /// Kleingedrucktes: Herkunft einer Zahl, Zeitstempel, Fassungsangabe.
  /// Nie für etwas, das jemand lesen *muss*.
  static const TextStyle klein = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: Gewicht.normal,
    fontFeatures: _ziffern,
  );

  /// Fliesstext, Listenzeilen, Feldinhalte.
  static const TextStyle text = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: Gewicht.normal,
    fontFeatures: _ziffern,
  );

  /// Betonter Fliesstext: Beträge, Namen, das Wichtige in einer Zeile.
  static const TextStyle textBetont = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: Gewicht.betont,
    fontFeatures: _ziffern,
  );

  /// Abschnittstitel, Kartentitel.
  static const TextStyle titel = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: Gewicht.betont,
    fontFeatures: _ziffern,
  );

  /// Die grosse Zahl auf der Bestätigungsfläche: Betrag, Kistennummer,
  /// Messwert. Das, was man aus einem Meter Abstand lesen soll.
  static const TextStyle gross = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: Gewicht.betont,
    fontFeatures: _ziffern,
  );

  /// Bildschirmtitel — sparsam, einer je Bildschirm.
  static const TextStyle bildschirm = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: Gewicht.betont,
    fontFeatures: _ziffern,
  );
}
