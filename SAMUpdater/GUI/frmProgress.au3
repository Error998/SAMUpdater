#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <ColorConstants.au3>
#include "..\DataIO\Folders.au3"

Global $guiUpdateTime

; #FUNCTION# ====================================================================================================================
; Name ..........: displayProgressGUI
; Description ...: Display Progress GUI
; Syntax ........: displayProgressGUI($title, $header, $totalFilesize)
; Parameters ....: $title               - Dialog Title.
;                  $header              - Dialog header.
;                  $totalFilesize       - Total filesize in bytes that must be downloaded.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func displayProgressGUI($title, $header)
	Global $frmProgressGUI
	Global $progressbarCurrent
	Global $progressbarTotal
	Global $lblCurrent
	Global $lblTotal
	Global $lblCurrentFile

	; Create GUI
	$frmProgressGUI = GUICreate($title, 386, 187, -1, -1, $DS_MODALFRAME, -1, $frmPackSelection)
	GUISetBkColor(0x343331, $frmProgressGUI)

	; Background
	GUICtrlCreatePic($datafolder & "\PackData\Assets\GUI\Progress\background.jpg", 0, 0, 386, 187)

	; Header
	GUICtrlCreateLabel($header, 20, 10, 339, 18, -1, -1)
	GUICtrlSetFont(-1,10,400,0,"Comic Sans MS")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $COLOR_WHITE)

	; Progress bars
	$progressbarCurrent = GUICtrlCreateProgress(10,59,361,20,-1,-1)
	$progressbarTotal = GUICtrlCreateProgress(10,129,361,20,-1,-1)

	GUICtrlCreateLabel("Total Progress", 20, 109, 85, 15, -1, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $COLOR_WHITE)

	$lblCurrentFile = GUICtrlCreateLabel("", 20, 39, 250, 15, -1, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $COLOR_WHITE)

	; Current progress
	$lblCurrent = GUICtrlCreateLabel("", 251, 39, 116, 15, 2, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $COLOR_WHITE)

	; Total progress
	$lblTotal = GUICtrlCreateLabel("", 237, 110, 130, 15, 2, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, $COLOR_WHITE)

	; Display GUI
	GUISetState(@SW_SHOW, $frmProgressGUI)

	; Create update time stamp
	$guiUpdateTime = TimerInit()
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: closeProgressGUI
; Description ...: Close the progress GUI
; Syntax ........: closeProgressGUI()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func closeProgressGUI()

	GUIDelete($frmProgressGUI)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: updateProgressGUI
; Description ...: Update the values for the Progress GUI
; Syntax ........: updateProgressGUI($progressTopValue, $progressTopMax,
;                  $progessBottomValue, $progressBottomMax)
; Parameters ....: $progressTopValue				- Value for the current (top) progress bar.
;                  $progressTopMax		 			- Max value of current (top) progress bar.
;                  $progressBottomValue				- Total bytes downloaded.
;                  $progressBottomMax   			- Total download size in bytes.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateProgressGUI($progressTopValue, $progressTopMax, $progressBottomValue, $progressBottomMax, $topLabel)
	Local $timeDiff

	; Top Prgress bar
	GUICtrlSetData($progressbarCurrent, Round($progressTopValue / $progressTopMax * 100))

	; Set Total Progress bar
	GUICtrlSetData($progressbarTotal, Round($progressBottomValue / $progressBottomMax * 100))


	; Skip Label updates if gui was updated in less than 250ms
	If TimerDiff($guiUpdateTime) < 250 Then Return


	; Total downloaded
	GUICtrlSetData($lblTotal, "(" & $progressBottomValue & " of " & $progressBottomMax & ")")

	; Top Label
	GUICtrlSetData($lblCurrentFile, $topLabel)

	; Top Label
	GUICtrlSetData($lblCurrent, "(" & $progressTopValue & " of " & $progressTopMax & ")")

	; Save new update time stamp
	$guiUpdateTime = TimerInit()
EndFunc