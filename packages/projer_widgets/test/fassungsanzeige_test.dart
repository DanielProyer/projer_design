import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projer_tokens/projer_tokens.dart';
import 'package:projer_widgets/projer_widgets.dart';

Widget _app(Widget kind, {Brightness helligkeit = Brightness.light}) =>
    MaterialApp(
      theme: projerThema(akzent: Akzent.ziegel, helligkeit: helligkeit),
      home: Scaffold(body: Center(child: kind)),
    );

void main() {
  testWidgets('zeigt die Fassung', (tester) async {
    await tester.pumpWidget(_app(const Fassungsanzeige(fassung: '0.3.1+12')));
    expect(find.text('Fassung 0.3.1+12'), findsOneWidget);
  });

  testWidgets('ein Pfad-Override ist unübersehbar', (tester) async {
    await tester.pumpWidget(_app(
      const Fassungsanzeige(fassung: '0.3.1+12', pfadOverride: true),
    ));
    expect(find.text('Fassung 0.3.1+12 · ÜBERSTEUERT'), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    // Warnfarbe und betont — sonst übersieht man es genau dann, wenn es zählt.
    expect(text.style?.color, Bedeutungsfarbe.warnung.textHell);
    expect(text.style?.fontWeight, Gewicht.betont);
  });

  testWidgets('Zusatz wird angehängt', (tester) async {
    await tester.pumpWidget(_app(
      const Fassungsanzeige(fassung: '1.0.0+1', zusatz: 'Pixel 9 Pro XL'),
    ));
    expect(find.text('Fassung 1.0.0+1 · Pixel 9 Pro XL'), findsOneWidget);
  });

  testWidgets('derselbe Wortlaut steht als Text für Fehlerberichte bereit', (tester) async {
    const w = Fassungsanzeige(fassung: '2.0.0+7', pfadOverride: true, zusatz: 'dev');
    expect(w.text, 'Fassung 2.0.0+7 · ÜBERSTEUERT · dev');
  });

  testWidgets('funktioniert auch im dunklen Thema', (tester) async {
    await tester.pumpWidget(_app(
      const Fassungsanzeige(fassung: '0.1.0+1', pfadOverride: true),
      helligkeit: Brightness.dark,
    ));
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style?.color, Bedeutungsfarbe.warnung.textDunkel);
  });
}
