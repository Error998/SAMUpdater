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
Func displayDownloadGUI($title, $header, $totalFilesize)
	Global $frmDownloadGUI
	Global $progressbarCurrent
	Global $progressbarTotal

	; Create GUI
	$frmDownloadGUI = GUICreate($title, 386, 187, -1, -1, $DS_MODALFRAME, -1)

	; Header
	$lblHeader = GUICtrlCreateLabel($header, 20, 10, 339, 18, -1, -1)
	GUICtrlSetFont(-1,10,400,0,"Comic Sans MS")
	GUICtrlSetBkColor(-1,"-2")

	; Progress bars
	$progressbarCurrent = GUICtrlCreateProgress(10,59,361,20,-1,-1)
	$progressbarTotal = GUICtrlCreateProgress(10,129,361,20,-1,-1)

	GUICtrlCreateLabel("Total Progress", 20, 109, 85, 15, -1, -1)
	GUICtrlSetBkColor(-1,"-2")

	GUICtrlCreateLabel("Current File Progress", 20, 39, 105, 15, -1, -1)
	GUICtrlSetBkColor(-1,"-2")

	; Current bytes downloaded
	$lblCurrent = GUICtrlCreateLabel("0B of 1234KB", 237, 39, 130, 15, 2, -1)
	GUICtrlSetBkColor(-1,"-2")

	; Total bytes downloaded
	$lblTotal = GUICtrlCreateLabel("0B of " & $totalFilesize, 237, 110, 130, 15, 2, -1)
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
Func updateDownloadGUI($currentBytesDownloaded, $currentByteFileSize, $totalBytesDownloaded, $totalByteFilesize)

	; Set Current Progress bar
	GUICtrlSetData($progressbarCurrent, Round($currentBytesDownloaded / $currentByteFileSize * 100))

	; Current Lable
	GUICtrlSetData($lblCurrent, getHumanReadableFilesize($currentBytesDownloaded) & " of " & getHumanReadableFilesize($currentByteFileSize))


	; Set Total Progress bar
	GUICtrlSetData($progressbarTotal, Round($totalBytesDownloaded / $totalByteFilesize * 100))

	; Total Lable
	GUICtrlSetData($lblTotal, getHumanReadableFilesize($totalBytesDownloaded) & " of " & getHumanReadableFilesize($totalByteFilesize))

EndFunc