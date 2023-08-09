# FS22_CVT_Addon

![CVTaddon_github](https://user-images.githubusercontent.com/4678246/214910194-35925097-47f7-4b22-ba34-4a7e1f6e73b5.png)

https://discord.gg/mfergkwhDu 

Known issues:
- multiplayer* is in sync. but the driving feeling have to be readjust - I'm on it.

*A very big thanks goes to Glowin, for fixing the mp sync issue.

LessMotorBrakeforce to new Edition CVT_Addon 
by SbSh(Modastian) and Frvetz
also in credits: modelleicher


Depending on the setting, this script completely recalculates the engine braking effect
 and adds various options for Vario and CVT transmissions.
 The calculations are dependent on various factors - e.g.:
 - speeds
 - Weight & Weight of prospective implements and trailers and their filling
 - Ground, tires, friction
 - engine speed
 - Engine power/hp class (**(engine displacement/cylinder capacity) would still be nice, unfortunately not in the LS)
 - wind
 - vehicle condition

** (what's the correct description in english for this?) cylinder capacity, displacement of engine

There are 2 driving levels, II. is intended for road travel, transport and light work.
Stage I. Rather for heavy field work and heavy transport.  The maximum speed is also reduced here
and the torque provides more thrust, especially when starting.
A key assignment must be assigned for each level.  Changing the driving range should be done while stationary,
 since damage can also occur here.
 *A little tip, if you use the group switching buttons for up/down, you can use the same buttons for the speed levels.
 Furthermore, there is now an acceleration ramp in 4 stages, which can be switched through with a button.
 Here the pull-in behavior when accelerating and reducing the driving speed are influenced.
 Gentle and with feeling or full power and rough.
 With heavy equipment or trailers, high pressures can occur in the planetary gear and damage can occur!
 Here the acceleration ramp should be set to 3 or less.  Level 4 is more suitable for empty runs.
 In light field work, you can easily pull on speed level 1 in acceleration ramp 4 - for example disc harrow, flat cultivator.
 Some vehicles / implements have a hydrostatic drive in driveinglevel 1.
 You are welcome to give me feedback on which vehicles should have this.
 In order not to leave out the comfortable setting options, you can also change the braking ramp.
 There is also a button that can be used to switch between 5 levels.
 The braking ramp at different speeds of 1 km/h (standard)4, 8, 15 and 17 km/h
 cause the engine braking effect to decrease from the set one when the accelerator pedal or joystick is released
 Braking ramp supported with the service brake.
 This can be helpful when maneuvering or front loader work - or simply when driving stop and go on the road.
 Manually shifted transmissions are not affected.
 Then there is the TMS "Pedal" mode, with this you can control the pedal resolution.
 Ie set the maximum speed of the pedal.  With the cruise control deactivated, you set the levels there.
 E.g. 1 could be max 3 km/h.  In addition, the padal then reacts as a percentage, i.e. 50% pedal travel corresponds to a maximum of 12 km/h, 6 km/h.
 
 My script "Reduced engine braking effect" is no longer required with this new edition, and should not be used together.

EV: 100%
 - no restrictions

VCA: 60%
 - Unfortunately, the engine braking effect calculation does not work correctly.  In VCA the "low braking force" should be set to 100%
 - An update will hopefully follow from the VCA Mod
 - The vca:motor modification should be switched off

realismAddon_Gearbox: 100%
 - no restrictions
 - Complements each other in the two gear types.

Important:
 - All settings in the LS must be set to manual.
 - Manual shift and clutch.
 - No automatic controls may be active.
   If you want to drive realistically, you do it anyway.
 - Together with realismAddon_GearBox from modelleicher, it makes even more sense to set everything as real/manually as possible.
 - CVT addon should be used actively and not just a "it runs in the background" mod (adapt for the respective application)



![CVT_Addon_Explain](https://user-images.githubusercontent.com/4678246/214910310-4fb7e1ce-83e2-4319-b647-2e923cbf297a.png)



Dieses Skript berechnet je nach Einstellung die Motorbremswirkung völlig neu
und fügt diverse Optionen für Vario und CVT Getriebe hinzu.
Die Berechnungen sind von verschiedenen Faktoren anhängig - z.B.:
- Geschwindigkeiten
- Gewicht & Gewicht angangener Geräter und Anhänger und deren Füllung
- Untergrund, Reifen, Reibung
- Motordrehzahl
- Motorleistung/ PS-Klasse (Hubraum wäre noch schön, gibt es leider nicht im LS)
- Wind
- Fahrzeugzustand
  
Es gibt 2 Fahrstufen, II. ist für Straßenfahrten, Transport und leichte Arbeiten gedacht.
Stufe I. eher für schwere Feldarbeiten und schwere Transporte. Hierbei wird auch die Maximalgeschwindigkeit reduziert
und das Drehmoment sorgt vorallem beim anfahren für mehr Schub.
Für jede Stufe ist eine Tastenbelegung zu vergeben. Das wechseln der Fahrbereiche sollte im Stillstand geschehen,
da auch hier Schäden entstehen können.
*Kleiner Tipp, wenn ihr die Gruppenschaltungs-Tasten für hoch/runter nutzt, könnt ihr die selben Tasten für die Fahrstufen verwenden.
Desweiteren gibt es nun eine Beschleunigungsrampe in 4 Stufen, die mit einer Taste durchgeschaltet werden können.
Hier werden das Anzugverhalten beim Beschleunigen und reduzieren der Fahrgeschwindigkeit beeinflusst.
Sanft und mit Gefühlt oder volle Power und ruppig.
Mit schweren Geräten oder Anhänger, kann es zu hohen Drücken im Planetengetriebe kommen und es kann Schaden nehmen!
Hier sollte die Beschleunigungsrampe auf 3 oder weniger eingestellt werden. Stufe 4 ist eher für Leerfahrten geeignet.
In der leichten Feldarbeit kann man ruhig auf Fahrstufe 1 in der Beschleunigungsrampe 4 ziehen - Beispielsweise Scheibenegge, Flachgrubber.
Manche Fahrzeuge / Arbeitsgeräte haben einen Hydrostatischen Antrieb in der Fahrstufe 1.
Welche Fahzeuge genau dies besitzen sollen oder sollten, könnt ihr mir gerne ein Feedback zu geben.
Um Komfortable Einstellungsmöglichkeiten nicht auszulasen, kann man ebenfalls noch die Bremsrampe verändern.
Hierzu gibt es auch wieder eine Taste mit der in 5 Stufen umgeshaltet werden kann.
Die Bremsrampe in unterschiedlichen Geschwindigkeitsstufen von 1 km/h(Standard)4, 8, 15 und 17 km/h
bewirken, daß beim loslassen des Fahrpedals oder Fahrjoysticks die Motorbremswirkung ab der eingestellten
Bremsrampe mit der Betriebsbremse unterstützt.
Dies kann hilfreich bei Rangier- oder Frontladerarbeiten sein - oder einfach bei Stop&Go Straßenfahrten.
Manuell geschaltete Getriebe werden nicht beeinflusst.
Dann gibt es noch den TMS "Pedal" Modus, mit diesem kann man die Pedalauflösung kontrollieren.
D.h. die maximale Geschwindigkeit des Pedals festlegen. Mit deaktiviertem Tempomat, stellt man dort die Stufen ein.
Bsp. 1 könnte max 3 km/h sein. Dazu reagiert das Padal dann prozentual, sprich 50% Pedalweg entspricht bei max 12 km/h, 6 km/h.

Mein Skript "Verringerte Motorbremswirkung" wird mit dieser Neuauflage nicht mehr benötigt, bzw. sollte nicht zusammen genutzt werden.

EV: 100%
- keine Einschränkungen
  
VCA: 60%
- Die Motorbremswirkungs-Berechnung funktioniert leider nicht korrekt. In VCA sollte die "niedrige Bremskraft" auf 100% gestellt werden
- Ein Update folgt hoffentlich vom VCA Mod
- Die vca:Motormodifikation sollte ausgeschalten sein

realismAddon_Gearbox: 100%
- keine Einschränkungen
- Ergänzt sich Gegenseitig in den zwei Getriebearten.


Wichtig:
- Alle Einstellungen im LS müssen auf manuell gesetzt sein.
- Manuelle Schaltung und Kupplung.
- Es dürfen keine Automatiken für die Steuerung aktiv sein.
  Wenn man realistisch fahren möchte, macht man das sowieso.
- U.a. zusammen mit realismAddon_GearBox von modelleicher, macht es noch mehr Sinn alles so real/manuell wie möglich einzustellen.
- CVT-Addon sollte aktiv benutzt werden und nicht nur ein "es läuft im Hintergund" mod ( für die jeweilige Anwendung anpassen )


[![Watch the video](https://img.youtube.com/vi/rdKwO8u5Zd0/maxresdefault.jpg)](https://www.youtube.com/watch?v=rdKwO8u5Zd0)

