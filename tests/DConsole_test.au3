#include "DConsole.au3"

Dim $sPath = ""

GUICreate("UPX GUI", 345, 140)
$input = GUICtrlCreateInput("", 5, 5, 300, 24)
$button = GUICtrlCreateButton("...", 310, 5, 30, 24)
$label = GUICtrlCreateLabel("Current compression:", 5, 45, 300, 24)
$progress = GUICtrlCreateProgress(5, 70, 300, 24)
$buttonrun = GUICtrlCreateButton("Compress", 5, 110, 80, 24)
$check = GUICtrlCreateCheckbox("Best compression", 100, 110, 130, 24)
GUISetState()

While 1
    $msg = GUIGetMsg()
    If $msg = -3 Then Exit
    If $msg = $button Then
       $sPath = FileOpenDialog("Select file to compress:", $sPath, "Executables (*.exe)")
       GUICtrlSetData($input, $sPath)
    Endif        
    If $msg = $buttonrun Then
        If $sPath = "" Then Continueloop
        GUICtrlSetState($buttonrun, 128)
        $best = ""
        If GUICtrlRead($check) = 1 Then $best = "--best "
        $pid = _DConsoleRun(@ScriptDir & "\upx.exe " & $best & $sPath)
        While ProcessExists($pid)
            $gd = StringStripWs(_DConsoleRead(), 7)
            $percent = StringRegExp($gd, "\[(\**)\.*\]", 1)
            If @Extended Then $percent = StringLen($percent[0]) * (100 / 64)
            $compercent = StringRegExp($gd, "\s(\d+?\.\d+?)%", 1)
            If @Extended Then $compercent = $compercent[0]
            GUICtrlSetData($label, "Current compression: " & $compercent & " %")
            GUICtrlSetData($progress, $percent)
        Wend       
        _DConsoleFree()
        GUICtrlSetState($buttonrun, 64)
    Endif
Wend
