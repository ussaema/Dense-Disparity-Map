
Benutzung:

Um Disparity Map, Rotation und Translation zu berechnen, bitte 'challenge.m' datei ausführen.
Achtung: Mit der vorliegenden Parametereinstellung berechnet sich die Dispärity Map in ca. 30 - 50 sekunden (oder mehr, ist abhängig von den Disparity Levels).
         Es ist möglich, vergleichbar gutes PSNR in ca. hälfte der zeit zu erhalten, 10 - 20 sekunden, mit der Parameterübergabe ('preprocess',"sobel",'customMaxWidth',700)
         für die 'disparity_map' Funktion (Zeile 25). Diese Einstellung schafft es jedoch nicht die Kanten so gut zu erhalten.
         Grundlegend gilt, dass die Berechnung schneller ist je kleiner 'customMaxWidth'.

Danach kann das Skript 'exceute3D.m' ausgeführt werden um eine 3D Rekonstruktion der Szene mit Hilfe der ausgerechneten
Disparity Map zu erstellen (man kann auch die Ground Truth nehmen, dafür im Skript, letzte Zeile 'D' zu 'G' ändern).

Nachdem "challenge.m" ausgeführt wurde, welche die Datei 'challenge.mat' erstellt, können die Unittests mit dem Befehl "runtests('test')" gestartet werden. 
'challenge.mat' wird von den Unittest benötigt wird, um die zu überprüfenden Variablen einzulesen.
Innerhalb der "challenge.m" Datei normieren wir die Ground Truth zusätzlich, da Matlabs Funktion psnr dies nicht automatisch macht. 
Dadurch kann ein minimaler Threshold gewährleistet werden.

Um die GUI zu starten einfach die 'start_gui.m' Funktion ausführen. Danach kann per Klick auf 'Folder' der Szenenordner ausgewählt 
und mit einem weiteren Klick auf 'Disparity Map' die Disparity Map berechnet werden. Auch können hier Parameter der funktion 'disparity_map' geändert werden.
Achtung: Es kann vorkommen, dass der Ladebalken bei 90% plötzlich stehen bleibt. Das ist normal und heißt nicht, dass das
         Programm hängen geblieben ist.
         Auch hier können die Parameter eingestellt werden für schnellere Berechnungen oder bessere Disparity Maps.


Erklärung von (Zusatz-)Funktionen:

Die Funktion 'disparity_map' is zuständig für die Berechnung der Disparity Map. Diese nimmt als Input  
den Pfad zum Szenenorder und weitere optionale Parameter. Die Erklärung der Parameter kann in der Dokumentation oder direkt in der Funktion
als Kommentare nachgelesen werden. Die Outputs sind die Disparity Map D, Rotationsmatrix R, und Translationvektor T in meter.
Anmerkung: Die Standard Preproccessing Option is "histeq". Diese kann Kanten und Ecken gut erhalten, scheitert jedoch oft bei texturlosen Flächen.
           In solchen Fällen zeigt sich die Option "sobel" oftmals besser, welche robuster gegenüber texturlose Flächen scheint als die "histeq" Option.
Achtung: Das Disparity Intervall muss angeben sein als vielfaches der Bildbreite. Z.b. für ein Bild mit Breite 1200 Pixel und maximale
         Disparität 280 Pixel und minimal Disparität 0, muss die Eingabe wie folgt lauten: ('disparityInterval',[0 280/1200]).
         Jedoch, Größen wie 'blockSize' (Sgementkantenlänge für Kostenberechnung) und 'median_length' (Sgementkantenlänge für Medianfilter) müssen
         in Pixel angegeben sein bezüglich einer gewählten maximalen Bildbreite 'customMaxWidth'.

Die Funktion 'reconstruct3d' ist zu ständig für 3D Rekonstruktion. Die Funktion nimmt als Input die DisparityMap, Brennweite
in Pixel, Basislinie in mm, x-unterschied der Brennpunkte in Pixel, Kalibireungsmatrix und das zugehörige Stereobild. Output ist
ein Plot der Szene in 3D. 

Die Funktion 'readpfm.m' liest eine .pfm Datei in einem ausgewählten Ordnerpfad.

Der Ordner 'functions' ist eine Bibliothek mit Funktionen, welche für die Berechnung der Disparity Map benötigt werden.

Um das Design der GUI zu bearbeiten, geben Sie guide("start_gui.fig") in der matlab-Konsole ein und öffnen Sie die angegebene Figure-Datei zur Bearbeitung in GUIDE.
Guide startet GUIDE, eine UI-Designumgebung.