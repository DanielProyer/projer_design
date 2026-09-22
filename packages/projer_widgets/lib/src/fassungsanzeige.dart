import 'package:flutter/material.dart';
import 'package:projer_tokens/projer_tokens.dart';

/// Zeigt die Fassung der App — auf jedem Bildschirm, auch auf Hilfs- und
/// Testseiten, und in jeder Fehler- und Statusausgabe.
///
/// Warum das ein eigenes Widget ist und keine Konvention: Ohne sichtbare
/// Fassung ist nach einer Rückmeldung aus dem Feld nicht entscheidbar, ob ein
/// Fix nicht wirkt oder gar nicht angekommen ist. Zwischenspeicher liefern
/// still alte Stände aus. Das hat in mehreren Projekten wiederholt zur
/// Fehlersuche am falschen Ende geführt. (Regel Dani, projektübergreifend.)
///
/// Greift ein Pfad-Override (`pubspec_overrides.yaml` zeigt auf einen
/// Arbeitsbaum), **muss** das hier sichtbar sein — sonst baut der Release
/// gegen einen Stand, der in keinem Repo steht. Die App übergibt dazu
/// [pfadOverride], typischerweise aus einem `--dart-define`.
///
/// Die Angabe kommt von der App ([fassung]), nicht aus einem Paket wie
/// `package_info_plus`: Das Widget bleibt abhängigkeitsfrei und testbar, und
/// die App entscheidet, woher sie ihre Fassung nimmt.
class Fassungsanzeige extends StatelessWidget {
  const Fassungsanzeige({
    super.key,
    required this.fassung,
    this.pfadOverride = false,
    this.zusatz,
  });

  /// Fassung samt Build, wie in `pubspec.yaml`: «0.3.1+12».
  final String fassung;

  /// Wahr, wenn die App gegen einen Pfad-Override gebaut wurde.
  final bool pfadOverride;

  /// Frei: Gerätename, Kanal, Datenstand — was die Fehlersuche braucht.
  final String? zusatz;

  /// Der Text, wie er auch in einem Fehlerbericht steht. Öffentlich, damit
  /// eine Statusausgabe denselben Wortlaut verwenden kann wie die Anzeige.
  String get text {
    final teile = <String>[
      'Fassung $fassung',
      if (pfadOverride) 'ÜBERSTEUERT',
      if (zusatz != null && zusatz!.isNotEmpty) zusatz!,
    ];
    return teile.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).extension<ProjerFarben>();
    final warnung = farben?.bedeutung(Bedeutungsfarbe.warnung).text;
    final stil = Schrift.klein.copyWith(
      color: pfadOverride ? warnung : Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: pfadOverride ? Gewicht.betont : Gewicht.normal,
    );
    return Semantics(
      label: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Abstand.rand,
          vertical: Abstand.eng,
        ),
        child: Text(text, style: stil, textAlign: TextAlign.center),
      ),
    );
  }
}
