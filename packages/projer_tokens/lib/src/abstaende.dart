/// Abstände, Radien und Tippflächen — das 4er-Raster aus dem Design-System.
///
/// Alle Werte in logischen Pixeln (dp). Kein Bildschirm setzt eigene Zahlen;
/// wer einen Abstand braucht, nimmt eine Stufe von hier. Das ist die Regel,
/// die «Design jederzeit einfach veränderbar» dauerhaft einlöst: Eine
/// Änderung an dieser Stelle wirkt überall.
library;

/// Abstandsstufen auf dem 4er-Raster.
///
/// Semantisch benannt nach Verwendung, nicht nach Zahl — sonst wandert
/// die Zahl in die Köpfe und die Stufe verliert ihren Sinn.
abstract final class Abstand {
  /// Zwischen Symbol und Text, zwischen eng zusammengehörigen Teilen.
  static const double eng = 4;

  /// Innerhalb einer Zeile, zwischen Feldern einer Gruppe.
  static const double innen = 8;

  /// Zwischen Gruppen auf demselben Bildschirm.
  static const double gruppe = 16;

  /// Seitlicher Rand des Bildschirms; zwischen Abschnitten.
  static const double rand = 16;

  /// Zwischen deutlich getrennten Abschnitten, über einer Hauptaktion.
  static const double abschnitt = 24;

  /// Luft um die Hauptaktion in der Daumenzone.
  static const double gross = 32;
}

/// Zwei Rundungen, mehr nicht. Rund ist bei uns eine Eigenschaft von
/// Flächen, nicht eine Spielwiese. (Heisst nicht `Radius`, weil Flutter den
/// Namen schon vergibt — ein Schatten darüber wäre ein Fehler, den man erst
/// beim Übersetzen sieht.)
abstract final class Rundung {
  /// Felder, Chips, kleine Karten.
  static const double klein = 8;

  /// Karten, Dialoge, die Bestätigungsfläche.
  static const double gross = 16;
}

/// Tippflächen. Die Zahlen kommen aus dem Design-System vom 31.07.2026:
/// «Minimum 48 dp, Kernaktionen 56 dp+ (nasse/kalte Finger)».
///
/// Beim Inventar wird ohne Handschuhe gearbeitet (Entscheid 22.09.2026),
/// die 64 dp sind trotzdem die Grösse der Hauptaktion — grosszügig ist
/// hier keine Stilfrage, sondern Fehlertoleranz.
abstract final class Tippflaeche {
  /// Unter 48 dp gibt es bei uns keine antippbare Fläche.
  static const double minimum = 48;

  /// Nebenaktionen, Listenzeilen, Chips.
  static const double normal = 48;

  /// Kernaktionen in der Daumenzone.
  static const double kern = 56;

  /// Die eine Hauptaktion je Bildschirm.
  static const double haupt = 64;
}
