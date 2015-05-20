#include-once
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiRichEdit.au3>
#include "..\DataIO\Modpack.au3"
#include "..\DataIO\InstallModpack.au3"
#include "..\DataIO\Cache.au3"
#include "frmAdvInfo.au3"
#include "frmSelectFolder.au3"
#include "GUIScrollbars_Ex.au3"

Opt("GUIOnEventMode", 1)


; Number of modpack and ctrl id of the 2 buttons and label of the modpack region
Global $ctrlIDs[5][3]

; The zero based index of the modpack to download - Used as return value
Global $downloadPacknum = -1

; Used to determine if the splash and description should be reloaded or not
Global $selectedPackNum


; #FUNCTION# ====================================================================================================================
; Name ..........: addPack
; Description ...: Add a pack to the list on the left of the GUI
; Syntax ........: addPack($packNum, Byref $ctrlIDs)
; Parameters ....: $packNum		        - Zero based index of the selected modpack to add
;                  $ctrlIDs             - [in/out] Array to hold the control ID of the clickable items
; Return values .: The (top + height) of the bottom most control, used to determine the size for the scrollable area
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func addPack($packNum, ByRef $ctrlIDs)
	; Background color of pack box
	Local $backgroundColor = 0xC0C0C0

	Local $offset = $packNum * 100
	Local $iconPath

	Local $PackID
	Local $PackName
	Local $PackVersion
	Local $ContentVersion
	Local $PackDescriptionSHA1
	Local $PackIconSHA1
	Local $PackSplashSHA1
	Local $PackDatabaseSHA1
	Local $PackConfigSHA1
	Local $PackRepository
	Local $PackDownloadable
	Local $PackVisible

	; Assign all Pack elemets
	$PackID = $packs[$packNum][0]
	$PackName = $packs[$packNum][1]
	$PackVersion = $packs[$packNum][2]
	$ContentVersion = $packs[$packNum][3]
	$PackDescriptionSHA1 = $packs[$packNum][4]
	$PackIconSHA1 = $packs[$packNum][5]
	$PackSplashSHA1 = $packs[$packNum][6]
	$PackDatabaseSHA1 = $packs[$packNum][7]
	$PackConfigSHA1 = $packs[$packNum][8]
	$PackRepository = $packs[$packNum][9]
	$PackDownloadable = $packs[$packNum][10]
	$PackVisible = $packs[$packNum][11]


	; Set Icon path
	If $PackIconSHA1 == "" Then
		$iconPath = $dataFolder & "\Packdata\Assets\GUI\Modpackselection\defaulticon.jpg"
	Else
		$iconPath = $dataFolder & "\Packdata\Modpacks\" & $PackID & "\Data\icon.jpg"
	EndIf


	; ### Create controls ####

	; Border
	$ctrlIDs[$packNum][2] = GUICtrlCreateLabel("", 13, 13 + $offset, 315, 80)
	GUICtrlSetOnEvent(-1, "PackClicked")
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Border part under buttons thats not clickable
	GUICtrlCreateLabel("", 327, 13 + $offset, 87, 80)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, $backgroundColor)

	If $PackDownloadable = "False" Then

		; Disabled Info Button
		$ctrlIDs[$packNum][0] =  GUICtrlCreateButton("Info", 328, 24 + $offset, 75, 25)
		GUICtrlSetState(-1, $GUI_DISABLE)



		; Disabled Download button
		$ctrlIDs[$packNum][1]  = GUICtrlCreateButton("Offline", 328, 56 + $offset, 75, 25)
		GUICtrlSetState(-1, $GUI_DISABLE)


	Else

		; Info Button
		$ctrlIDs[$packNum][0] =  GUICtrlCreateButton("Info", 328, 24 + $offset, 75, 25)
		GUICtrlSetOnEvent(-1, "btnInfo")


		; Download button
		If $isOnline Then
			$ctrlIDs[$packNum][1]  = GUICtrlCreateButton("Download", 328, 56 + $offset, 75, 25)
		Else
			$ctrlIDs[$packNum][1]  = GUICtrlCreateButton("Install", 328, 56 + $offset, 75, 25)
		EndIf
		GUICtrlSetOnEvent(-1, "btnDownload")


	EndIf


	; Icon
	GUICtrlCreatePic($iconPath, 21, 21 + $offset, 64, 64)

	; Heading - Pack Name
	GUICtrlCreateLabel($PackName, 93, 21 + $offset, 223, 24)
	GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Line 1 - Pack Version
	GUICtrlCreateLabel($PackVersion, 93, 45 + $offset, 223, 17)
	GUICtrlSetBkColor(-1, $backgroundColor)

	; Line 2 - Content Version
	GUICtrlCreateLabel($ContentVersion, 93, 61 + $offset, 223, 17)
	GUICtrlSetBkColor(-1, $backgroundColor)


	; Return the bottom most pixel heigh
	Return $offset + 93
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: showSplashAndDescription
; Description ...: Shows the Splach picture and the description of the selected pack
; Syntax ........: showSplashAndDescription($packNum)
; Parameters ....: $packNum          - Zero based index of the selected pack to display.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func showSplashAndDescription($packNum)
	Local $descriptionPath
	Local $splashPath

	; Assign all Pack elemets
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



	; Check if we actaully need to update anything
	If $packNum = $selectedPackNum Then
		Return
	EndIf


	; Set splash path
	If $PackSplashSHA1 == "" Then
		$splashPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	Else
		$splashPath = $dataFolder & "\Packdata\Modpacks\" & $PackID & "\Data\splash.jpg"
	EndIf

	; Set description path
	If $PackDescriptionSHA1 == "" Then
		$descriptionPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"
	Else
		$descriptionPath = $dataFolder & "\Packdata\Modpacks\" & $PackID & "\Data\description.rtf"
	EndIf


	; Update Splash
	GUICtrlSetImage($picSplash, $splashPath)

	; Update Description
	_GUICtrlRichEdit_PauseRedraw($hRichEdit)
	; Clear control text
	_GUICtrlRichEdit_SetText($hRichEdit, "")
	; Load description from file
    _GUICtrlRichEdit_StreamFromFile($hRichEdit, $descriptionPath)
	; Set scroll bar to the top
	_GUICtrlRichEdit_SetScrollPos($hRichEdit, 0, 0)
	_GUICtrlRichEdit_ResumeRedraw($hRichEdit)

	; Save the modpack num of the current displayed info
	$selectedPackNum = $packNum
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: PackClicked
; Description ...: Displays the Splash and description of the selected pack
; Syntax ........: PackClicked()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PackClicked()
	Local $packNum

	$packNum = findPackNumFromCtrlID(@GUI_CtrlId, 2, $ctrlIDs)

	; Display Splash and description
	writeLogEchoToConsole("[Info]: Displaying info for pack: " & $packNum & @CRLF)
	showSplashAndDescription($packNum)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: btnDownload
