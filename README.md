# FS22_CVT_Addon
## Download, please use the  [latest release](https://github.com/s4t4n/FS22_CVT_Addon/releases/latest/download/FS22_CVT_Addon.zip)
[![Latest](https://img.shields.io/github/downloads-pre/s4t4n/FS22_CVT_Addon/latest/FS22_CVT_Addon.zip?label=Downloads%20of%20Latest)](https://github.com/s4t4n/FS22_CVT_Addon/releases/latest/download/FS22_CVT_Addon.zip)
[![GitHub all releases](https://img.shields.io/github/downloads/s4t4n/FS22_CVT_Addon/total?label=Total%20downloads)](https://github.com/s4t4n/FS22_CVT_Addon/releases/latest/download/FS22_CVT_Addon.zip)
[![Last update](https://img.shields.io/github/release-date-pre/s4t4n/FS22_CVT_Addon?label=Last%20update)](#)
[![GitHub release (with filter)](https://img.shields.io/github/v/release/s4t4n/FS22_CVT_Addon?label=Latests%20Version)](#) \
[![GitHub Repo stars](https://img.shields.io/github/stars/s4t4n/FS22_CVT_Addon)](#)
[![GitHub User's stars](https://img.shields.io/github/stars/s4t4n?label=All%20stars)](#)
[![GitHub watchers](https://img.shields.io/github/watchers/s4t4n/FS22_CVT_Addon)](#)
[![GitHub forks](https://img.shields.io/github/forks/s4t4n/FS22_CVT_Addon)]()
[![GitHub followers](https://img.shields.io/github/followers/s4t4n)](#) \
[![issues](https://img.shields.io/github/issues/s4t4n/FS22_CVT_Addon)](https://github.com/s4t4n/FS22_CVT_Addon/issues)
[![language count](https://img.shields.io/github/languages/count/s4t4n/FS22_CVT_Addon)](#)
[![GitHub top language](https://img.shields.io/github/languages/top/s4t4n/FS22_CVT_Addon)](#) 

[![Discord](https://img.shields.io/discord/660942481118199811?logo=discord&logoColor=%23ffffff&label=SbSh-PooL%20Discord)](https://discord.gg/mfergkwhDu) \
[![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UC_Yn6bN1MMyd7Sn8wUyXnIg) ![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UC_Yn6bN1MMyd7Sn8wUyXnIg)](https://www.youtube.com/@SbSh-Modastian) \
[![Twitch Status](https://img.shields.io/twitch/status/sbsh_modasti4n?logo=twitch&label=sbsh_modasti4n%20Live-Stream%20now&labelColor=%23ffffff&color=%23aa55ff)](https://www.twitch.tv/sbsh_modasti4n)




Instructions how to download the code and use it as modfile zip here -> [Wiki: How to download and use master code](https://github.com/s4t4n/FS22_CVT_Addon/wiki/How-to-download-and-use-master-code)

![CVTa_github](https://github.com/s4t4n/FS22_CVT_Addon/assets/4678246/f3f66c42-fe3e-419c-b4f7-552e2ebe2ea6)

[![YouTube Video Views](https://img.shields.io/youtube/views/lhM3yu9weCI?logo=youtube&label=Technical%20Tutorial%20-%20Teil%201)](#) \
[![Watch the video](https://img.youtube.com/vi/lhM3yu9weCI/maxresdefault.jpg)](https://www.youtube.com/watch?v=lhM3yu9weCI)

https://discord.gg/mfergkwhDu 

#english
#deutsch

Known issues:
- multiplayer* is in sync. but the driving feeling have to be readjust at rpm - I'm on it.
- Neutral doesnt work correct in multiplayer, because of a bug(giants part), can't sync the lastDirection

*A very big thanks goes to Glowin, for fixing the mp sync issue.

LessMotorBrakeforce to new Edition CVT_Addon 
by SbSh(Modastian) and Frvetz
also in credits: modelleicher


Depending on the setting, this script completely recalculates the engine braking effect

 - engine speed

 - Engine power/hp class (displacement would still be nice, unfortunately not in the LS)

 - wind

 - vehicle condition


 There are 2 driving levels, II. is intended for road travel, transport and light work.  Stage I. Rather for heavy field work and heavy transport.
 The maximum speed is also reduced here and the torque provides more thrust, especially when starting.
 A key assignment must be assigned for each level.  Changing the driving range should be done while stationary,
 since damage can also occur here.  *A little tip if you use the group switching buttons for up/down,
 you can use the same buttons for the speed levels.  Furthermore, there is now an acceleration ramp in 4 stages,
 which can be switched through with a button.  Here the pull-in behavior when accelerating and reducing the driving speed are influenced.
 Gentle and with feeling or full power and rough.  With heavy equipment or trailers,
 This can lead to high pressures in the planetary gear and it can be damaged!  Here the acceleration ramp should be set to 3 or less.
 Level 4 is more suitable for empty runs.
 In light field work, you can easily pull on speed level 1 in acceleration ramp 4 - for example disc harrow, flat cultivator.
 Some vehicles / implements have a hydrostatic drive in gear 1. Which vehicles should or should have this,
 Can you please give me some feedback.  In order not to leave out the comfortable setting options, you can also change the braking ramp.
 There is also a button that can be used to switch between 5 levels.
 The braking ramp in different speed levels of 1 km/h (standard)4, 8, 15 and 17 km/h effect,
 that when the accelerator pedal or joystick is released, the engine braking effect is supported by the service brake from the set braking ramp.
 This can be helpful when maneuvering or front loader work - or simply when driving stop and go on the road.  Manually shifted transmissions are not affected.
 Then there is the TMS "Pedal" mode, with this you can control the pedal resolution.  Ie set the maximum speed of the pedal.
 With the cruise control deactivated, you set the levels there.  E.g. 1 could be max 3 km/h.  The padal then reacts as a percentage,
 i.e. 50% pedal travel corresponds to a maximum of 12 km/h, 6 km/h.
 Digital hand throttle, without further ado, only has a decorative function - but together with
 eg RealismAddon_rpmAnimSpeeds is then used to control the hydraulic and PTO performance, among other things.
 Improper operation can lead to higher temperatures, pressures and even damage to the gearbox!
 New feature (vca requied), automatic diff locks by steering angle and awd by speed in drivinglevel I. for fieldwork
 with additional automatic preselection from DL II. to DL I.
 (You have to bind one new key for this)
 My script "Reduced engine braking effect" is no longer required with this new edition, and should not be used together.

EV: 100%
 - no restrictions

VCA: 99%
 - update vca to build 130 or higher
 - The vca:motor modification should be switched off
 - then it's 100%

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
 


![CVT_Addon_Explain](https://github.com/s4t4n/FS22_CVT_Addon/assets/4678246/090a90af-d47a-455d-a59b-b9fea431db5c)

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


Dieses Skript berechnet je nach Einstellung die Motorbremswirkung völlig neu

und fügt diverse Optionen für Vario und CVT Getriebe hinzu.

Die Berechnungen sind von verschiedenen Faktoren abhängig - z.B.:
- Geschwindigkeiten
- Gewicht & Gewicht angangener Geräter und Anhänger und deren Füllung
- Untergrund, Reifen, Reibung
- Motordrehzahl
- Motorleistung/ PS-Klasse (Hubraum wäre noch schön, gibt es leider nicht im LS)
- Wind
- Fahrzeugzustand

  
Es gibt 2 Fahrstufen, II. ist für Straßenfahrten, Transport und leichte Arbeiten gedacht. Stufe I. eher für schwere Feldarbeiten und schwere Transporte.

Hierbei wird auch die Maximalgeschwindigkeit reduziert und das Drehmoment sorgt vorallem beim anfahren für mehr Schub.

Für jede Stufe ist eine Tastenbelegung zu vergeben. Das wechseln der Fahrbereiche sollte im Stillstand geschehen,

da auch hier Schäden entstehen können. *Kleiner Tipp, wenn ihr die Gruppenschaltungs-Tasten für hoch/runter nutzt,

könnt ihr die selben Tasten für die Fahrstufen verwenden. Desweiteren gibt es nun eine Beschleunigungsrampe in 4 Stufen,

die mit einer Taste durchgeschaltet werden können. Hier werden das Anzugverhalten beim Beschleunigen und reduzieren der Fahrgeschwindigkeit beeinflusst.

Sanft und mit Gefühl oder volle Power und ruppig. Mit schweren Geräten oder Anhänger,

kann es zu hohen Drücken im Planetengetriebe kommen und es kann Schaden nehmen! Hier sollte die Beschleunigungsrampe auf 3 oder weniger eingestellt werden.

Stufe 4 ist eher für Leerfahrten geeignet.

In der leichten Feldarbeit kann man ruhig auf Fahrstufe 1 in der Beschleunigungsrampe 4 ziehen - Beispielsweise Scheibenegge, Flachgrubber.

Manche Fahrzeuge / Arbeitsgeräte haben einen Hydrostatischen Antrieb in der Fahrstufe 1. Welche Fahzeuge genau dies besitzen sollen oder sollten,

könnt ihr mir gerne ein Feedback zu geben. Um Komfortable Einstellungsmöglichkeiten nicht auszulasen, kann man ebenfalls noch die Bremsrampe verändern.

Hierzu gibt es auch wieder eine Taste mit der in 5 Stufen umgeshaltet werden kann.

Die Bremsrampe in unterschiedlichen Geschwindigkeitsstufen von 1 km/h(Standard)4, 8, 15 und 17 km/h bewirken,

daß beim loslassen des Fahrpedals oder Fahrjoysticks die Motorbremswirkung ab der eingestellten Bremsrampe mit der Betriebsbremse unterstützt.

Dies kann hilfreich bei Rangier- oder Frontladerarbeiten sein - oder einfach bei Stop&Go Straßenfahrten. Manuell geschaltete Getriebe werden nicht beeinflusst.

Dann gibt es noch den TMS "Pedal" Modus, mit diesem kann man die Pedalauflösung kontrollieren. D.h. die maximale Geschwindigkeit des Pedals festlegen.

Mit deaktiviertem Tempomat, stellt man dort die Stufen ein. Bsp. 1 könnte max 3 km/h sein. Dazu reagiert das Padal dann prozentual,

sprich 50% Pedalweg entspricht bei max 12 km/h, 6 km/h.

Digitales Handgas, hat ohne weiteres nur eine Deko Funktion - jedoch zusammen mit

z.B. RealismAddon_rpmAnimSpeeds wird damit dann u.a. die Hydraulik- und PTO-Leistung gesteuert.


Unsachgemäße Bedienung kann zu höheren Temperaturen, Drücken und sogar Schäden im Getriebe führen!


Neue Funktion (VCA erforderlich), automatische Differenzialsperre je nach Lenkwinkel und Allradantrieb je nach Geschwindigkeit in Fahrstufe I. für Feldarbeiten

mit zusätzlicher automatischer Vorwahl von DL II.  zu DL I.

(Sie müssen hierfür eine neue Taste belegen)

Mein Skript "Verringerte Motorbremswirkung" wird mit dieser Neuauflage nicht mehr benötigt, bzw. sollte nicht zusammen genutzt werden.

EV: 100%
- keine Einschränkungen
  
VCA: 99%
- Update VCA auf Build 130 oder höher
- Die vca:Motormodifikation sollte ausgeschalten sein
- dann sind es 100%

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
