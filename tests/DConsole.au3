#include-once

;===============================================================================
;
; Description:      Functions for dynamically retreive data from console applications
; Requirement(s):   Autoit 3.104 Beta
; Return Value(s):  
; Author(s):        YDY (Lazycat)
; Version:          0.5
; Date:             25.02.2006
;
;===============================================================================

;===============================================================================
;
; Description:      Create console and run console application
; Parameter(s):     Run command, path, state
; Return Value(s):  Process ID
;
;===============================================================================

Func _DConsoleRun($sCommand, $sPath = "", $nState = @SW_HIDE)
    $ret = DllCall("Kernel32.dll", "hwnd", "AllocConsole")
    If $nState = @SW_HIDE Then
        $ret = DllCall("Kernel32.dll", "hwnd", "GetConsoleWindow")
        WinSetState($ret[0], "", @SW_HIDE)
    Endif
    Return Run($sCommand, $sPath)
EndFunc

;===============================================================================
;
; Description:      Read data from console
; Parameter(s):     Number of symbols read, start position
; Return Value(s):  String 
;
;===============================================================================

Func _DConsoleRead($nSymbolsRead = 2000, $nReadPos = 0)
    Local $ret = DllCall("Kernel32.dll", "hwnd", "GetStdHandle", "int", -11) ; $STD_OUTPUT_HANDLE = -11
    $hConsole = $ret[0]
    Local $lpNumberOfCharsRead = DllStructCreate("dword")
    Local $lpCharacter = DllStructCreate("byte[" & $nSymbolsRead * 2 & "]")
    Local $ret = DllCall("Kernel32.dll", "int", "ReadConsoleOutputCharacter", "int", $hConsole, _
                                                    "ptr", DllStructGetPtr($lpCharacter), _
                                                    "int", $nSymbolsRead, _
                                                    "int", $nReadPos, _
                                                    "ptr", DllStructGetPtr($lpNumberOfCharsRead))
    Return DllStructGetData($lpCharacter, 1)
EndFunc

;===============================================================================
;
; Description:      Free console
; Parameter(s):     None
; Return Value(s):  None
;
;===============================================================================

Func _DConsoleFree()
    DllCall("Kernel32.dll", "hwnd", "FreeConsole")
EndFunc
