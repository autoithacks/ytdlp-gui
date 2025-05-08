#include <GUIConstantsEx.au3>
#include <EditConstants.au3> ; Diese Include-Datei enthält $ES_READONLY
#include "ytMetadata.au3"
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <EditConstants.au3>
#include <GuiRichEdit.au3>
#include <ProgressConstants.au3>
#include <ComboConstants.au3>
#Include <GuiMenu.au3>
#include <WinAPIShellEx.au3>

; GUI erstellen
Local $hGUI = GUICreate("Get Channel ID", 400, 200)
$idInput = _GUICtrlRichEdit_Create($hGUI,"",10,0,380,44,-1,-1)
Local $idButton = GUICtrlCreateButton("GO", 150, 50, 100, 30) ; Schaltfläche
Local $idOutput = GUICtrlCreateInput("", 10, 100, 380, 25) ; Textfeld für die Ausgabe (schreibgeschützt)

GUISetState(@SW_SHOW) ; GUI anzeigen

; Hauptschleife
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop ; Fenster schließen
        Case $idButton 
            ; Text aus dem Eingabefeld lesen
			checkChanneName()
			#cs
		Case _GUICtrlRichEdit_GetText($idInput) <> ''		
			 _GUICtrlRichEdit_SetText($idInput,"") 
			 checkChanneName()
			 #ce
    EndSwitch
	Sleep(50)
WEnd

func checkChanneName()
			$url=_GUICtrlRichEdit_GetText($idInput)
            GUICtrlSetState($idButton, $GUI_DISABLE)
			Local $sUserInput = getChannelNameFromUrl ( $url)
            ; Text in das Ausgabefeld schreiben
            GUICtrlSetData($idOutput,  ($sUserInput) )
            GUICtrlSetState($idButton, $GUI_ENABLE)
			_GUICtrlRichEdit_SetText($idInput,"")			

EndFunc

GUIDelete($hGUI) ; GUI löschen


