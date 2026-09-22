/// Farb-, Abstands- und Schrift-Token für alle Apps von Daniel Projer.
///
/// Grundprinzip aus dem Design-System vom 31.07.2026: **Token statt Farben im
/// Code.** Kein Bildschirm erhält je direkt eine Farbe, Schriftgrösse oder
/// einen Abstand; alles kommt von hier. Eine Änderung an einer Stelle wirkt
/// überall.
///
/// Die Farben sind gerechnet, nicht gewählt — Kontrast nach WCAG 2.1,
/// Unterscheidbarkeit nach CIEDE2000 auch bei Farbsehschwäche. Der Test in
/// `test/kontrast_test.dart` rechnet das bei jeder Änderung nach.
library;

export 'src/abstaende.dart';
export 'src/farben.dart';
export 'src/schrift.dart';
export 'src/thema.dart';
