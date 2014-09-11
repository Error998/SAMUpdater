; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.0.0.6
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <GuiListBox.au3>
#include <Timers.au3>

Local $frmSplash = GUICreate("Initializing",396,231,-1,-1,$DS_MODALFRAME,-1)
GUICtrlCreateLabel("Status",10,10,50,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
Local $lstSplash = GUICtrlCreatelist("",10,30,370,162,-1,512)



;Func LoadFormSplash()
	ConsoleWrite(@TAB & "test" & @CRLF)
	GUISetState(@SW_SHOW,$frmSplash)

;~ 	;Create Data Folder
;~ 	createFolder($sDataFolder)

;~ 	;Check for program update
;~ 	checkUpdate($sUpdateURL)

;~ 	SetStatus($lstSplash, "")

;~ 	; Download music
;~ 	getBackgroundMusic($sMusicURL)

;~ 	; Play music
;~ 	If FileExists($sDataFolder & "\PackData\Sounds\Background.mp3") Then
;~ 		SoundPlay($sDataFolder & "\PackData\Sounds\Background.mp3")
;~ 	EndIf
;~ 	; Start timer to restart music
;~ 	_Timer_SetTimer($frmSplash, 227 * 1000, "playBackgroundMusic")

;~ 	; Download and store ServerPacks.xml
;~ 	getPackXML($sPackURL)

;EndFunc
Sleep(3000)


