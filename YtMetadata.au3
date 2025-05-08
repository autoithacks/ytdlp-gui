#include <MsgBoxConstants.au3>
#include <Process.au3> ; Für Run(), StdoutRead(), ProcessExists()
#include <String.au3>  ; Für StringRegExp()
#include <File.au3> ; Für _FileReadToArray
#include <MsgBoxConstants.au3> ; Für MsgBox


#cs
; Beispielaufruf der Funktion
Local $sVideoURL = "https://www.youtube.com/watch?v=mk_hoDXjvPw"
Local $sChannelName = getChannelNameFromUrl($sVideoURL)

If $sChannelName <> "" Then
    MsgBox($MB_OK, "Kanalname", "Der Kanalname lautet: " & $sChannelName)
Else
    MsgBox($MB_OK, "Fehler", "Kanalname konnte nicht ermittelt werden.")
EndIf
#Ce


; Funktion zum Extrahieren des Kanalnamens aus einer YouTube-Video-URL
Func getChannelNameFromUrl($sVideoURL)
    ; Pfad zu yt-dlp (falls nicht im PATH, gib den vollständigen Pfad an)
    Local $sYtDlpPath = "yt-dlp" ; oder z. B. "C:\Pfad\zu\yt-dlp.exe"

    ; Befehl zum Abrufen der Metadaten mit yt-dlp
    Local $sCommand = $sYtDlpPath & ' --dump-json "' & $sVideoURL & '"'

    ; Führe den Befehl aus und lies die Ausgabe
    Local $sOutput = RunCommand($sCommand)

    ; Extrahiere den Kanalnamen aus der JSON-Ausgabe
    Local $sUploader = ExtractJSONValue($sOutput, "uploader")
	
;	MsgBox($MB_OK, "Kanalname", "Der Kanalname lautet: " & $sUploader)

    ; Gib den Kanalnamen zurück
    Return $sUploader
EndFunc

; Funktion zum Ausführen eines Befehls und Zurückgeben der Ausgabe
Func RunCommand($sCmd)
    ; Numerische Werte für STDERR und STDOUT
    Local $STDOUT_CHILD = 2 ; Standardausgabe
    Local $STDERR_CHILD = 4 ; Fehlerausgabe

    ; Führe den Befehl aus und erfasse sowohl STDOUT als auch STDERR
    Local $iPID = Run('"' & @ComSpec & '" /c ' & $sCmd, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
    Local $sOutput = ""
    While ProcessExists($iPID)
        $sOutput &= StdoutRead($iPID)
    WEnd
    Return $sOutput
EndFunc

; Funktion zum Extrahieren eines Werts aus der JSON-Ausgabe
Func ExtractJSONValue($sJSON, $sKey)
    Local $aRegex = StringRegExp($sJSON, '"' & $sKey & '":\s*"([^"]+)"', 1)
    If Not @error Then
        Return $aRegex[0]
    EndIf
    Return ""
EndFunc




; Funktion zum Verarbeiten der CSV-Datei und Aufrufen der Download-Funktionen
Func getDLfunction($channelToCheck)
	$sCsvFilePath="channelDLset.csv"
    ; CSV-Datei einlesen
    Local $aCsvData
    If Not _FileReadToArray($sCsvFilePath, $aCsvData) Then
        MsgBox($MB_ICONERROR, "Fehler", "CSV-Datei konnte nicht gelesen werden.")
        Return False
    EndIf

    ; CSV-Daten verarbeiten
    For $i = 1 To $aCsvData[0] ; $aCsvData[0] enthält die Anzahl der Zeilen
        Local $aLine = StringSplit($aCsvData[$i], ";") ; Zeile in Spalten aufteilen
        
            Local $sChannelName = StringStripWS($aLine[1], $STR_STRIPLEADING + $STR_STRIPTRAILING) ; Kanalname (ohne Leerzeichen)
            Local $sDownloadFunction = StringStripWS($aLine[2], $STR_STRIPLEADING + $STR_STRIPTRAILING) ; Download-Funktion (ohne Leerzeichen)
			if 	($sChannelName=$channelToCheck) then
				  ; MsgBox(0, "Gefunden", $sChannelName & " soll via "&$sDownloadFunction )
     			return $sDownloadFunction
            EndIf
        
    Next

    Return ""
EndFunc