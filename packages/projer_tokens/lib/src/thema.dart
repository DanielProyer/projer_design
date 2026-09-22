import 'package:flutter/material.dart';

import 'abstaende.dart';
import 'farben.dart';
import 'schrift.dart';

/// Eine Bedeutungsfarbe, aufgelöst für das aktuelle Thema: die Textfarbe und
/// die getönte Fläche, auf der sie steht.
///
/// Auf der Fläche gehört nur kurze Beschriftung — der Kontrast dort liegt
/// zwischen 5.9:1 und 9.1:1, also über AA, aber unter AAA. Fliesstext steht
/// auf der Grundfläche.
final class BedeutungImThema {
  const BedeutungImThema({required this.text, required this.flaeche});

  final Color text;
  final Color flaeche;
}

/// Die Farben, die eine App zur Laufzeit wirklich braucht, als
/// [ThemeExtension] — damit `Theme.of(context).extension<ProjerFarben>()`
/// überall dieselbe Antwort gibt und kein Bildschirm selbst zwischen hell
/// und dunkel unterscheiden muss.
///
/// Drei Typen, drei Aufgaben, absichtlich nicht austauschbar:
/// - [akzent] — die eine Farbe, an der Dani die App erkennt.
/// - [bedeutung] — Status: fehler, warnung, erfolg, info. Immer mit Symbol
///   und Wort, nie allein.
/// - [geld] — Geldrichtung. Kein Status; eine Ausgabenliste in Fehlerrot
///   sieht aus wie eine Liste von Fehlern.
final class ProjerFarben extends ThemeExtension<ProjerFarben> {
  const ProjerFarben({required this.akzent, required this.helligkeit});

  final Akzent akzent;
  final Brightness helligkeit;

  bool get _hell => helligkeit == Brightness.light;

  /// Die Akzentfarbe im aktuellen Thema — für Hauptaktion, aktive Zustände,
  /// die App-Leiste. Nie für Status.
  Color get akzentFarbe => akzent.fuer(helligkeit);

  /// Die Grundfläche, auf der die Akzent- und Bedeutungsfarben gerechnet sind.
  Color get grundflaeche => _hell ? Grundflaeche.hell : Grundflaeche.dunkel;

  /// Beschriftung auf der Akzentfarbe: die jeweils andere Grundfläche. Das
  /// ergibt denselben Kontrast wie Akzent auf Grundfläche, also ≥ 7:1.
  Color get aufAkzent => _hell ? Grundflaeche.hell : Grundflaeche.dunkel;

  BedeutungImThema bedeutung(Bedeutungsfarbe b) => BedeutungImThema(
        text: _hell ? b.textHell : b.textDunkel,
        flaeche: _hell ? b.flaecheHell : b.flaecheDunkel,
      );

  Color geld(Geldrichtung g) => _hell ? g.textHell : g.textDunkel;

  @override
  ProjerFarben copyWith({Akzent? akzent, Brightness? helligkeit}) =>
      ProjerFarben(
        akzent: akzent ?? this.akzent,
        helligkeit: helligkeit ?? this.helligkeit,
      );

