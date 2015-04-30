#include-once
#include <MsgBoxConstants.au3>

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: getPackConfigSettingDefaultInstallFolder
; Description ...: Get the default installation path for the pack
; Syntax ........: getPackConfigSettingDefaultInstallFolder($PackID, $dataFolder)
; Parameters ....: $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: default installation path
; Author ........: Error_998
; Modified ......:
; Remarks .......: Function will replace special folder shortcuts with real paths - Example %appdata%
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getPackConfigSettingDefaultInstallFolder($PackID, $dataFolder)
	Local $defaultInstallPath

	; Read the default intallation path
	$defaultInstallPath = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\" & $PackID & ".ini", "Install", "DefaultInstallFolder", "None")


	; Sanity check - Default installation path must be set even if the client can set his own.
	If $defaultInstallPath = "None" Then
		writeLogEchoToConsole("[ERROR]: Default installation path not set - " & $PackID & ".ini" & @CRLF)
		MsgBox($MB_ICONERROR, "Default installation path not set", "Please ask your Pack creator to fix this configuration error"  & @CRLF & $PackID & ".ini - Default installation path must be set per pack entry")
		Exit
	EndIf


	; Replace special folder shortcuts with real paths
	$defaultInstallPath = parsePath($defaultInstallPath)


	Return $defaultInstallPath
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getPackConfigSettingChangeInstallationFolderAllowed
; Description ...: User is able to set a custom path for the installation or not
; Syntax ........: getPackConfigSettingChangeInstallationFolderAllowed($PackID, $dataFolder)
; Parameters ....: $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: True					- User is allowed to set a custom installation path
;				 : False				- Installation folder is locked and cant be changed
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getPackConfigSettingChangeInstallationFolderAllowed($PackID, $dataFolder)

	; Get the custom installation path if any, else return the defualt path
	Return IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\" & $PackID & ".ini", "Install", "ChangeInstallationFolderAllowed", "True")


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getInstallFolder
; Description ...: Get the installation path for the pack
; Syntax ........: getInstallFolder($PackID, $dataFolder)
; Parameters ....: $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: Path to where pack is installed
; Author ........: Error_998
; Modified ......:
; Remarks .......: If no custom install folder is set it will return the default installation folder
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getInstallFolder($PackID, $dataFolder)
	Local $path
	Local $defaultInstallPath

	; Get the default installation path
	$defaultInstallPath = getPackConfigSettingDefaultInstallFolder($PackID, $dataFolder)


	; Get the custom installation path if any, else return the default path
	$path = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\custom.ini", "Install", "InstallationPath", $defaultInstallPath)


	Return $path
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: setInstallFolder
; Description ...: Saves the installation folder if it differs from the current install folder
; Syntax ........: setInstallFolder($installationPath, $PackID, $dataFolder)
; Parameters ....: $installationPath    - Path to the new installation folder.
;                  $PackID              - The Pack ID.
;                  $dataFolder          - The Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setInstallFolder($installationPath, $PackID, $dataFolder)

	writeLog("[Info]: Using installation folder - " & $installationPath & @CRLF)

	; Skip if install path is already set
	If getInstallFolder($PackID, $dataFolder) = $installationPath Then Return


	; Save custom install folder
	IniWrite($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\custom.ini", "Install", "InstallationPath", $installationPath)
	writeLog("[Info]: Saved custom installation path in - " & $dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\custom.ini")

EndFunc