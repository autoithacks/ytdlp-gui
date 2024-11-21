;*****************************************
;ytdlp-gui.au3 by jichs
;Erstellt mit ISN AutoIt Studio v. 1.13
;*****************************************
#pragma compile(AutoItExecuteAllowed, True)
#include "windowMain.isf"
#include <Array.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>


const $DLERROR = 0xFF0000
const $DLINPROCESS = 0xFFFF00
const $DLSUCCESS = 0x339966
const $opt_params2='  --embed-subs --write-auto-sub  --no-mtime --no-part '
const $opt_sdubtitles=' --write-subs --write-auto-subs --sub-langs "en, en-orig" --embed-subs  --convert-subs srt --compat-options no-keep-subs '&$opt_params2

$defaultBirate="1080|720|highest" 
$defaultBirateSelected="1080"
GUICtrlSetData($bitrateselect, "", "")
GUICtrlSetData($bitrateselect, $defaultBirate, $defaultBirateSelected)

$dlpath = ""
$videotitle = ""
$line = ""
$gesamtlog = ""
$link = ""
Global $globallogstr
$dlbitrate = ""
$downloading = false

Opt("GUIOnEventMode", 1)

AdlibRegister("getProgress", 250)
readsettings()
GUISetOnEvent($GUI_EVENT_CLOSE, "Terminate")
GUISetState(@SW_SHOW)
GUICtrlGetState($menuOverwrieHandler)


;GUICtrlSetState($input720p, $GUI_DISABLE)



While 1

	$action = GUIGetMsg()
	select
		; DETECT DRAG AND DROP EVENT HERE <-------------------
		Case _GUICtrlRichEdit_GetText($input720p) <> ''     ;And Not GUICtrlRead($dircont)
			selectBitrate ()
		Case _GUICtrlRichEdit_GetText($input360p) <> ''     ;And Not GUICtrlRead($dircont)
			$dlbitrate = "360p"
			dlIn360p()
	endselect


	Sleep(50)
WEnd


func selectBitrate ()
	
			If GUICtrlRead($bitrateSelect) = "1080"Then 
			$dlbitrate = "1080p"
			dlIn1080p()
			Elseif GUICtrlRead($bitrateSelect) = "720"Then 
			$dlbitrate = "720p" 
			dlIn720p()
			else
			dlInHighest()			
			EndIf 
			
EndFunc
	
	
Func Terminate()
	_GUICtrlRichEdit_Destroy($windowmain)
	Exit
EndFunc   ;==>Terminate

Func correctURL($link)
	$link = StringReplace($link, 'https://www.youtube.com/shorts/', 'https://www.youtube.com/watch?v=')
	$link = StringReplace($link, '&list=', '&-&')
	
	if GUICtrlGetState($MenuPlaylist) then 		
			$link = StringReplace($link, '&-&', '&list=')
	EndIf 
		
	return $link
EndFunc   ;==>Terminate


func dlInHighest()
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	
	if(not StringInStr($link, 'watch')) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)
		setReadOnly(false)
		return
	EndIf

	GUICtrlSetState($input720p, $GUI_DISABLE)
	
	
;	$params = " -f mp4 "& $opt_params2 & "  --sponsorblock-remove all -o  " &$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
	$params = " -22  -P home:" & $dlpath & " "& "--no-mtime --no-part"
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		$params &= " --force-overwrites "
	EndIf
	startDL($link, $params, "")
	_GUICtrlRichEdit_SetText($input720p, "")
	GUICtrlSetState($input720p, $GUI_ENABLE)
EndFunc   ;==>dlIn720p

func dlIn720p()
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	
	if(not StringInStr($link, 'watch')) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)
		setReadOnly(false)
		return
	EndIf

	GUICtrlSetState($input720p, $GUI_DISABLE)
	
	
	$params = " -f mp4 "& $opt_params2 & "  --sponsorblock-remove all -o  " &$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		$params &= " --force-overwrites "
	EndIf
	startDL($link, $params, "")
	_GUICtrlRichEdit_SetText($input720p, "")
	GUICtrlSetState($input720p, $GUI_ENABLE)
EndFunc   ;==>dlIn720p


func dlIn1080p()	
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	
	
	if( StringInStr($link, 'odysee.com')) then
	downloadOdysee($link,"")
	return
	endif

	if(not StringInStr($link, 'watch')) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)	
		setReadOnly(false)
		return
	EndIf

	$params = $opt_sdubtitles&" -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o  -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o "&$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
