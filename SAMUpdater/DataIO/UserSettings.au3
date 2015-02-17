#include-once

Opt('MustDeclareVars', 1)



; #FUNCTION# ====================================================================================================================
; Name ..........: initUserSettings
; Description ...: Create a settings.ini file to store user settings
; Syntax ........: initUserSettings($dataFolder)
; Parameters ....: $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initUserSettings($dataFolder)
	Local $file

	$file = $dataFolder & "\Settings\settings.ini"

	writeLogEchoToConsole("[Info]: Initializing user settings" & @CRLF)

	; Skip if settings.ini exists
	If FileExists($file) Then

		writeLogEchoToConsole("[Info]: User settings initialized" & @CRLF & @CRLF)
		Return

	EndIf



	; settings.ini does not exist, creating new file
	IniWrite($file, "Sound", "BackgroundMusicOn", "True")
	IniWrite($file, "Network", "Mode", "Online")

	writeLogEchoToConsole("[Info]: User settings created" & @CRLF & @CRLF)

EndFunc