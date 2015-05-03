#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include "..\DataIO\Folders.au3"



; #FUNCTION# ====================================================================================================================
; Name ..........: displayDownloadGUI
; Description ...: Display Download GUI
; Syntax ........: displayDownloadGUI($title, $header, $totalFilesize)
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
Func displayDownloadGUI($title, $header)
	Global $frmDownloadGUI
	Global $progressbarCurrent
	Global $progressbarTotal
	Global $lblCurrent
	Global $lblTotal
	Global $lblCurrentFile

	; Create GUI
	$frmDownloadGUI = GUICreate($title, 386, 187, -1, -1, $DS_MODALFRAME, -1)

	; Header
	GUICtrlCreateLabel($header, 20, 10, 339, 18, -1, -1)
	GUICtrlSetFont(-1,10,400,0,"Comic Sans MS")
	GUICtrlSetBkColor(-1,"-2")

	; Progress bars
	$progressbarCurrent = GUICtrlCreateProgress(10,59,361,20,-1,-1)
	$progressbarTotal = GUICtrlCreateProgress(10,129,361,20,-1,-1)

	GUICtrlCreateLabel("Total Progress", 20, 109, 85, 15, -1, -1)
	GUICtrlSetBkColor(-1,"-2")

	$lblCurrentFile = GUICtrlCreateLabel("", 20, 39, 250, 15, -1, -1)
	GUICtrlSetBkColor(-1,"-2")

	; Current bytes downloaded
	$lblCurrent = GUICtrlCreateLabel("", 251, 39, 116, 15, 2, -1)
	GUICtrlSetBkColor(-1,"-2")

	; Total bytes downloaded
	$lblTotal = GUICtrlCreateLabel("", 237, 110, 130, 15, 2, -1)
	GUICtrlSetBkColor(-1,"-2")

	; Display GUI
	GUISetState(@SW_SHOW, $frmDownloadGUI)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: closeDownloadGUI
; Description ...: Close the download GUI
; Syntax ........: closeDownloadGUI()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func closeDownloadGUI()

	GUIDelete($frmDownloadGUI)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: updateDownloadGUI
; Description ...: Update the values for the download GUI
; Syntax ........: updateDownloadGUI($currentBytesDownloaded, $currentByteFileSize,
;                  $totalBytesDownloaded, $totalByteFilesize)
; Parameters ....: $currentBytesDownloaded			- Total bytes downloaded for current file.
;                  $currentByteFileSize 			- Current filesize in bytes.
;                  $totalBytesDownloaded			- Total bytes downloaded.
;                  $totalByteFilesize   			- Total download size in bytes.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateDownloadGUI($currentBytesDownloaded, $currentByteFileSize, $currentFile, $totalBytesDownloaded, $totalByteFilesize)

	;Skip if current bytes downloaded is 0, in an attempt to keep the progress bar longer on 100%
	If $currentBytesDownloaded > 0 Then
		; Set Current Progress bar
		GUICtrlSetData($progressbarCurrent, Round($currentBytesDownloaded / $currentByteFileSize * 100))
	EndIf

	; Current File
	GUICtrlSetData($lblCurrentFile, $currentFile)

	; Current total downloaded
	GUICtrlSetData($lblCurrent, getHumanReadableFilesize($currentBytesDownloaded) & " of " & getHumanReadableFilesize($currentByteFileSize))


	; Set Total Progress bar
	GUICtrlSetData($progressbarTotal, Round($totalBytesDownloaded / $totalByteFilesize * 100))

	; Total downloaded
	GUICtrlSetData($lblTotal, getHumanReadableFilesize($totalBytesDownloaded) & " of " & getHumanReadableFilesize($totalByteFilesize))

EndFunc