loggen(":---------------------")	
loggen(@crlf & $params &@crlf)
loggen("+---------------------")	
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		$params &= " --force-overwrites "
	EndIf
	startDL($link, $params, "")
	_GUICtrlRichEdit_SetText($input720p, "")

EndFunc   ;==>dlIn1080p


func dlIn360p()	

	
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = _GUICtrlRichEdit_GetText($input360p)
	$link = StringReplace($link, 'https://www.youtube.com/shorts/', 'https://www.youtube.com/watch?v=')
	$link = correctURL($link)
	
	if( StringInStr($link, 'odysee.com')) then
		downloadOdysee($link," -f hls-655 ")
	return
	endif	

	startDL($link, "  --force-overwrites  --no-mtime  --no-part   -f 18 -P home:" & $dlpath & " ", "")
	_GUICtrlRichEdit_SetText($input360p, "")

EndFunc   ;==>dlIn360p

func loggen($text, $guictrl = $globalLog)
	$text = StringRegExpReplace($text, "(?m)(\r\n){2,}", @CRLF)
	ConsoleWrite($text & @CRLF)
	$textLog = StringRegExpReplace(GUICtrlRead($guictrl), "(?m)(\r\n){2,}", @CRLF)
	$textLog = StringStripWS($textLog, 3)
	$textLog = StringReplace($textLog,  @crlf&""&@crlf,@crlf)

	GUICtrlSetData($guictrl, $text  & $textLog)
EndFunc   ;==>loggen

Func downloadOdysee($link,$quality)
	
	startDL($link, $quality &' --no-mtime ', "")
	ShellExecuteWait("cmd","/c ren *.webm *.mp4 ",@scriptdir,'',@SW_HIDE )
	ShellExecuteWait("cmd","/c ren *.mkv *.mp4 ",@scriptdir,'',@SW_HIDE )
	;ShellExecute("cmd","/c move *.mp4 "& $dlpath,@scriptdir, '',@SW_HIDE )
EndFunc   ;==>Terminate

func setReadOnly($state)
	_GUICtrlRichEdit_SetReadOnly($input720p, $state)
	_GUICtrlRichEdit_SetReadOnly($input360p, $state)
	if($state = false)then
	_GUICtrlRichEdit_SetText($input720p, "")
	_GUICtrlRichEdit_SetText($input360p, "")
	GUICtrlSetData($bitrateselect, "", "")
	GUICtrlSetData($bitrateselect, $defaultBirate, $defaultBirateSelected)
	
	EndIf 
endfunc


func getProgress()
	$procent = _StringBetween2($line, "[download]", "%", 20)	
	ConsoleWrite(@SEC& " ->" & $procent& @crlf)
	
    if $procent <> "" then
		;loggen($procent& " " & @crlf)
		GUICtrlSetData($progressBar, $procent)
	EndIf 	
EndFunc

