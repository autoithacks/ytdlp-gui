;*****************************************
;ytdlp-gui.au3 by jichs
;Erstellt mit ISN AutoIt Studio v. 1.13
;*****************************************
#include "windowMain.isf"
#include <Array.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>


Opt("GUIOnEventMode", 1)
#cs
$mFilemenu = GUICtrlCreateMenu("File")
$mExititem = GUICtrlCreateMenuItem("Exit", $mFilemenu)
$mSpecialitem = GUICtrlCreateMenuItem("?", -1) ; I belong to the main menu
#ce
GUISetOnEvent($GUI_EVENT_CLOSE, "Terminate")
GUISetState(@SW_SHOW)
Global $globallogstr
$dlpath= "c:\_downloads\"

While 1
	
	
    $action = GUIGetMsg()
    select
   ; DETECT DRAG AND DROP EVENT HERE <-------------------
    Case _GUICtrlRichEdit_GetText($input720p) <> '' ;And Not GUICtrlRead($dircont)
         dlIn720p()

           
    endselect
	
	
Sleep(50)
WEnd
 
Func Terminate()
    _GUICtrlRichEdit_Destroy($windowmain)
    Exit
EndFunc

func dlIn720p()

	$link = _GUICtrlRichEdit_GetText($input720p)
	if(not StringInStr($link, 'watch') ) then 
			 _GUICtrlRichEdit_SetText($input720p, "")
			 loggen("Draggin pictures not supported!")
		return
	EndIf 
	
	GUICtrlSetState($btnDl720p, $GUI_DISABLE)
		startDL($link, " -22 -P home:"&$dlpath & " ",  "")
	 _GUICtrlRichEdit_SetText($input720p, "")
	 GUICtrlSetState($btnDl720p, $GUI_ENABLE)
EndFunc

func dlIn360p()
	GUICtrlSetState($btnDl360p, $GUI_DISABLE)
	$link = _GUICtrlRichEdit_GetText($input360p)
	startDL($link, " -f 18 -P home:"&$dlpath & " ",  "")
	 _GUICtrlRichEdit_SetText($input360p, "")
	 GUICtrlSetState($btnDl360p, $GUI_ENABLE)
EndFunc

func loggen($text,  $guictrl = $globalLog)
	$text = StringRegExpReplace($text, "(?m)(\r\n){2,}", @CRLF)
	ConsoleWrite($text & @CRLF) 
	$textLog = StringRegExpReplace(GUICtrlRead($guictrl), "(?m)(\r\n){2,}", @CRLF)
	$textLog = StringStripWS($textLog, 3)
	GUICtrlSetData($guictrl, $text & @CRLF & $textLog )

	
EndFunc

Func startDL($link,  $params,  $log)	
	$gesamtlog = ""
	Local $line
	loggen("yt-dlp.exe " &  $params& " -n16 " & $link & @crlf)

;$nu = ShellExecuteWait ( "yt-dlp.exe",  $params& " -n 16 " & $link , @ScriptDir)

	$nu = Run ( "yt-dlp.exe " &  $params& "  " & $link , @ScriptDir,  @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD )

;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $nu = ' & $nu & @crlf & '>Error code: ' & @error & @crlf) ;### Debug Console

While 1
    $line  =StdoutRead($nu)
    $gesamtlog &= $line
	;$gesamtlog &= @crlf
	If @error Then ExitLoop
   ; MsgBox(0, "STDOUT read:", $line)
	loggen($line)
Wend
GUICtrlSetData($log, $line)

if StringInStr($gesamtlog, "error")   then
		MsgBox($MB_TOPMOST, "STDOUT read:", $gesamtlog)
        $aArray = _StringBetween($gesamtlog, "Destination: ", "].mp4")
        ; Display the results in _ArrayDisplay.
;        _ArrayDisplay($aArray, "$STR_ENDISSTART")
		_GUICtrlRichEdit_SetText($input360p, $link)
		if isarray($aArray) Then 
			$tempfile = $aArray[0]
			FileDelete($tempfile &  "].mp4.part")
			
		EndIf
		
	return
EndIf


if  StringInStr($gesamtlog, "already been")  then
		MsgBox($MB_TOPMOST, "Already downloaded!", $gesamtlog)		
	return
EndIf

	loggen(@crlf& "Download complete")
	


EndFunc