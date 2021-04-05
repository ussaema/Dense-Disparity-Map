
Benutzung:

Um Disparity Map, Rotation und Translation zu berechnen, bitte 'challenge.m' datei ausf�hren.
Achtung: Mit der vorliegenden Parametereinstellung berechnet sich die Disp�rity Map in ca. 30 - 50 sekunden (oder mehr, ist abh�ngig von den Disparity Levels).
         Es ist m�glich, vergleichbar gutes PSNR in ca. h�lfte der zeit zu erhalten, 10 - 20 sekunden, mit der Parameter�bergabe ('preprocess',"sobel",'customMaxWidth',700)
         f�r die 'disparity_map' Funktion (Zeile 25). Diese Einstellung schafft es jedoch nicht die Kanten so gut zu erhalten.
         Grundlegend gilt, dass die Berechnung schneller ist je kleiner 'customMaxWidth'.

Danach kann das Skript 'exceute3D.m' ausgef�hrt werden um eine 3D Rekonstruktion der Szene mit Hilfe der ausgerechneten
Disparity Map zu erstellen (man kann auch die Ground Truth nehmen, daf�r im Skript, letzte Zeile 'D' zu 'G' �ndern).

Nachdem "challenge.m" ausgef�hrt wurde, welche die Datei 'challenge.mat' erstellt, k�nnen die Unittests mit dem Befehl "runtests('test')" gestartet werden. 
'challenge.mat' wird von den Unittest ben�tigt wird, um die zu �berpr�fenden Variablen einzulesen.
Innerhalb der "challenge.m" Datei normieren wir die Ground Truth zus�tzlich, da Matlabs Funktion psnr dies nicht automatisch macht. 
Dadurch kann ein minimaler Threshold gew�hrleistet werden.

Um die GUI zu starten einfach die 'start_gui.m' Funktion ausf�hren. Danach kann per Klick auf 'Folder' der Szenenordner ausgew�hlt 
und mit einem weiteren Klick auf 'Disparity Map' die Disparity Map berechnet werden. Auch k�nnen hier Parameter der funktion 'disparity_map' ge�ndert werden.
Achtung: Es kann vorkommen, dass der Ladebalken bei 90% pl�tzlich stehen bleibt. Das ist normal und hei�t nicht, dass das
         Programm h�ngen geblieben ist.
         Auch hier k�nnen die Parameter eingestellt werden f�r schnellere Berechnungen oder bessere Disparity Maps.


Erkl�rung von (Zusatz-)Funktionen:

Die Funktion 'disparity_map' is zust�ndig f�r die Berechnung der Disparity Map. Diese nimmt als Input  
den Pfad zum Szenenorder und weitere optionale Parameter. Die Erkl�rung der Parameter kann in der Dokumentation oder direkt in der Funktion
als Kommentare nachgelesen werden. Die Outputs sind die Disparity Map D, Rotationsmatrix R, und Translationvektor T in meter.
Anmerkung: Die Standard Preproccessing Option is "histeq". Diese kann Kanten und Ecken gut erhalten, scheitert jedoch oft bei texturlosen Fl�chen.
           In solchen F�llen zeigt sich die Option "sobel" oftmals besser, welche robuster gegen�ber texturlose Fl�chen scheint als die "histeq" Option.
Achtung: Das Disparity Intervall muss angeben sein als vielfaches der Bildbreite. Z.b. f�r ein Bild mit Breite 1200 Pixel und maximale
         Disparit�t 280 Pixel und minimal Disparit�t 0, muss die Eingabe wie folgt lauten: ('disparityInterval',[0 280/1200]).
         Jedoch, Gr��en wie 'blockSize' (Sgementkantenl�nge f�r Kostenberechnung) und 'median_length' (Sgementkantenl�nge f�r Medianfilter) m�ssen
         in Pixel angegeben sein bez�glich einer gew�hlten maximalen Bildbreite 'customMaxWidth'.

Die Funktion 'reconstruct3d' ist zu st�ndig f�r 3D Rekonstruktion. Die Funktion nimmt als Input die DisparityMap, Brennweite
in Pixel, Basislinie in mm, x-unterschied der Brennpunkte in Pixel, Kalibireungsmatrix und das zugeh�rige Stereobild. Output ist
ein Plot der Szene in 3D. 

Die Funktion 'readpfm.m' liest eine .pfm Datei in einem ausgew�hlten Ordnerpfad.

Der Ordner 'functions' ist eine Bibliothek mit Funktionen, welche f�r die Berechnung der Disparity Map ben�tigt werden.

Um das Design der GUI zu bearbeiten, geben Sie guide("start_gui.fig") in der matlab-Konsole ein und �ffnen Sie die angegebene Figure-Datei zur Bearbeitung in GUIDE.
Guide startet GUIDE, eine UI-Designumgebung.