; Description ...: Download button event, set flags to close gui and save the pack num
; Syntax ........: btnDownload()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func btnDownload()
	Local $selectedPackNum

	$selectedPackNum = findPackNumFromCtrlID(@GUI_CtrlId, 1, $ctrlIDs)

	; Display Splash and description
	showSplashAndDescription($selectedPackNum)

	writeLogEchoToConsole("[Info]: Pack #: " & $selectedPackNum & " selected for download" & @CRLF)

	; Disable Parent GUI
	GUISetState(@SW_DISABLE, $frmPackSelection)
	GUISetState(@SW_DISABLE, $hAperture)


	; Display Select Folder GUI
	displaySelectFolderGUI($selectedPackNum)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: btnInfo
; Description ...: Display the AdvInfo GUI for the pack
; Syntax ........: btnInfo()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func btnInfo()
	Local $packNum

	; Caculate what pack's info should be displayed
	$packNum = findPackNumFromCtrlID(@GUI_CtrlId, 0, $ctrlIDs)

	; Disable CTRL + O Hotkey - Cant set offline mode while displaying Adv Info GUI
	HotKeySet("^o")


	; Display Splash and description
	showSplashAndDescription($packNum)


	; Disable GUI
	GUISetState(@SW_DISABLE, $frmPackSelection)
	GUISetState(@SW_DISABLE, $hAperture)


	; Display AdvInfo GUI
	displayAdvInfo($packNum)


	; Re-enable CTRL + O hotkey
	HotKeySet("^o", toggleNetworkMode)
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: CLOSEButton
; Description ...: Event that fires when the GUI is closed
; Syntax ........: CLOSEButton()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: GUI resources must be released using GUIDelete()
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func CLOSEButton()

	; Release GUI control resources
	GUIDelete($frmPackSelection)

	; Set Exit GUI loop condition
	$closeGUI = True

	writeLogEchoToConsole("[Info]: Closing Pack Selection GUI" & @CRLF & @CRLF)
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: findPackNumFromCtrlID
; Description ...: Determine the zero index based pack number of the control that was clicked
; Syntax ........: findPackNumFromCtrlID($clickedCTRLid, $controlIndex, $ctrlIDs)
; Parameters ....: $clickedCTRLid       - The id of the control that was clicked.
;                  $controlIndex        - The index specifying the button that was clicked
;                  $ctrlIDs             - The array of controlID's from the created pack list.
; Return values .: Zero based pack index
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func findPackNumFromCtrlID($clickedCTRLid, $controlIndex, $ctrlIDs)
	; Find the modpack number for the control that was clicked
	For $i = 0 To UBound($ctrlIDs) - 1
		If $clickedCTRLid = $ctrlIDs[$i][$controlIndex] Then ExitLoop
	Next

	Return $i
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: createPackSelectionGUI
; Description ...: Create and populate the Pack Selection GUI
; Syntax ........: createPackSelectionGUI()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createPackSelectionGUI()
	Local $backgroundPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\background.jpg"
	Local $splashPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	Local $descriptionPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"

	Global $frmPackSelection = GUICreate("SAMUpdater v" & $version, 869, 486)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")


	; GUI Background
	GUICtrlCreatePic($backgroundPath, 0, 0, 869, 486)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Pack Splash picture
	Global $picSplash = GUICtrlCreatePic($splashPath, 456, 13, 400, 200)

	; Pack News control
	Global $hRichEdit = _GUICtrlRichEdit_Create($frmPackSelection, "",456, 216,400, 255, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY ))


	; Show main form
	GUISetState(@SW_SHOW ,$frmPackSelection)


	; Display Splash and description from first pack
	$selectedPackNum = -1
	showSplashAndDescription(0)


	; Create the scrollable pack list
	createScrollableView()


	writeLogEchoToConsole("[Info]: Displaying Pack Selection GUI" & @CRLF)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: createScrollableView
