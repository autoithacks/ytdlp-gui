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
$dlpath=""

Opt("GUIOnEventMode", 1)


readsettings()
GUISetOnEvent($GUI_EVENT_CLOSE, "Terminate")
GUISetState(@SW_SHOW)
Global $globallogstr
	

While 1
	
	
    $action = GUIGetMsg()
    select
   ; DETECT DRAG AND DROP EVENT HERE <-------------------
    Case _GUICtrlRichEdit_GetText($input720p) <> '' ;And Not GUICtrlRead($dircont)
         dlIn720p()
    Case _GUICtrlRichEdit_GetText($input360p) <> '' ;And Not GUICtrlRead($dircont)
         dlIn360p()
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
			 GUICtrlSetBkColor($globalLog,$DLERROR)
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
	startDL($link, "--force-overwrites   -f 18 -P home:"&$dlpath & " ",  "")
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

	GUICtrlSetBkColor($globalLog,$DLINPROCESS)
	$gesamtlog = ""
	Local $line
	loggen("yt-dlp.exe --no-mtime --no-part " &  $params& " -n16 " & $link & @crlf)

	$proc = Run ( "yt-dlp.exe --no-mtime --no-part " &  $params& "  " & $link , @ScriptDir,  @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD )

While 1
    $line  =StdoutRead($proc)
    $gesamtlog &= $line
	;$gesamtlog &= @crlf
	If @error Then ExitLoop
   ; MsgBox(0, "STDOUT read:", $line)
	loggen($line)
Wend
GUICtrlSetData($log, $line)

if StringInStr($gesamtlog, "error")   then
		_GUICtrlRichEdit_SetText($input360p, $link)
		GUICtrlSetBkColor($globalLog,$DLERROR)
       #cs
		$aArray = _StringBetween($gesamtlog, "Destination: ", "].mp4")
		 
		if isarray($aArray) Then 
			$tempfile = $aArray[0]
			FileDelete($tempfile &  "].mp4.part")			
		EndIf
		#ce
		
		MsgBox($MB_TOPMOST, "STDOUT read:", $gesamtlog)
	return
EndIf


if  StringInStr($gesamtlog, "already been")  then
;		MsgBox($MB_TOPMOST, "Already downloaded!", $gesamtlog)	
	
MsgBox(262192,"Already downloaded","File already exists!",0)

	GUICtrlSetBkColor($globalLog,$DLSUCCESS)	
	return
EndIf
	GUICtrlSetBkColor($globalLog,$DLSUCCESS)
	loggen(@crlf& "Download complete")
EndFunc

func opensettings()
	$dldir = FileSelectFolder ( "dialog text)", "c:\" )
	
	if(StringLen($dldir ) > 2) Then 
	IniWrite("settings.ini", "", "download_to", $dldir)
	loggen("DL dir set to=" & $dldir)
	readsettings()
	EndIf 
EndFunc

func readsettings(	)
$dlpath=  IniRead("settings.ini", "", "download_to", "c:\_downloads\") 
EndFunc 
