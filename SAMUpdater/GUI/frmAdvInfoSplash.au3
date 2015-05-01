#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>



; #FUNCTION# ====================================================================================================================
; Name ..........: displayAdvInfoSplash
; Description ...: Displays the AdvInfo Splash window with a progress bar
; Syntax ........: displayAdvInfoSplash($datafolder)
; Parameters ....: None
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func displayAdvInfoSplash()
	Global $frmAdvInfoSplash
	Global $progressbar

	$frmAdvInfoSplash = GUICreate("Please Wait...",380,285,-1,-1,$WS_POPUPWINDOW,$WS_EX_CLIENTEDGE)
	GUICtrlCreatePic($dataFolder & "\PackData\Assets\GUI\AdvInfo\plswaitbackground.jpg", 0, 0, 380, 285, -1, -1)
	$progressbar = GUICtrlCreateProgress(10,255,360,20,-1,-1)

	GUISetState(@SW_SHOW)
EndFunc



Func closeAdvInfoSplash()
	GUIDelete($frmAdvInfoSplash)


EndFunc



Func setAdvInfoSplashProgress($percentage)

	GUICtrlSetData($progressbar, $percentage)

EndFunc