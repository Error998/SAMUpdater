; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <GuiListBox.au3>
#include <Timers.au3>


Local $frmSplash = GUICreate("Initializing",396,231,-1,-1,$DS_MODALFRAME,-1)
GUICtrlCreateLabel("Status",10,10,50,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
Local $lstSplash = GUICtrlCreatelist("",10,30,370,162,-1,512)


; Init Constants
Local $sPackURL = "http://127.0.0.1/SAMUpdater/packs.xml"
Local $sMusicURL = "http://127.0.0.1/SAMUpdater/Sounds/Background.mp3"
Local $sUpdateURL = "http://127.0.0.1/SAMUpdater/version.dat"


Func LoadFormSplash()
	GUISetState(@SW_SHOW,$frmSplash)

	;Check for program update
	checkUpdate($sUpdateURL)

	SetStatus($lstSplash, "")

	; Download music
	getBackgroundMusic($sMusicURL)

	; Play music
	If FileExists(@ScriptDir & "\PackData\Sounds\Background.mp3") Then
		SoundPlay(@ScriptDir & "\PackData\Sounds\Background.mp3")
	EndIf
	; Start timer to restart music
	_Timer_SetTimer($frmSplash, 227 * 1000, "playBackgroundMusic")

	; Download and store ServerPacks.xml
	getPackXML($sPackURL)

EndFunc


Func AppendStatus($controlID, $sText)
	Local $i
	; Store last item index
	$i = _GUICtrlListBox_GetCount($controlID) - 1

	_GUICtrlListBox_ReplaceString($controlID, $i, _GUICtrlListBox_GetText($controlID, $i) & $sText)
EndFunc


Func SetStatus($controlID, $sText)
	Local $i

	; Adds text to the status listbox, if its full clear the listbox and add item aggain
	$i = _GUICtrlListBox_InsertString($controlID, $sText)
	If $i = -1 Then
		_GUICtrlListBox_ResetContent($controlID)
		_GUICtrlListBox_InsertString($controlID, $sText)
	EndIf
	_GUICtrlListBox_SetCurSel($controlID, $i)
EndFunc