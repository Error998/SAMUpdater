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

		setUserSettingBackgroundMusicOn("True", $dataFolder)
		setUserSettingNetworkMode("Online", $dataFolder)
		setUserSettingDeleteToRecycleBin("False", $dataFolder)


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



; #FUNCTION# ====================================================================================================================
; Name ..........: setUserSettingNetworkMode
; Description ...: Save the Network Mode user setting
; Syntax ........: setUserSettingNetworkMode($mode, $dataFolder)
; Parameters ....: $mode                - Online or Offline are valid.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setUserSettingNetworkMode($mode, $dataFolder)

	; Save Network Mode setting to Online
	If $mode = "Online" Then
		IniWrite($dataFolder & "\Settings\settings.ini", "Network", "Mode", "Online")

		Return
	EndIf

	; Anything else for $mode is considered Offline
	IniWrite($dataFolder & "\Settings\settings.ini", "Network", "Mode", "Offline")


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getUserSettingNetworkMode
; Description ...: Returns the Network Mode setting
; Syntax ........: getUserSettingNetworkMode($dataFolder)
; Parameters ....: $dataFolder          - Application data folder.
; Return values .: Online				- Network mode is online
;				 : Offline				- Network mode is offline (no internet access)
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getUserSettingNetworkMode($dataFolder)

	Return IniRead($dataFolder &  "\Settings\settings.ini", "Network", "Mode", "Online")

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: setUserSettingBackgroundMusicOn
; Description ...: Save the background music user setting
; Syntax ........: setUserSettingBackgroundMusicOn($boolean, $dataFolder)
; Parameters ....: $boolean             - "True" Background music is on
;				 :						- "False" Background music is off
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setUserSettingBackgroundMusicOn($boolean, $dataFolder)
	; Save user setting for the background music
	IniWrite($dataFolder &  "\Settings\settings.ini", "Sound", "BackgroundMusicOn", $boolean)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getUserSettingBackgroundMusicOn
; Description ...: Returns the background music setting
; Syntax ........: getUserSettingBackgroundMusicOn($dataFolder)
; Parameters ....: $dataFolder          - Application data folder.
; Return values .: "True"				- Background music is on
;				 : "False"				- Background music is off
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getUserSettingBackgroundMusicOn($dataFolder)

	Return IniRead($dataFolder &  "\Settings\settings.ini", "Sound", "BackgroundMusicOn", "True")

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: setUserSettingDeleteToRecycleBin
; Description ...: Save the Delete to Recycle Bin user setting
; Syntax ........: setUserSettingDeleteToRecycleBin($boolean, $dataFolder)
; Parameters ....: $boolean             - "True" All files that are deleted will be sent to recycle bin
;				 :						- "False" Files will be permanently deleted
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setUserSettingDeleteToRecycleBin($boolean,$dataFolder)
	;Save user setting for deleting files to recycle bin
	IniWrite($dataFolder &  "\Settings\settings.ini", "Files", "DeleteToRecycleBin", $boolean)

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: getUserSettingDeleteToRecycleBin
; Description ...: Returns the Delete to recycle bin user setting
; Syntax ........: getUserSettingDeleteToRecycleBin($dataFolder)
; Parameters ....: $dataFolder          - Application data folder.
; Return values .: "True"				- Files will be sent to recycle bin
;				 : "False"				- Files will be deleted permanently
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getUserSettingDeleteToRecycleBin($dataFolder)

	Return IniRead($dataFolder &  "\Settings\settings.ini", "Files", "DeleteToRecycleBin", "False")

EndFunc