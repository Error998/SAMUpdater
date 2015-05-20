#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include "..\DataIO\CustomPackSettings.au3"
#include "..\DataIO\Folders.au3"


Opt("GUIOnEventMode", 1)




; #FUNCTION# ====================================================================================================================
; Name ..........: CloseSelectFolderGUI
; Description ...: Close the Select Folder GUI and free resources
; Syntax ........: CloseSelectFolderGUI()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Callback function of frmSelectFolderGUI close event
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func CloseSelectFolderGUI()

	writeLogEchoToConsole("[Info]: Closing Select Folder GUI" & @CRLF)
	; Close Select Folder GUI
	GUIDelete($frmSelectFolder)

	; Re-enable forms
	GUISetState(@SW_ENABLE, $frmPackSelection)
	GUISetState(@SW_ENABLE, $hAperture)
	WinActivate("SAMUpdater v" & $version)
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: btnOKSelectFolderGUI
; Description ...: Confirm installation path and save path if different from default path
; Syntax ........: btnOKSelectFolderGUI()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func btnOKSelectFolderGUI()
	Local $installationPath
	Local $defaultInstallationPath
	Local $PackID = $packs[$selectedPackNum][0]

	; Disable the parent GUI
	GUISetState(@SW_DISABLE, $frmSelectFolder)


	$installationPath = GUICtrlRead($txtFolder)


	; Remove trailing "\" from path
	If StringRight($installationPath, 1) = "\" Then
		$installationPath = StringLeft($installationPath, StringLen($installationPath) - 1)

		; Leave "\" if path is a drive root folder (Only in GUI view)
		If Not StringRight($installationPath, 1) = ":" Then
			GUICtrlSetData($txtFolder, $installationPath)
		EndIf
	EndIf


	; Check if path is valid
	If Not isPathValid($installationPath) Then
			; Enable parent GUI
			GUISetState(@SW_ENABLE, $frmSelectFolder)
			WinActivate("Select installation folder")

			Return
	EndIf


	; Save selected installation path
	setInstallFolder($installationPath, $PackID, $dataFolder)


	; Close Select Folder GUI
	CloseSelectFolderGUI()

	$closeGUI = True


	; Set the selected packID as the pack that will be downloaded
	$downloadPacknum = $selectedPackNum
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: SelectFolderDialog
; Description ...: Displays a Select Folder Dialogbox
; Syntax ........: SelectFolderDialog()
; Parameters ....:
; Return values .: Full path to selected folder
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func SelectFolderDialog()

	; Disable the parent GUI
	GUISetState(@SW_DISABLE, $frmSelectFolder)


	; Display Select Folder dialog
	Local $sFileSelectFolder = FileSelectFolder("Select installation folder", @HomeDrive)
	If @error Then
		; Enable the parent GUI
		GUISetState(@SW_ENABLE, $frmSelectFolder)
		WinActivate("Select installation folder")

		Return ""
	EndIf



	; Library was selected, change to My Documents
	If StringInStr($sFileSelectFolder, "{031E4825-7B94-4DC3-B131-E946B44C8DD5}") Then
		$sFileSelectFolder = @MyDocumentsDir
	EndIf


	; My Computer was selected, change to root of Home Drive
	If StringInStr($sFileSelectFolder, "{20D04FE0-3AEA-1069-A2D8-08002B30309D}") Then
		$sFileSelectFolder = @HomeDrive & "\"
	EndIf


	; Special folders are invalid
	If StringLeft($sFileSelectFolder, 1) = ":" Then
		MsgBox($MB_ICONWARNING, "Invalid special folder selected", "Please select a valid folder")

		; Enable the parent GUI
		GUISetState(@SW_ENABLE, $frmSelectFolder)
		WinActivate("Select installation folder")

		Return ""
	EndIf


	; Enable the parent GUI
	GUISetState(@SW_ENABLE, $frmSelectFolder)
	WinActivate("Select installation folder")


	; Return selected folder
	Return $sFileSelectFolder

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateInstallationPathTextbox
; Description ...: Open the OS Select Folder Dialogbox for the user to select an installation path
; Syntax ........: UpdateInstallationPathTextbox()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Updates the textbox field of frmSelectFolder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func UpdateInstallationPathTextbox()
	Local $sFileSelectFolder

	; Disable the parent GUI
	GUISetState(@SW_DISABLE, $frmSelectFolder)


	; Display Select Folder Dialog box
	$sFileSelectFolder = SelectFolderDialog()


	; No valid folder selected
	If $sFileSelectFolder = "" Then
		; Enable parent GUI
		GUISetState(@SW_ENABLE, $frmSelectFolder)

		Return
	EndIf


	; Update Textbox
	GUICtrlSetData($txtFolder, $sFileSelectFolder)

	; Enable parent GUI
	GUISetState(@SW_ENABLE, $frmSelectFolder)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: displaySelectFolderGUI
