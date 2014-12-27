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
#include "GUIScrollbars_Size.au3"

Opt("GUIOnEventMode", 1)


; Number of modpack and ctrl id of the 2 buttons and label of the modpack region
Global $ctrlIDs[5][3]

; The zero based index of the modpack to download - Used as return value
Global $downloadModpackNum = -1

; Used to determine if the splash and description should be reloaded or not
Global $selectedModpackNum


; #FUNCTION# ====================================================================================================================
; Name ..........: addModpack
; Description ...: Add a modpack to the list on the left of the GUI
; Syntax ........: addModpack($modpackNum, Byref $ctrlIDs)
; Parameters ....: $modpackNum          - Zero based index of the selected modpack to add
;                  $ctrlIDs             - [in/out] Array to hold the control ID of the clickable items
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func addModpack($modpackNum, ByRef $ctrlIDs)
	Local $offset = $modpackNum * 100
	Local $iconPath
	Local $heading
	Local $line1
	Local $line2

	; Set Icon path
	If $modpacks[$modpackNum][7] == "" Then
		$iconPath = $dataFolder & "\Packdata\Assets\GUI\Modpackselection\defaulticon.jpg"
	Else
		$iconPath = $dataFolder & "\Packdata\Modpacks\" & $modpacks[$modpackNum][0] & "\Data\icon.jpg"
	EndIf

	; Set Heading text
	$heading = $modpacks[$modpackNum][1]

	; Set Line 1 text
	$line1 = $modpacks[$modpackNum][2]

	; Set Line 2 text
	$line2 = $modpacks[$modpackNum][3]



	; ### Create controls ####

	; Border
	$ctrlIDs[$modpackNum][2] = GUICtrlCreateLabel("", 13, 13 + $offset, 315, 80)
	GUICtrlSetOnEvent(-1, "ModpackClicked")

	; Border part under buttons thats not clickable
	GUICtrlCreateLabel("", 328, 13 + $offset, 86, 80)
	GUICtrlSetState(-1, $GUI_DISABLE)


	If $modpacks[$modpackNum][12] = "False" Then

		; Disabled Info Button
		$ctrlIDs[$modpackNum][0] =  GUICtrlCreateButton("Info", 328, 24 + $offset, 75, 25)
		GUICtrlSetState(-1, $GUI_DISABLE)


		; Disabled Download button
		$ctrlIDs[$modpackNum][1]  = GUICtrlCreateButton("Offline", 328, 56 + $offset, 75, 25)
		GUICtrlSetState(-1, $GUI_DISABLE)


	Else

		; Info Button
		$ctrlIDs[$modpackNum][0] =  GUICtrlCreateButton("Info", 328, 24 + $offset, 75, 25)
		GUICtrlSetOnEvent(-1, "btnInfo")


		; Download button
		$ctrlIDs[$modpackNum][1]  = GUICtrlCreateButton("Download", 328, 56 + $offset, 75, 25)
		GUICtrlSetOnEvent(-1, "btnDownload")


	EndIf


	; Icon
	GUICtrlCreatePic($iconPath, 21, 21 + $offset, 64, 64)

	; Heading - Modpack Name
	GUICtrlCreateLabel($heading, 93, 21 + $offset, 223, 24)
	GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")

	; Line 1 - Modpack Version
	GUICtrlCreateLabel($line1, 93, 45 + $offset, 223, 17)

	; Line 2 - Game Version
	GUICtrlCreateLabel($line2, 93, 61 + $offset, 223, 17)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: showSplashAndDescription