; Description ...: Creates a transparent scrollable control group displaying the packs
; Syntax ........: createScrollableView()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Transparent color is 0xacbdef
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createScrollableView()
	Global $hAperture
	Local $iAperture_Width = 433
	Local $iAperture_Ht = 458
	Local $iLeft = 5
	Local $iTop = 13
	Local $maxVerticalScrollHeight

	; Create aperture GUI
	$hAperture = GUICreate("", $iAperture_Width, $iAperture_Ht, $iLeft, $iTop, $WS_POPUP,  BitOR($WS_EX_MDICHILD, $WS_EX_LAYERED), $frmPackSelection)

	; Set the child background to some color which we can set as the transparent color
	GUISetBkColor(0xacbdef)


	; Populate aperture controls that will be scrollable - Pack list
	For $i =  0 to UBound($packs) - 1
		$maxVerticalScrollHeight = addPack($i, $ctrlIDs)
	Next


	; Show aperture gui
	GUISetState()


	; Add vertical scrollbar if needed
	If $maxVerticalScrollHeight > 300 Then
		_GUIScrollbars_Generate($hAperture, 0, $maxVerticalScrollHeight)
	EndIf

	; Apply the trancparency for the aperture gui
	_WINAPI_SetLayeredWindowAttributes($hAperture, 0xacbdef, 255)


	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: DisplayPackSelection
; Description ...: Populate the and create the GUI controls then display it. User can select which pack to download.
; Syntax ........: DisplayPackSelection()
; Parameters ....: None
; Return values .: Zero based pack index to download
;				 : If no pack was selected to download, return  -1
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func DisplayPackSelection()
	; Varible to detect if GUI was closed
	Global $closeGUI = False

	; Create and display GUI with populated controls
	createPackSelectionGUI()


	; Create CTRL + O hotkey to toggle network mode
	HotKeySet("^o", toggleNetworkMode)


	; Main GUI message loop
	While Not $closeGUI

	WEnd


	; Remove CTRL + O Hotkey
	HotKeySet("^o")


	Return $downloadPacknum
EndFunc



