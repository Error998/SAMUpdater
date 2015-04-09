#include <MsgBoxConstants.au3>
#include "..\DataIO\UserSettings.au3"

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: getSettingIsOnline
; Description ...: Determine if the Updater should be in Online or Offline mode
; Syntax ........: getSettingIsOnline($dataFolder)
; Parameters ....: $dataFolder          - Application data folder
; Return values .: True					- Online mode (requires an internet connection)
;				   False				- Offline mode (no internet connection is needed)
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getSettingIsOnline($dataFolder)
		If getUserSettingNetworkMode($dataFolder) = "Online" Then
			Return True
		Else
			Return False
		EndIf

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: toggleNetworkMode
; Description ...: Toggle between Online and Offline mode
; Syntax ........: toggleNetworkMode()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func toggleNetworkMode()
	Local $reply

	If $isOnline Then

		$reply = MsgBox($MB_ICONQUESTION + $MB_YESNO, "Switch to Offline Mode?", "SAMUpdater is currently in Online mode" & @CRLF & @CRLF & "Would you like to switch to Offline mode?")


		; Switch to Offline mode
		If $reply = $IDYES Then
			$isOnline = False

			; Update user settings
			setUserSettingNetworkMode("Offline", $dataFolder)

			writeLogEchoToConsole("[Info]: Switched to Offline mode" & @CRLF & @CRLF)
		EndIf


	Else

		$reply = MsgBox($MB_ICONQUESTION + $MB_YESNO, "Switch to Online Mode?", "SAMUpdater is currently in Offline mode" & @CRLF & @CRLF & "Would you like to switch to Online mode?")


		; Switch to Offline mode
		If $reply = $IDYES Then
			$isOnline = True

			; Update user settings
			setUserSettingNetworkMode("Online", $dataFolder)

			writeLogEchoToConsole("[Info]: Switched to Online mode" & @CRLF & @CRLF)
		EndIf

	EndIf

EndFunc