Func startDL($link, $params, $log)
	;$proc = Run("yt-dlp.exe  --update-to nightly " , @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	GUICtrlSetBkColor($globalLog, $DLINPROCESS)
	$gesamtlog = ""
	$downloading = true
	;Local $line
	loggen("yt-dlp.exe  " & $link & " " & $params & @crlf)

	$proc = Run("yt-dlp.exe " & $params & "  " & $link, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	setReadOnly(true)
	While 1
		$line = StdoutRead($proc)
		$line2 = StderrRead ($proc)
		$gesamtlog &= $line&@CRLF&$line2
		If @error Then ExitLoop
		loggen($line&@CRLF&$line2)
		sleep(500)
	Wend

		
	GUICtrlSetData($log, $line)
	
	if StringInStr($gesamtlog,"Requested format is not available") and $dlbitrate <> "720p"  then
		_GUICtrlRichEdit_SetText($input720p, $link)		
		dlIn1080p()
	endif

	if StringInStr($gesamtlog,"Got error: <urlopen error [Errno 11001]") and not StringInStr($gesamtlog,"Got error: [WinError 10054]") then
		;_GUICtrlRichEdit_SetText($input360p, $link)
		GUICtrlSetBkColor($globalLog, $DLERROR)
		;if $dlbitrate = "360p" then
			MsgBox($MB_TOPMOST, "Error " & $dlbitrate, $gesamtlog)
			saveText( "error-"&@HOUR&@MIN&@SEC&".txt", $gesamtLog)
		;EndIf
		loggen($link & @crlf & $videotitle & @crlf & " download failed")
		setReadOnly(false)
		return
	EndIf
	


	GUICtrlSetBkColor($globalLog, $DLSUCCESS)
	loggen($link & @crlf & $videotitle & @crlf & "Download process complete")
	if StringInStr($gesamtlog, "already been") then
		loggen($link & @crlf & $videotitle & @crlf & "File already exists")
	EndIf
	
	GUICtrlSetData($progressBar, 100)
	ShellExecuteWait("cmd","/c ren *.webm *.mp4 ",@scriptdir,'',@SW_HIDE )
	ShellExecuteWait("cmd","/c ren *.mkv *.mp4 ",@scriptdir,'',@SW_HIDE )
	ShellExecute("cmd","/c move *.mp4 "& $dlpath,@scriptdir, '',@SW_HIDE )
	setReadOnly(false)	
	$downloading = false
	GUICtrlSetData($progressBar, 0)

EndFunc   ;==>startDL

Func _StringBetween2($s, $from, $to, $maxlen = 10)
	$x = StringInStr($s, $from) + StringLen($from)
	$y = StringInStr(StringTrimLeft($s, $x), $to)

	$ret = StringMid($s, $x, $y)
	If StringLen($ret) <= $maxlen Then
		Return $ret
	Else
		Return ""
	EndIf

EndFunc   ;==>_StringBetween2

func opensettings()
	$dldir = FileSelectFolder("dialog text)", "c:\")
	if(StringLen($dldir) > 2) Then
		IniWrite("settings.ini", "", "download_to", $dldir)
		loggen("DL dir set to=" & $dldir)
		readsettings()
	EndIf
EndFunc   ;==>opensettings

func getvideotitle()
	return _StringBetween2($gesamtlog, "Destination: ", "].mp4",  40)

endfunc   ;==>getvideotitle

func readsettings()
	$dlpath = IniRead("settings.ini", "", "download_to", "c:\_downloads\")
EndFunc   ;==>readsettings

func newinstance()
	_RunAU3("ytdlp-gui.au3")
EndFunc   ;==>newinstance

func funcCheckEXEUpdates()
	ShellExecute("https://github.com/yt-dlp/yt-dlp#release-files")
EndFunc

func overwriteClicked()
	$title = WinGetTitle($windowMain)
	$title = stringreplace($title, " [+R]", "")

	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($menuOverwrieHandler, $GUI_UNCHECKED)
		WinSetTitle($windowMain, "", $title & "")
	Else
		GUICtrlSetState($menuOverwrieHandler, $GUI_CHECKED)
		WinSetTitle($windowMain, "", $title & " [+R]")
	EndIf

EndFunc   ;==>overwriteClicked

func playlistClicked()
	$title = WinGetTitle($windowMain)
	$title = stringreplace($title, " [pl]", "")

	If BitAnd(GUICtrlRead($MenuPlaylist), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($MenuPlaylist, $GUI_UNCHECKED)
		WinSetTitle($windowMain, "", $title & "")
				
	Else
		GUICtrlSetState($MenuPlaylist, $GUI_CHECKED)
		WinSetTitle($windowMain, "", $title & " [pl]")
	EndIf

EndFunc   ;==>overwriteClicked

Func _RunAU3($sFilePath, $sWorkingDir = @ScriptDir, $iShowFlag = @SW_SHOW, $iOptFlag = 0)
	Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '"', $sWorkingDir, $iShowFlag, $iOptFlag)
	;ShellExecuteWait(@ProgramFilesDir & '\AutoIt3\Aut2Exe\Aut2exe.exe', ' /in .au3')
EndFunc   ;==>_RunAU3

Func saveText($filename = "", $text = "")
    ConsoleWrite("speichereText: " & @CRLF & $text)
    Local $file = ""

    ;if gesamtLog
    $file = FileOpen($filename, 2+256)

    ; Check if file opened for writing OK
    If $file = -1 Then
        MsgBox(0, "Error", "Error writing.")
        ;Exit
    EndIf

    FileWrite($file, $text & @CRLF)
    FileClose($file)
EndFunc   ;==>speichereText
