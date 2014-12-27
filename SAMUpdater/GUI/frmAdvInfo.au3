#include-once
#include <GUIImageList.au3>
#include <GUITreeview.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
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
Func displayAdvInfo($modpackNum)
	Local $totalFileSize = 0
	Local $hddSpaceRequirement
	Local $uncachedFiles
	Local $removeFiles
	Local $modID = $modpacks[$modpackNum][0]
	Local $numberOfUncachedFiles


	; Skip if the AdvInfo window is already open
	WinGetHandle("Modpack Advanced Information")
	If @error = 0 Then Return



	; Display Please Wait splash screen
	SplashImageOn("Please wait...", $dataFolder & "\PackData\Assets\GUI\AdvInfo\plswaitbackground.jpg", 380, 285)



	; Get data to be displayed
	getModpackAdvInfo($modID, $hddSpaceRequirement, $uncachedFiles, $totalFileSize, $removeFiles)



	writeLogEchoToConsole("[Info]: Updating " & $uncachedFiles[0] & " file(s), total download size: " & $totalFileSize & @CRLF)
	writeLogEchoToConsole("[Info]: Installed modpack will use: " & $hddSpaceRequirement & " harddrive space." & @CRLF & @CRLF)
	writeLogEchoToConsole("[Info]: Displaying AdvInfoGUI" & @CRLF & @CRLF)




	; If the local cache is up to date and no files need to be removed, only display a msgbox with minimal info
	If $uncachedFiles[0] = 0 And $removeFiles[0] = 0 Then
		; Turn off the splash
		SplashOff()

		MsgBox($MB_ICONINFORMATION, "Local cache is up to date", "Modpack is already cached locally, nothing new to download or remove." & @CRLF & @CRLF & "   Click Download if you wish to reinstall the modpack." & @CRLF & @CRLF & @CRLF & "   Installed modpack will use: " & $hddSpaceRequirement & " harddrive space.")

		Return
	EndIf


	$numberOfUncachedFiles = $uncachedFiles[0]

	; Add files marked for removal and re-sort the combined array
	_ArrayConcatenate($uncachedFiles, $removeFiles, 1)
	_ArraySort($uncachedFiles, 0, 1)

	; Set file count in combined array
	$uncachedFiles[0] = UBound($uncachedFiles) - 1




	; Create AdvInfo GUI
	createAdvInfo($totalFileSize, $hddSpaceRequirement, $numberOfUncachedFiles,  $uncachedFiles, $modpacks[$modpackNum][13])


EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: getModpackAdvInfo
; Description ...: Generate data for AdvInfo GUI - Storage requiements, uncached files, download fileze and files to be removed
; Syntax ........: getModpackAdvInfo($modID, Byref $hddSpaceRequirement, Byref $uncachedFiles, Byref $totalFileSize,
;                  Byref $removeFiles)
; Parameters ....: $modID               - The modID.
;                  $hddSpaceRequirement - [in/out] Total storage space requirement for the modpack.
;                  $uncachedFiles       - [in/out] All files that still need to be cached.
;                  $totalFileSize       - [in/out] The total download size.
;                  $removeFiles         - [in/out] All files that will be removed from the local installation.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getModpackAdvInfo($modID, ByRef $hddSpaceRequirement, ByRef $uncachedFiles, ByRef $totalFileSize, ByRef $removeFiles)

	; Generate Advanced info
	writeLogEchoToConsole("[Info]: Generating advanced info for modpack: " & $modID & @CRLF & @CRLF)



	; Calculate modpack storage requirement
	$hddSpaceRequirement = getTotalDiskspaceRequirementFromModpackXML($modID, $dataFolder)
	$hddSpaceRequirement = getHumanReadableFilesize($hddSpaceRequirement)



	; Calculate uncached files + filesize
	$uncachedFiles = getStatusInfoOfUncachedFiles($modID, $dataFolder, $totalFileSize)



	; User friendly total download size
	$totalFileSize = getHumanReadableFilesize($totalFileSize)



	; Caculate all files that will be removed
	$removeFiles = getStatusInfoOfFilesToRemove($modpacks[$modpackNum][13], $modID, $dataFolder)



EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: createAdvInfo
; Description ...: Display the AdvInfo GUI
; Syntax ........: createAdvInfo($totalFileSize, $hddSpaceRequirement, $numberOfUncachedFiles, $files, $defaultInstallFolder)
; Parameters ....: $totalFileSize       	- Total filesize to be downloaded.
;                  $hddSpaceRequirement 	- Modpack storage requirement.
;				   $uncachedFileCount		- Total number of files that will be downloaded
;                  $files       			- Combined files that will be added and removed.
;                  $defaultInstallFolder	- Modpack installation folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: $files stores an array of path+filenames+ #ADD or #DEL tags to show uncached or files to remove
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createAdvInfo($totalFileSize, $hddSpaceRequirement, $numberOfUncachedFiles, $files, $defaultInstallFolder)
	Local $backgroundPath = $dataFolder & "\PackData\Assets\GUI\AdvInfo\background.jpg"
	Local $hParent
	Local $hChild
	Local $folder
	Local $file
	Local $prevFolder
	Local $hRoot
	Local $hImage

	; From
	GUICreate("Modpack Advanced Information", 854, 449, 192, 124, -1, -1, $frmModpackSelection)
	GUISetOnEvent($GUI_EVENT_CLOSE, "AdvInfoCLOSEButton")

	; Background picture
	GUICtrlCreatePic($backgroundPath, 0, 0, 854, 449)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Lable Group
	GUICtrlCreateLabel("", 16, 24, 193, 103)

		; Storage Requirements
		GUICtrlCreateLabel("Harddrive storage required: " & $hddSpaceRequirement, 22, 43, 185, 17)

		; Number of files to download
		GUICtrlCreateLabel("Files marked for download: " & $numberOfUncachedFiles, 22, 67, 185, 17)

		; Download size
		GUICtrlCreateLabel("Download size: " & $totalFileSize, 22, 91, 185, 17)
	; End of group


	; Close button
	GUICtrlCreateButton("Close", 501, 408, 74, 25)
	GUICtrlSetOnEvent(-1, "AdvInfoCLOSEButton")



	; Treeview
	Local $tree = GUICtrlCreateTreeView(232, 24, 601, 369, $TVS_NOSCROLL)

	; Icons used for the treeview
	$hImage = _GUIImageList_Create(16, 16, 5, 3)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 4)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 146)
	_GUIImageList_AddIcon($hImage, "shell32.dll", 131)
    _GUICtrlTreeView_SetNormalImageList($tree, $hImage)


	; Root entry displaying Installation path
	$hRoot = _GUICtrlTreeView_Add($tree, 0, $defaultInstallFolder, 0, 0)


	For $i = 1 To $files[0]

		; Split the path and filename
		$folder = getPath($files[$i])
		$file = getFilename($files[$i])


		; Create a new parent node if its different than previous parent node
		If $prevFolder <> $folder Then
			$hParent = _GUICtrlTreeView_AddChild($tree, $hRoot, $folder, 0, 0)
		EndIf


		; Add modpack root files to root tree node
		If $folder = "" Then $hParent = $hRoot


		; Add file entry to treeview
		If StringRight($file, 4) = "#ADD" Then
			; Add
			$hChild = _GUICtrlTreeView_AddChild($tree, $hParent, StringTrimRight($file, 4), 1, 1)
		Else
			; Remove
			$hChild = _GUICtrlTreeView_AddChild($tree, $hParent, StringTrimRight($file, 4), 2, 2)
		EndIf


		$prevFolder = $folder


	Next

	; Expand the entire treeview
	_GUICtrlTreeView_Expand($tree)

	; Set treeview style after the expand to prevent horisontal scrolling
	GUICtrlSetStyle($tree, BitOR($TVS_HASLINES,$TVS_DISABLEDRAGDROP,$TVS_SHOWSELALWAYS,$WS_BORDER))

	; Close the please wait splash
	SplashOff()


	; Display AdvInfo GUI
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

	writeLogEchoToConsole("[Info]: Closing AdvInfo GUI" & @CRLF & @CRLF)
EndFunc

