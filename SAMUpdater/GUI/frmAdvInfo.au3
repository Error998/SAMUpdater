#include-once
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <GUITreeview.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <GUIImageList.au3>
#include "..\DataIO\Folders.au3"


Opt("GUIOnEventMode", 1)




; #FUNCTION# ====================================================================================================================
; Name ..........: displayAdvInfo
; Description ...: Create and populate the GUI controls then display it.
; Syntax ........: displayAdvInfo()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func displayAdvInfo($totalFileSize, $hddSpaceRequirement, $uncachedFiles)
	Global $advInfoClose = False

	; Create AdvInfo GUI
	createAdvInfo($totalFileSize, $hddSpaceRequirement, $uncachedFiles)

EndFunc




Func createAdvInfo($totalFileSize, $hddSpaceRequirement, $uncachedFiles)
	Local $iStyle = BitOR($TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS)
	Local $hParent
	Local $hChild
	Local $folder
	Local $file
	Local $prevFolder
	Local $hRoot
	Local $hImage


	GUICreate("Modpack Advanced Information", 982, 588, 192, 124, -1, -1, $frmModpackSelection)
	GUISetOnEvent($GUI_EVENT_CLOSE, "AdvInfoCLOSEButton")

	GUICtrlCreateLabel("Harddrive storage required: " & $hddSpaceRequirement, 64, 56, 200, 17)
	GUICtrlCreateLabel("Files marked for download: " & $uncachedFiles[0], 64, 80, 200, 17)
	GUICtrlCreateLabel("Download size: " & $totalFileSize, 64, 104, 200, 17)

	Local $tree = GUICtrlCreateTreeView(256, 48, 713, 481)

	$hImage = _GUIImageList_Create(16, 16, 5, 3)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 4)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 146)
	_GUIImageList_AddIcon($hImage, "shell32.dll", 131)

    _GUICtrlTreeView_SetNormalImageList($tree, $hImage)

	$hRoot = _GUICtrlTreeView_Add($tree, 0, "Installation Folder", 2, 2)

	;_GUICtrlTreeView_BeginUpdate($tree)

	For $i = 1 To $uncachedFiles[0]





		$folder = getPath($uncachedFiles[$i])
		$file = getFilename($uncachedFiles[$i])

		If $prevFolder <> $folder Then
			; Parent not found, create it
			$hParent = _GUICtrlTreeView_Add($tree, $hRoot, $folder, 0, 0)
		EndIf

		; Add file to treeview
		If StringRight($file, 4) = "#ADD" Then
			; Add
			$hChild = _GUICtrlTreeView_AddChild($tree, $hParent, StringTrimRight($file, 4), 1, 1)
		Else
			; Remove
			$hChild = _GUICtrlTreeView_AddChild($tree, $hParent, StringTrimRight($file, 4), 2, 2)
		EndIf

		$prevFolder = $folder
	Next
	_GUICtrlTreeView_Expand($tree)
	;_GUICtrlTreeView_EndEdit($tree)



	; Close button
	GUICtrlCreateButton("Close", 512, 552, 75, 25)
	GUICtrlSetOnEvent(-1, "AdvInfoCLOSEButton")



	; Close the please wait splash
	SplashOff()

	; Display GUI
	GUISetState(@SW_SHOW)



EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: AdvInfoCLOSEButton
; Description ...: Event that fires when the GUI is closed
; Syntax ........: AdvInfoCLOSEButton()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: GUI resources must be released using GUIDelete()
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func AdvInfoCLOSEButton()

	; Release GUI control resources
	GUIDelete()

	; Set Exit GUI loop condition
	$advInfoClose = True
	writeLogEchoToConsole("[Info]: Closing AdvInfo GUI" & @CRLF & @CRLF)
EndFunc