  /// Akzente werden nicht gemischt — «einstellbar heisst auswählen, nicht
  /// mischen» (E-006). Ein Wechsel springt, er blendet nicht.
  @override
  ProjerFarben lerp(ProjerFarben? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Baut das Thema einer App aus einem Akzent und einer Helligkeit.
///
/// Das ist die einzige Stelle, an der Farben in ein [ThemeData] fliessen.
/// Apps rufen `projerThema(akzent: Akzent.ziegel, helligkeit: ...)` auf und
/// setzen sonst nichts — Material 3, Tippflächen, Schrift und Radien kommen
/// mit.
///
/// Hell-Maximal (Schneeblendung, Garten in der Sonne) fehlt noch: andere
/// Grundflächen, andere Werte, noch nicht gerechnet. Es kommt als dritter
/// Wert, nicht als Sonderfall von hell.
ThemeData projerThema({
  required Akzent akzent,
  required Brightness helligkeit,
}) {
  final farben = ProjerFarben(akzent: akzent, helligkeit: helligkeit);
  final hell = helligkeit == Brightness.light;
  final akzentFarbe = akzent.fuer(helligkeit);
  final fehler = farben.bedeutung(Bedeutungsfarbe.fehler);

  final schema = ColorScheme.fromSeed(
    seedColor: akzentFarbe,
    brightness: helligkeit,
    // Der Seed liefert Zwischentöne; die tragenden Farben setzen wir selbst,
    // damit die gerechneten Kontraste gelten und nicht Materials Ableitung.
    primary: akzentFarbe,
    onPrimary: farben.aufAkzent,
    surface: farben.grundflaeche,
    onSurface: hell ? Textfarbe.hellStark : Textfarbe.dunkelStark,
    onSurfaceVariant: hell ? Textfarbe.hellMittel : Textfarbe.dunkelMittel,
    error: fehler.text,
    onError: farben.aufAkzent,
    errorContainer: fehler.flaeche,
    onErrorContainer: fehler.text,
  );

  final basis = ThemeData(
    useMaterial3: true,
    colorScheme: schema,
    brightness: helligkeit,
    scaffoldBackgroundColor: farben.grundflaeche,
    extensions: [farben],
  );

  // 🔴 Die Textfarbe MUSS hier gesetzt werden, und zwar an jedem Eintrag.
  //
  // Befund vom 22.09.2026, gefunden im Feld beim ersten Bildschirm der
  // Haus-App: `Schrift.*` sind absichtlich farblos, damit derselbe Stil in
  // hellem und dunklem Thema taugt. Setzt man sie ohne Farbe ins
  // [TextTheme], bleibt `color` null - und die Flutter-Engine malt Text
  // ohne aufgeloeste Farbe **weiss**. Auf der hellen Grundflaeche war der
  // ganze Bildschirminhalt damit unsichtbar: weiss auf weiss, ohne Fehler,
  // ohne Warnung, und der Widget-Test blieb gruen, weil `find.text` die
  // Farbe nicht prueft.
  //
  // Deshalb: jeder Eintrag bekommt seine Farbe aus dem Schema. Der Test
  // `thema_test.dart` rechnet nach, dass KEIN Eintrag farblos bleibt - die
  // Regel ist eine Pruefung, keine Gewohnheit.
  final aufFlaeche = schema.onSurface;
  final gedaempft = schema.onSurfaceVariant;

  return basis.copyWith(
    textTheme: basis.textTheme.copyWith(
      // Kleingedrucktes steht gedaempft - es ist Beiwerk, kein Fliesstext.
      bodySmall: Schrift.klein.copyWith(color: gedaempft),
      bodyMedium: Schrift.text.copyWith(color: aufFlaeche),
      bodyLarge: Schrift.textBetont.copyWith(color: aufFlaeche),
      titleMedium: Schrift.titel.copyWith(color: aufFlaeche),
      headlineSmall: Schrift.bildschirm.copyWith(color: aufFlaeche),
      displaySmall: Schrift.gross.copyWith(color: aufFlaeche),
    ),
    // Knöpfe: Höhe aus den Tippflächen, Breite NICHT unendlich.
    // `Size.fromHeight(52)` hiesse `Size(∞, 52)` — der Befund der Finanzapp,
    // der zweimal im Feld zugeschlagen hat. Deshalb minimumSize mit Breite 0:
    // die Höhe ist gesichert, die Breite bestimmt das Layout.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, Tippflaeche.kern),
        textStyle: Schrift.textBetont,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Rundung.klein)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, Tippflaeche.normal),
        textStyle: Schrift.textBetont,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Rundung.klein)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, Tippflaeche.normal),
        textStyle: Schrift.textBetont,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rundung.klein)),
      ),
      // Fehlermeldungen brauchen Platz: Sie sagen, was zu tun ist, nicht nur,
      // was falsch war.
      errorMaxLines: 3,
      helperMaxLines: 3,
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Rundung.gross)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      minTileHeight: Tippflaeche.normal,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Abstand.rand,
        vertical: Abstand.eng,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