; Description ...: Shows the Splach picture and the description of the selected modpack
; Syntax ........: showSplashAndDescription($modpackNum)
; Parameters ....: $modpackNum          - Zero based index of the selected modpack to display.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func showSplashAndDescription($modpackNum)
	Local $descriptionPath
	Local $splashPath

	; Check if we actaully need to update anything
	If $modpackNum = $selectedModpackNum Then
		Return
	EndIf


	; Set splash path
	If $modpacks[$modpackNum][9] == "" Then
		$splashPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	Else
		$splashPath = $dataFolder & "\Packdata\Modpacks\" & $modpacks[$modpackNum][0] & "\Data\splash.jpg"
	EndIf

	; Set description path
	If $modpacks[$modpackNum][5] == "" Then
		$descriptionPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"
	Else
		$descriptionPath = $dataFolder & "\Packdata\Modpacks\" & $modpacks[$modpackNum][0] & "\Data\description.rtf"
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
	$selectedModpackNum = $modpackNum
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: ModpackClicked
; Description ...: Displays the Splash and description of the selected modpack
; Syntax ........: ModpackClicked()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func ModpackClicked()
	Local $modpackNum

	$modpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 2, $ctrlIDs)

	; Display Splash and description
	writeLogEchoToConsole("[Info]: Displaying info for modpack: " & $modpackNum & @CRLF)
	showSplashAndDescription($modpackNum)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: btnDownload
; Description ...: Download button event, set flags to close gui and save the modpack num
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

	$downloadModpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 1, $ctrlIDs)

	writeLogEchoToConsole("[Info]: Modpack #: " & $downloadModpackNum & " selected for download" & @CRLF)

	; Close GUI and free resources
	CLOSEButton()
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: btnInfo
; Description ...: Display the AdvInfo GUI for the modpack
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
	Local $modpackNum

	; Caculate what modpack's info should be displayed
	$modpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 0, $ctrlIDs)


	; Display Splash and description
	showSplashAndDescription($modpackNum)



	; Display AdvInfo GUI
	displayAdvInfo($modpackNum)


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
	GUIDelete()

	; Set Exit GUI loop condition
	$closeGUI = True
	writeLogEchoToConsole("[Info]: Closing ModpackSelection GUI" & @CRLF & @CRLF)
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: findModpackNumFromCtrlID
; Description ...: Determine the zero index based modpack number of the control that was clicked
; Syntax ........: findModpackNumFromCtrlID($clickedCTRLid, $controlIndex, $ctrlIDs)
; Parameters ....: $clickedCTRLid       - The id of the control that was clicked.
;                  $controlIndex        - The index specifying the button that was clicked
;                  $ctrlIDs             - The array of controlID's from the created modpack list.
; Return values .: Zero based modpack index
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func findModpackNumFromCtrlID($clickedCTRLid, $controlIndex, $ctrlIDs)
	; Find the modpack number for the control that was clicked
	For $i = 0 To UBound($ctrlIDs) - 1
		If $clickedCTRLid = $ctrlIDs[$i][$controlIndex] Then ExitLoop
	Next

	Return $i
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: createModpackSelectionGUI
; Description ...: Create and populate the ModpackSelection GUI
; Syntax ........: createModpackSelectionGUI()
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createModpackSelectionGUI()
	Local $backgroundPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\background.jpg"
	Local $splashPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	Local $descriptionPath = $dataFolder & "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"

	Global $frmModpackSelection = GUICreate("SAMUpdater v" & $version, 869, 486, 192, 124)

	; GUI Background
	GUICtrlCreatePic($backgroundPath, 0, 0, 869, 486)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Modpack Splash picture
	Global $picSplash = GUICtrlCreatePic($splashPath, 456, 13, 400, 200)

	; Modpack News control
	Global $hRichEdit = _GUICtrlRichEdit_Create($frmModpackSelection, "",456, 216, 400, 255, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY ))


	; Populate Modpack list
	For $i =  0 to UBound($modpacks) - 1
		addModpack($i, $ctrlIDs)
	Next

	; Display Splash and description from first modpack
	$selectedModpackNum = -1
	showSplashAndDescription(0)


	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")


	writeLogEchoToConsole("[Info]: Displaying ModpackSelection GUI" & @CRLF)
	GUISetState(@SW_SHOW)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: DisplayModpackSelection
; Description ...: Populate the and create the GUI controls then display it. User can select which modpack to download.
; Syntax ........: DisplayModpackSelection()
; Parameters ....: None
; Return values .: Zero based modpack index to download
;				 : If no modpack was selected to download return  -1
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func DisplayModpackSelection()
	; Varible to detect if GUI was closed
	Global $closeGUI = False

	; Create and display GUI with populated controls
	createModpackSelectionGUI()

	; Main GUI message loop
	While Not $closeGUI

	WEnd

	Return $downloadModpackNum
EndFunc



