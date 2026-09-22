import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projer_tokens/projer_tokens.dart';

/// Prüft das Thema auf den Fehler, der am 22.09.2026 im Feld aufgetreten ist:
/// **Text ohne aufgelöste Farbe malt die Flutter-Engine weiss.**
///
/// Der erste Bildschirm der Haus-App war deshalb leer — weiss auf weiss, ohne
/// Fehlermeldung, ohne Warnung. Der Widget-Test der App blieb grün, weil
/// `find.text` nur nach dem Widget sucht, nicht nach seiner Sichtbarkeit.
///
/// Diese Prüfung ist die Antwort darauf: Sie macht aus der Regel «Farbe nicht
/// vergessen» eine Bedingung, die bei jeder Änderung nachgerechnet wird.
void main() {
  for (final helligkeit in [Brightness.light, Brightness.dark]) {
    final name = helligkeit == Brightness.light ? 'hell' : 'dunkel';

    group('Thema $name', () {
      final thema = projerThema(akzent: Akzent.ziegel, helligkeit: helligkeit);

      test('jeder gesetzte Textstil hat eine Farbe', () {
        final stile = <String, TextStyle?>{
          'bodySmall': thema.textTheme.bodySmall,
          'bodyMedium': thema.textTheme.bodyMedium,
          'bodyLarge': thema.textTheme.bodyLarge,
          'titleMedium': thema.textTheme.titleMedium,
          'headlineSmall': thema.textTheme.headlineSmall,
          'displaySmall': thema.textTheme.displaySmall,
        };
        for (final eintrag in stile.entries) {
          expect(
            eintrag.value?.color,
            isNotNull,
            reason: '${eintrag.key} ohne Farbe — die Engine malt das weiss, '
                'und auf heller Grundfläche sieht niemand etwas.',
          );
        }
      });

      test('kein Textstil im TextTheme ist farblos', () {
        // Auch die Einträge, die das Paket nicht selbst setzt: Käme Material
        // je mit einem farblosen Stil, wäre der Befund derselbe.
        final alle = <String, TextStyle?>{
          'displayLarge': thema.textTheme.displayLarge,
          'displayMedium': thema.textTheme.displayMedium,
          'displaySmall': thema.textTheme.displaySmall,
          'headlineLarge': thema.textTheme.headlineLarge,
          'headlineMedium': thema.textTheme.headlineMedium,
          'headlineSmall': thema.textTheme.headlineSmall,
          'titleLarge': thema.textTheme.titleLarge,
          'titleMedium': thema.textTheme.titleMedium,
          'titleSmall': thema.textTheme.titleSmall,
          'bodyLarge': thema.textTheme.bodyLarge,
          'bodyMedium': thema.textTheme.bodyMedium,
          'bodySmall': thema.textTheme.bodySmall,
          'labelLarge': thema.textTheme.labelLarge,
          'labelMedium': thema.textTheme.labelMedium,
          'labelSmall': thema.textTheme.labelSmall,
        };
        final ohneFarbe = alle.entries
            .where((e) => e.value != null && e.value!.color == null)
            .map((e) => e.key)
            .toList();
        expect(ohneFarbe, isEmpty,
            reason: 'Farblose Stile: ${ohneFarbe.join(", ")}');
      });

      test('Fliesstext steht mit mindestens 7:1 auf der Grundfläche', () {
        // Der Kontrast ist anderswo gerechnet; hier wird nur geprüft, dass
        // die Farbe, die wirklich im Thema landet, die gerechnete ist.
        final erwartet = helligkeit == Brightness.light
            ? Textfarbe.hellStark
            : Textfarbe.dunkelStark;
        expect(thema.textTheme.bodyMedium?.color, erwartet);
      });

      test('Grundfläche und Textfarbe passen zusammen', () {
        final erwarteteFlaeche = helligkeit == Brightness.light
            ? Grundflaeche.hell
            : Grundflaeche.dunkel;
        expect(thema.scaffoldBackgroundColor, erwarteteFlaeche);
        expect(thema.colorScheme.surface, erwarteteFlaeche);
      });
    });
  }

  testWidgets('Text ohne eigenen Stil ist auf der Grundfläche sichtbar',
      (tester) async {
    // Der Fall aus dem Feld, nachgestellt: ein gewöhnlicher Text in einem
    // Scaffold. Er muss eine Farbe haben, die nicht die Grundfläche ist.
    await tester.pumpWidget(MaterialApp(
      theme: projerThema(akzent: Akzent.petrol, helligkeit: Brightness.light),
      home: const Scaffold(body: Text('Sichtbar?')),
    ));

    final text = tester.widget<Text>(find.text('Sichtbar?'));
    final stil = DefaultTextStyle.of(
      tester.element(find.text('Sichtbar?')),
    ).style.merge(text.style);

    expect(stil.color, isNotNull, reason: 'sonst malt die Engine weiss');
    expect(stil.color, isNot(Grundflaeche.hell),
        reason: 'weiss auf weiss ist der Fehler, um den es hier geht');
  });
}