; Description ...: Displays the select folder GUI to select or display the pack's installation folder
; Syntax ........: displaySelectFolderGUI($packNum)
; Parameters ....: $packNum             - The pack number as index of $packs[]
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Also closes frmPackSelection on valid entry of data in frmSelectFolder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func displaySelectFolderGUI($packNum)

	; Background color of pack box
	Local $backgroundColor = 0xC0C0C0
	Local $iconPath

	Local $PackID = $packs[$packNum][0]
	Local $PackName = $packs[$packNum][1]
	Local $PackVersion = $packs[$packNum][2]
	Local $ContentVersion = $packs[$packNum][3]
	Local $PackDescriptionSHA1 = $packs[$packNum][4]
	Local $PackIconSHA1 = $packs[$packNum][5]
	Local $PackSplashSHA1 = $packs[$packNum][6]
	Local $PackDatabaseSHA1 = $packs[$packNum][7]
	Local $PackConfigSHA1 = $packs[$packNum][8]
	Local $PackRepository = $packs[$packNum][9]
	Local $PackDownloadable = $packs[$packNum][10]
	Local $PackVisible = $packs[$packNum][11]

	Local $installationPath
	Local $isCustomInstallationPathAllowed
	Global $txtFolder
	Global $frmSelectFolder


	; Disable parent windows
	GUISetState(@SW_DISABLE, $frmPackSelection)
	GUISetState(@SW_DISABLE, $hAperture)


	; Get Installation path
	$installationPath = getInstallFolder($PackID, $dataFolder)


	; Is custom installation folder allowed
	$isCustomInstallationPathAllowed = getPackConfigSettingChangeInstallationFolderAllowed($PackID, $dataFolder)


	; Set Icon path
	If $PackIconSHA1 == "" Then
		$iconPath = $dataFolder & "\Packdata\Assets\GUI\Modpackselection\defaulticon.jpg"
	Else
		$iconPath = $dataFolder & "\Packdata\Modpacks\" & $PackID & "\Data\icon.jpg"
	EndIf




	; Create Select Folder GUI
	$frmSelectFolder = GUICreate("Select installation folder",402,209,-1,-1, $DS_MODALFRAME, $WS_EX_DLGMODALFRAME, $frmPackSelection)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CloseSelectFolderGUI")
	GUISetBkColor(0xF0F0F0)



	; ### Create controls ####

	; Border
	GUICtrlCreateLabel("", 0, 0, 402, 82)
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Icon
	GUICtrlCreatePic($iconPath, 8, 8, 64, 64)

	; Heading - Pack Name
	GUICtrlCreateLabel($PackName, 80, 21, 223, 24)
	GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Line 1 - Pack Version
	GUICtrlCreateLabel($PackVersion, 80, 45, 223, 17)
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Line 2 - Content Version
	GUICtrlCreateLabel($ContentVersion, 80, 61, 223, 17)
	GUICtrlSetBkColor(-1, $backgroundColor)



	; Disable control if Custom Path is not allowed
	If $isCustomInstallationPathAllowed = "False" Then
		GUICtrlCreateLabel("The following installation folder will be used:",10,95,318,15,-1,-1)
		GUICtrlSetBkColor(-1,"-2")

		$txtFolder = GUICtrlCreateInput($installationPath,10,110,348,20,-1,512)
		GUICtrlSetState(-1, $GUI_DISABLE)

		GUICtrlCreateButton("...",362,110,33,20,-1,-1)
		GUICtrlSetState(-1, $GUI_DISABLE)

	; Custom Path is allowed
	Else
		GUICtrlCreateLabel("Select installation folder",10,95,118,15,-1,-1)
		GUICtrlSetBkColor(-1,"-2")

		$txtFolder = GUICtrlCreateInput($installationPath,10,110,348,20,-1,512)

		GUICtrlCreateButton("...",362,110,33,20,-1,-1)
		GUICtrlSetOnEvent(-1, "UpdateInstallationPathTextbox")

	EndIf




	GUICtrlCreateButton("OK",68,145,100,30,-1,-1)
	GUICtrlSetOnEvent(-1, "btnOKSelectFolderGUI")

	GUICtrlCreateButton("Cancel",227,145,100,30,-1,-1)
	GUICtrlSetOnEvent(-1, "CloseSelectFolderGUI")

	GUISetState(@SW_SHOW)

	writeLogEchoToConsole("[Info]: Displaying Select Folder GUI" & @CRLF)


EndFunc