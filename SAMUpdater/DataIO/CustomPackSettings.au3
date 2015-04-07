#include-once
#include <MsgBoxConstants.au3>

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: getDefaultInstallFolder
; Description ...: Get the default installation path for the pack
; Syntax ........: getDefaultInstallFolder($PackID, $dataFolder)
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
Func getDefaultInstallFolder($PackID, $dataFolder)
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
; Name ..........: getInstallFolder
; Description ...: Get the installation path for the pack
; Syntax ........: getInstallFolder($PackID, $dataFolder, $defaultInstallPath)
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
	$defaultInstallPath = getDefaultInstallFolder($PackID, $dataFolder)


	; Get the custom installation path if any, else return the defualt path
	$path = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\custom.ini", "Install", "InstallationPath", $defaultInstallPath)


	Return $path
EndFunc