#include <GUIConstantsEx.au3>
#include <GUIListView.au3>

Global $urlsQueue[1]
Global Const $WM_DROPFILES = 0x0233 ; Konstante für WM_DROPFILES

$GUI = GUICreate("URL Queue", 400, 400)

$URLListView = GUICtrlCreateListView("URL", 10, 10, 380, 280)
_GUICtrlListView_SetExtendedListViewStyle($URLListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))

$URLInput = GUICtrlCreateInput("", 10, 290, 290, 20)
$AddButton = GUICtrlCreateButton("Add URL", 310, 290, 80, 20)

GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES")

GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $AddButton
            AddURLToList(GUICtrlRead($URLInput))
    EndSwitch
WEnd

Func AddURLToList($url)
    If $url <> "" Then
        ReDim $urlsQueue[UBound($urlsQueue) + 1]
        $urlsQueue[UBound($urlsQueue) - 1] = $url
        GUICtrlCreateListViewItem($url, $URLListView)
    EndIf
EndFunc

Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
    Local $aFile, $iCount
    $aFile = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", -1, "int", Null, "int", 0)
    $iCount = $aFile[0]
    For $i = 0 To $iCount - 1
        $aFile = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", 0, "int", 0)
        If @error Then ContinueLoop
        $sFilePath = ""
        For $j = 1 To $aFile[0] Step 2
            $aFile = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", 0, "int", 4096)
            $sFilePath &= DllStructGetData($aFile[3], 1)
        Next
        AddURLToList($sFilePath)
    Next
    DllCall("shell32.dll", "none", "DragFinish", "hwnd", $wParam)
    Return $GUI_RUNDEFMSG
EndFunc
