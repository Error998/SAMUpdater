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

	; Create settings file
	If Not FileExists($file) Then

		IniWrite($file, "Sound", "BackgroundMusicOn", "True")
		IniWrite($file, "Network", "Mode", "Online")
		IniWrite($file, "Files", "DeleteToRecycleBin", "False")


		writeLogEchoToConsole("[Info]: User settings created and initialized" & @CRLF & @CRLF)
		Return

	EndIf


	checkUserSetting($file, "Sound", "BackgroundMusicOn", "True")
	checkUserSetting($file, "Network", "Mode", "Online")
	checkUserSetting($file, "Files", "DeleteToRecycleBin", "False")



	writeLogEchoToConsole("[Info]: User settings initialized" & @CRLF & @CRLF)

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: checkUserSetting
; Description ...: Checks user setting file and creates the section and keys that are missing
; Syntax ........: checkUserSetting($file, $section, $key, $default)
; Parameters ....: $file                - Full path and filename to user settings.
;                  $section             - Section of the key value pair.
;                  $key                 - Key within the section to check.
;                  $default             - The default value for a key that will be used if the key does not exist.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func checkUserSetting($file, $section, $key, $default)
	Local $testValue

	; Read the value of Key
	$testValue = IniRead($file, $section, $key, "dummy_value")


	; If the Key does not exist it will return "dummy_value" so we need to create the Key
	If $testValue = "dummy_value" Then
		IniWrite($file, $section, $key, $default)
		writeLog("[Info]: Created Key '" & $key & "' in section [" & $section & "] with default value of '" & $default & "'")
	EndIf

EndFunc