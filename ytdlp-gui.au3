;*****************************************
;ytdlp-gui.au3 by jichs
;Erstellt mit ISN AutoIt Studio v. 1.13
;*****************************************
#pragma compile(AutoItExecuteAllowed, True)
#include "windowMain.isf"
#include "ytMetadata.au3"
#include <Array.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIGdi.au3>



const $DLERROR = 0xFF0000
const $DLINPROCESS = 0xFFFF00
const $DLSUCCESS = 0x339966
const $opt_params2='  --embed-subs --write-auto-sub  --no-mtime --no-part --retries infinite --continue '
const $opt_sdubtitles=' --write-subs --write-auto-subs --sub-langs "de, de-orig, en, en-orig" --embed-subs  --convert-subs srt --compat-options no-keep-subs '&$opt_params2

$defaultBirate="1080|720|highest" 
$defaultBirateSelected="720"
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
$adlibpause=250

AdlibRegister("getProgress", $adlibpause)
readsettings()
GUISetOnEvent($GUI_EVENT_CLOSE, "Terminate")
GUISetState(@SW_SHOW)
GUICtrlGetState($menuOverwrieHandler)





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

func checkForCustomChannelBitrate ()

	GUICtrlSetState($input720p, $GUI_DISABLE)
	GUICtrlSetBkColor($globalLog, $DLINPROCESS)

	$url = _GUICtrlRichEdit_GetText($input720p)
	$channel=getChannelNameFromUrl($url)
	return getDLfunction($channel)
	
endfunc

func checkChannelName()
	Run(@AutoItExe & ' "' & "getChannelName.au3" & '"')
	Run("notepad.exe" & ' "' & "channelDLset.csv" & '"')
	
EndFunc

func selectBitrate ()
			
			$customDLfunc=checkForCustomChannelBitrate() 
			if $customDLfunc<>"" then
			Call($customDLfunc, true)
			return
			endif
	
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
	
func updateRecentDL($text)
	;_GUICtrlMenu_SetItemText($recentDownloadItem, 1,$text) 	
	GUICtrlSetData($recentDownloadItem, $text, "")
EndFunc
	
Func Terminate()
	_GUICtrlRichEdit_Destroy($windowmain)
	Exit
EndFunc   ;==>Terminate

Func correctURL($link)
	updateRecentDL($link)
	$link = StringReplace($link, 'https://www.youtube.com/shorts/', 'https://www.youtube.com/watch?v=')
	$link = StringReplace($link, '&list=', '&-&')
	
	if GUICtrlGetState($MenuPlaylist) then 		
			$link = StringReplace($link, '&-&', '&list=')
	EndIf 
		
	return $link
EndFunc   ;==>Terminate


func dlInHighest($customChannelBitrate=False)
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	
	if(not StringInStr($link, 'watch') and $customChannelBitrate=False ) then
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
EndFunc   

func checkNotYTProvider($link)

	if( StringInStr($link, 'odysee.com') or StringInStr($link, 'rutube.ru')  ) then
	downloadOdysee($link,"")
	return true
	else
	return false
	endif
EndFunc

func dlIn720p($customChannelBitrate=False)
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	
	if  ( checkNotYTProvider($link) ) then
	return
	endif
	
	if(not StringInStr($link, 'watch') and $customChannelBitrate=False) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)
		setReadOnly(false)
		return
	EndIf

	GUICtrlSetState($input720p, $GUI_DISABLE)
	
	
	;$params = " -f mp4 "& $opt_params2 & "  --sponsorblock-remove all -o  " &$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
	$params = " -f bestvideo[height<=720]+bestaudio --merge-output-format mp4"& $opt_params2 & "  --sponsorblock-remove all -o  " &$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		$params &= " --force-overwrites "
	EndIf
	startDL($link, $params, "")
	_GUICtrlRichEdit_SetText($input720p, "")
	GUICtrlSetState($input720p, $GUI_ENABLE)
EndFunc   ;==>dlIn720p




func dlIn1080p($customChannelBitrate=False)	
	$videotitle = "" ;
	GUICtrlSetData($globalLog, "")
	$link = correctURL(_GUICtrlRichEdit_GetText($input720p))
	; MsgBox(0, "Gefunden",  $customChannelBitrate)
     			
	
	
	if( StringInStr($link, 'odysee.com') or StringInStr($link, 'rutube.ru')  ) then
	downloadOdysee($link,"")
	return true
	endif

	if(not StringInStr($link, 'watch') and not $customChannelBitrate) then
		_GUICtrlRichEdit_SetText($input720p, "")
		loggen("Dragging pictures not supported!")
		GUICtrlSetBkColor($globalLog, $DLERROR)	
		setReadOnly(false)
		return
	EndIf

	$params = "  "&$opt_sdubtitles&" -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o  -f bv*[height<=1080][ext=mp4]+ba --merge-output-format mp4 --sponsorblock-remove all -o "&$dlpath&"\\%(title)s-%(id)s.%(ext)s" 	
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
	;yt-dlp -f "best[height<=360]" 
	;startDL($link, "  --force-overwrites  --no-mtime  --no-part   -f 18 -P home:" & $dlpath & " ", "")
	startDL($link, "  --force-overwrites  --no-mtime  --no-part  -f best[height<=480] -P home:" & $dlpath & " ", "")
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

Func downloadRutube($link,$quality)
	
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
	;GUICtrlSetData($bitrateselect, "", "")
	;GUICtrlSetData($bitrateselect, $defaultBirate, $defaultBirateSelected)
	
	EndIf 
endfunc


func getProgress()
	$procent = _StringBetween2($line, "[download]", "%", 20)	
	ConsoleWrite(@SEC& " ->" & $procent& @crlf)
	
    if $procent <> "" or  GUICtrlGetBkColor($globalLog) =  $DLSUCCESS then
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
	loggen("-------------------------")
	loggen("Download Befehl: "&@crlf& " yt-dlp.exe  " & $link & " " & $params & @crlf)
	loggen("-------------------------")
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
	

	sleep(1.5*$adlibpause)	
	GUICtrlSetBkColor($globalLog, $DLSUCCESS)
	GUICtrlSetData($progressBar, 0)
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
	If BitAnd(GUICtrlRead($menuOverwrieHandler), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($menuOverwrieHandler, $GUI_UNCHECKED)
		;WinSetTitle($windowMain, "", $title & "")
		removeFromWindowTitle(" [+R]")
		
	Else
		GUICtrlSetState($menuOverwrieHandler, $GUI_CHECKED)
		;WinSetTitle($windowMain, "", $title & " [+R]")
		addToWindowTitle(" [+R]")
	EndIf

EndFunc   ;==>overwriteClicked

func addToWindowTitle($text)
	$title = WinGetTitle($windowMain)
	WinSetTitle($windowMain, "", $title &  " "&$text)
endfunc

func removeFromWindowTitle($text)
	$title = WinGetTitle($windowMain)
	$title = stringreplace($title, $text, "")
	WinSetTitle($windowMain, "", $title )
endfunc


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

EndFunc   ;==>playlistClicked

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

Func GUICtrlGetBkColor($hWnd)
    If Not IsHWnd($hWnd) Then
        $hWnd = GUICtrlGetHandle($hWnd)
    EndIf
    Local $hDC = _WinAPI_GetDC($hWnd)
    Local $iColor = _WinAPI_GetPixel($hDC, 0, 0)
    _WinAPI_ReleaseDC($hWnd, $hDC)
    Return $iColor
EndFunc   ;==>GUICtrlGetBkColor