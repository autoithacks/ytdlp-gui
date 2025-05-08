#include <Array.au3> ; Optional, falls du Debugging-Ausgaben nutzen willst
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>

; Variablen initialisieren
Local $logData = "" ; Speichert den gesamten Konsolentext
Local $progress = 0 ; Speichert den Fortschritt in %

; GUI erstellen
GUICreate("Download Fortschritt", 400, 100)
Local $progressBar = GUICtrlCreateProgress(10, 40, 380, 20, $PBS_SMOOTH)
Local $label = GUICtrlCreateLabel("Fortschritt: 0%", 10, 10, 380, 20)
GUISetState(@SW_SHOW)

; Start des externen Download-Programms
Local $pid = Run('yt-dlp.exe', ' -F https://odysee.com/@RT:fd/MACHETE:f1', @SW_HIDE, $STDOUT_CHILD)

While True
    ; Lese die Ausgabe des Programms
    Local $output = StdoutRead($pid)
    
    ; Wenn keine Ausgabe erfolgt und der Prozess nicht mehr läuft, breche die Schleife ab
    If @error And Not ProcessExists($pid) Then ExitLoop
    
    ; Wenn es Ausgabe gibt, bearbeite sie
    If $output Then
        ; Füge den gesamten Text zur Log-Variable hinzu
        $logData &= $output
        
        ; Suche nach Fortschritt in Prozent, z.B. "50%" oder "50 %"
        Local $progressMatch = StringRegExp($output, '\b(\d{1,3})\s?%', 1)
        
        ; Wenn ein Fortschritt gefunden wurde, aktualisiere die Progressbar
        If IsArray($progressMatch) Then
            $progress = $progressMatch[0]
            
            ; Setze den Fortschritt in der GUI-Progressbar
            GUICtrlSetData($progressBar, $progress)
            
            ; Aktualisiere das Label
            GUICtrlSetData($label, "Fortschritt: " & $progress & "%")
        EndIf
    EndIf
    
    ; Eventuelle GUI-Ereignisse behandeln
    Local $msg = GUIGetMsg()
    If $msg = $GUI_EVENT_CLOSE Then ExitLoop ; Schließe die GUI bei Bedarf
WEnd

; Nach Beendigung des Downloads
MsgBox(0, "Download abgeschlossen", "Der Download ist abgeschlossen!")
