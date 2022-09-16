;*****************************************
;ytdlp-gui.au3 by jichs
;Erstellt mit ISN AutoIt Studio v. 1.13
;*****************************************
#include "windowMain.isf"
#include <Array.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>


const $DLERROR = 0xFF0000
const $DLINPROCESS = 0xFFFF00
const $DLSUCCESS = 0x339966
$dlpath = ""
$videotitle = ""
$gesamtlog = ""
$link = ""

Opt("GUIOnEventMode", 1)


readsettings()
GUISetOnEvent($GUI_EVENT_CLOSE, "Terminate")
GUISetState(@SW_SHOW)
Global $globallogstr
$dlbitrate = ""

GUICtrlSetState($input720p, $GUI_DISABLE)

consolewrite(GUICtrlGetState($menuOverwrieHandler))

While 1


	$action = GUIGetMsg()
	select
		; DETECT DRAG AND DROP EVENT HERE <-------------------
		Case _GUICtrlRichEdit_GetText($input720p) <> ''     ;And Not GUICtrlRead($dircont)
			$dlbitrate = "720p"
			dlIn720p()
		Case _GUICtrlRichEdit_GetText($input360p) <> ''     ;And Not GUICtrlRead($dircont)
			$dlbitrate = "360p"
			dlIn360p()
	endselect


	Sleep(50)
WEnd

Func Terminate()
	_GUICtrlRichEdit_Destroy($windowmain)
	Exit
EndFunc   ;==>Terminate

func dlIn720p()
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = _GUICtrlRichEdit_GetText($input720p)
	$link = StringReplace($link, 'https://www.youtube.com/shorts/', 'https://www.youtube.com/watch?v=')

	if(not StringInStr($link, 'watch')) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)
		return
	EndIf

	GUICtrlSetState($btnDl720p, $GUI_DISABLE)
	GUICtrlSetState($input720p, $GUI_DISABLE)

	$params = " -22 -P home:" & $dlpath & " "
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		$params &= " --force-overwrites "
	EndIf
	startDL($link, $params, "")
	_GUICtrlRichEdit_SetText($input720p, "")
	GUICtrlSetState($input720p, $GUI_ENABLE)
	GUICtrlSetState($btnDl720p, $GUI_ENABLE)
EndFunc   ;==>dlIn720p

func dlIn360p()
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	GUICtrlSetState($btnDl360p, $GUI_DISABLE)
	GUICtrlSetState($input360p, $GUI_DISABLE)
	$link = _GUICtrlRichEdit_GetText($input360p)
	$link = StringReplace($link, 'https://www.youtube.com/shorts/', 'https://www.youtube.com/watch?v=')


	startDL($link, "--force-overwrites   -f 18 -P home:" & $dlpath & " ", "")
	_GUICtrlRichEdit_SetText($input360p, "")
	GUICtrlSetState($input360p, $GUI_ENABLE)
	GUICtrlSetState($btnDl360p, $GUI_ENABLE)
EndFunc   ;==>dlIn360p

func loggen($text, $guictrl = $globalLog)
	$text = StringRegExpReplace($text, "(?m)(\r\n){2,}", @CRLF)
	ConsoleWrite($text & @CRLF)
	$textLog = StringRegExpReplace(GUICtrlRead($guictrl), "(?m)(\r\n){2,}", @CRLF)
	$textLog = StringStripWS($textLog, 3)

	GUICtrlSetData($guictrl, $text & @CRLF & $textLog)
EndFunc   ;==>loggen

Func startDL($link, $params, $log)
	GUICtrlSetBkColor($globalLog, $DLINPROCESS)
	$gesamtlog = ""
	Local $line
	loggen("yt-dlp.exe --no-mtime --no-part " & $params & " -n16 " & $link & @crlf)

	$proc = Run("yt-dlp.exe --no-mtime --no-part " & $params & "  " & $link, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While 1
		$line = StdoutRead($proc)
		$gesamtlog &= $line
		If @error Then ExitLoop
		loggen($line)
	Wend
	GUICtrlSetData($log, $line)

	if StringInStr($gesamtlog, "error") then
		_GUICtrlRichEdit_SetText($input360p, $link)
		GUICtrlSetBkColor($globalLog, $DLERROR)
		if $dlbitrate = "360p" then
			MsgBox($MB_TOPMOST, "Error " & $dlbitrate, $gesamtlog)
		EndIf
		loggen($link & @crlf & $videotitle & @crlf & " download error")
		return
	EndIf

	GUICtrlSetBkColor($globalLog, $DLSUCCESS)
	loggen($link & @crlf & $videotitle & @crlf & "Download process complete")
	if StringInStr($gesamtlog, "already been") then
		loggen($link & @crlf & $videotitle & @crlf & "File already existed")
	EndIf
EndFunc   ;==>startDL

func opensettings()
	$dldir = FileSelectFolder("dialog text)", "c:\")

	if(StringLen($dldir) > 2) Then
		IniWrite("settings.ini", "", "download_to", $dldir)
		loggen("DL dir set to=" & $dldir)
		readsettings()
	EndIf
EndFunc   ;==>opensettings

func getvideotitle()
	if StringLen($videotitle) > 3 then
		return $videotitle
	EndIf

	$aArray = _StringBetween($gesamtlog, "Destination: ", "].mp4")

	if isarray($aArray) Then
		$tempfile = $aArray[0]
		return $tempfile ;
	EndIf


endfunc   ;==>getvideotitle

func readsettings()
	$dlpath = IniRead("settings.ini", "", "download_to", "c:\_downloads\")
EndFunc   ;==>readsettings

func overwriteClicked()
	$title = WinGetTitle($windowMain)
	$title = stringreplace($title, " [overwrite]", "")

	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($menuOverwrieHandler, $GUI_UNCHECKED)
		WinSetTitle($windowMain, "", $title & "")
	Else
		GUICtrlSetState($menuOverwrieHandler, $GUI_CHECKED)
		WinSetTitle($windowMain, "", $title & " [overwrite]")
	EndIf

EndFunc   ;==>overwriteClicked
