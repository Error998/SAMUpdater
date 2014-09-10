#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiRichEdit.au3>

Opt("GUIOnEventMode", 1)
; Number of modpack and ctrl id of the 2 buttons
Global $ctrlIDs[5][3]


#Region ### START Koda GUI section ### Form=c:\users\jock\documents\autoit\samupdater\samupdater\gui\modpack selection.kxf
$Form1_1 = GUICreate("Form1", 869, 486, 192, 124)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")





; ############ Modpack Display Right ############
$picmainPodpackPic = GUICtrlCreatePic("Splash.jpg", 456, 13, 400, 200)

$hRichEdit = _GUICtrlRichEdit_Create($Form1_1, "This a place for some decription about the modpack",456, 216, 400, 255, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
; ###############################################

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


Func addModpack($modpackNum, ByRef $ctrlIDs)
	Local $offset = $modpackNum * 100

	; Info Button
	$ctrlIDs[$modpackNum][0] =  GUICtrlCreateButton("Info", 328, 24+ $offset, 75, 25)
	GUICtrlSetOnEvent(-1, "btnInfo")

	; Download button
	$ctrlIDs[$modpackNum][1]  = GUICtrlCreateButton("Download", 328, 56+ $offset, 75, 25)
	GUICtrlSetOnEvent(-1, "btnDownload")
	ConsoleWrite(String($ctrlIDs[$modpackNum][1]) & @CRLF)

	; Border
	$ctrlIDs[$modpackNum][2] = GUICtrlCreateLabel("", 13, 13 + $offset, 401, 80, $SS_SUNKEN)
	GUICtrlSetOnEvent(-1, "ModpackClicked")

	; Icon
	GUICtrlCreatePic("Icon.jpg", 21, 21 + $offset, 64, 64)

	; Modpack Name
	GUICtrlCreateLabel("Modpack Name", 93, 21 + $offset, 223, 24)
	GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")

	; Modpack Version
	GUICtrlCreateLabel("Modpack version 1.x.x", 93, 45 + $offset, 223, 17)

	; Game Version
	GUICtrlCreateLabel("Minecraft version 1.6.4", 93, 61 + $offset, 223, 17)



EndFunc


Func ModpackClicked()
	Local $modpackNum

	$modpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 2, $ctrlIDs)

	ConsoleWrite("Display info for modpack: " & $modpackNum & @CRLF)

EndFunc



Func btnDownload()
	Local $modpackNum

	$modpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 1, $ctrlIDs)

	ConsoleWrite("Download modpack: " & $modpackNum & @CRLF)
EndFunc

Func btnInfo()
	Local $modpackNum

	$modpackNum = findModpackNumFromCtrlID(@GUI_CtrlId, 0, $ctrlIDs)

	ConsoleWrite("Display info for modpack: " & $modpackNum & @CRLF)


EndFunc


Func findModpackNumFromCtrlID($ctrlID, $controlIndex, $ctrlIDs)
	; Find the modpack number for the control that was clicked
	For $i = 0 To UBound($ctrlIDs) - 1
		If @GUI_CtrlId = $ctrlIDs[$i][$controlIndex] Then ExitLoop
	Next

	Return $i + 1
EndFunc


Func CLOSEButton()
	Exit
EndFunc


For $i =  0 to 4
	addModpack($i, $ctrlIDs)

Next

GUICtrlCreatePic("carbon.jpg", 0, 0, 869, 486)


While 1

WEnd
