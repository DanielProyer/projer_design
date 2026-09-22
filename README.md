# projer_design

Das gemeinsame Design-Fundament für die Apps von Daniel Projer — Finanzapp, Heineken
(SBS-App), Haus, später Bienen und GrowApp V2. Beschlossen am 20.09.2026 in Abstimmung
der drei Projekt-Sitzungen (Haus, Finanzapp, Heineken); Freigabe Dani, E-005 im
Decision-Log des Projekts Haus.

**Zwei Ebenen, ein Repo:**

| Paket | Inhalt | Wer bindet es ein |
|---|---|---|
| `packages/projer_tokens` | Farben, Abstände, Schrift, Themen — klein und stabil | alle Apps |
| `packages/projer_widgets` | feldgehärtete Bausteine, die man nur richtig benutzen kann | wer will |

Heineken nimmt nur die Token; ein Bedienmuster wandert erst nach `projer_widgets`, wenn es
**zweimal im Feld bestanden** hat — «getrieben von der Feldprobe, nicht vom Wunsch nach
Symmetrie». Die Finanzapp nimmt beide Ebenen nach ihren laufenden Etappen. Haus baut das
Paket auf und nutzt es zuerst allein.

## Einbinden

Immer mit **gepinntem Ref**, nie mit `main` — reproduzierbare Builds sind die Bedingung, unter
der die Finanzapp und Heineken zugestimmt haben:

```yaml
dependencies:
  projer_tokens:
    git:
      url: https://github.com/DanielProyer/projer_design.git
      path: packages/projer_tokens
      ref: v0.1.0
```

## Was ein Pfad-Override darf und was nicht

Für einen dringenden Fix darf eine App lokal per `pubspec_overrides.yaml` auf einen
Arbeitsbaum dieses Repos zeigen. Zwei Auflagen, beide aus der Abstimmung vom 20.09.2026:

1. **Nie ins Repo, nie in die CI.** `pubspec_overrides.yaml` steht in `.gitignore`; die
   Kette hat einen Wächter, der rot wird, wenn die Datei doch eingecheckt ist.
2. **Sichtbar in der Fassungsangabe.** Greift ein Override, zeigt die App das an — sonst baut
   der Release gegen einen Stand, der in keinem Repo steht, und bei einer Rückmeldung aus dem
   Feld ist nicht entscheidbar, ob ein Fix nicht wirkt oder gar nicht angekommen ist.
   `Fassungsanzeige(pfadOverride: true)` in `projer_widgets` tut genau das.

Ein **Versions**-Override (ein Paket verlangt eine alte Fassung, die es nicht benutzt) ist
davon nicht betroffen — er gehört in die `pubspec.yaml` und baut überall gleich.

## Die Farben sind gerechnet, nicht gewählt

Acht Akzente, vier Bedeutungsfarben, zwei Geldrichtungen — jede Farbe erreicht in beiden
Themen mindestens 7:1 Kontrast (AAA für Fliesstext), die Sätze sind auch bei Rot-Grün-Schwäche
unterscheidbar, und kein Akzent sieht aus wie eine Statusfarbe. `flutter test` in
`projer_tokens` rechnet das bei jeder Änderung nach.

Herleitung, Zielkonflikte und die verworfenen Alternativen: `Architektur\Design-Akzentfarben.md`
und `Architektur\Design-Bedeutungsfarben.md` im Projekt Haus.

## Regeln, die im Code stehen

- **Akzent und Status sind verschiedene Typen.** Ein `Akzent` lässt sich nicht als
  `Bedeutungsfarbe` einsetzen und umgekehrt; der Übersetzer verhindert es, nicht die Disziplin.
- **Geldrichtung ist kein Status.** `Geldrichtung` ist ein dritter Typ; eine Ausgabenliste in
  Fehlerrot sieht aus wie eine Liste von Fehlern.
- **Farbe trägt nie allein Bedeutung.** Jede Statusfarbe kommt mit Symbol und Wort.
- **Jede Fassung nennt sich selbst** — auf jedem Bildschirm, in jeder Ausgabe.

## Was noch fehlt

- **Hell-Maximal**, das dritte Thema (Schneeblendung, Garten in der Sonne). Andere
  Grundflächen, andere Werte — noch nicht gerechnet.
- Die **fünf Bausteine der Finanzapp**: Zeilenknopf, Bestätigungsleiste mit fester Knopfrolle,
  Leerzustand mit Pflicht-Ausgang, Datumszeile mit Klemmung, Fehlerkanal mit kopierbarem
  Protokoll. Kommen abgestimmt mit deren Sitzung, nicht kopiert aus einem laufenden
  Arbeitsbaum.
- **Abnahme durch Dani** am Gerät, nicht am PC-Bildschirm.
