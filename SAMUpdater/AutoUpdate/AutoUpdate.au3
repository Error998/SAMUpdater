#include-once
#include "..\DataIO\Folders.au3"
#include "..\DataIO\Download.au3"
#include <File.au3>

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: isNewUpdateAvailable
; Description ...: Check if a new update is available
; Syntax ........: isNewUpdateAvailable($version, $updateURL)
; Parameters ....: $version          	- Version number of SAMUpdater.exe
;				   $updateURL		 	- URL of version.ini
;				   $dataFolder		 	- Application data folder
; Return values .: Update available	 	- True
;				   Update current	 	- False
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func isNewUpdateAvailable($version, $updateURL, $dataFolder)
	Local $remoteVersion

	writeLogEchoToConsole("[Info]: Checking if an update is available..." & @CRLF)
	downloadAndVerify($updateURL, "version.ini", $dataFolder)

	$remoteVersion = IniRead($dataFolder & "\version.ini", "SAMUpdater", "version", "0.0.0.0")

	If $remoteVersion > $version Then
		writeLogEchoToConsole("[Info]: New version available!" & @CRLF)
		writeLogEchoToConsole("[Info]: Current Version: " & $version & " - New Version " & $remoteVersion & @CRLF & @CRLF)
		Return True
	Else
		writeLogEchoToConsole("[Info]: Current Version: " & $version & " - No new update available" & @CRLF & @CRLF)
		Return False
	EndIf
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: updateApp
; Description ...: Downloads the new SAMUpdater.exe and Update_Helper.exe and runs Update_Helper.exe when done.
; Syntax ........: updateApp($dataFolder)
; Parameters ....: $dataFolder          - Application data folder
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: version.ini must exist
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateApp($dataFolder)
	Local $URL
	Local $hash

	; SAMUpdater
	$URL = IniRead($dataFolder & "\version.ini", "SAMUpdater", "URL", "")
	$hash = IniRead($dataFolder & "\version.ini", "SAMUpdater", "SHA1", "")

	; Download new SAMUpdater.exe and save it as update.dat
	writeLogEchoToConsole("[Info]: Downloading new updates..." & @CRLF)
	downloadAndVerify($URL, "update.dat", $dataFolder, $hash)



	;UpdaterHelper
	$URL = IniRead($dataFolder & "\version.ini", "Update_Helper", "URL", "")
	$hash = IniRead($dataFolder & "\version.ini", "Update_Helper", "SHA1", "")

	; Check if Update_Helper.exe actually needs updating
	If Not FileExists($dataFolder & "\" & "Update_Helper.exe") Then
		downloadAndVerify($URL, "Update_Helper.exe", $dataFolder, $hash)

	ElseIf Not compareHash($dataFolder & "\" & "Update_Helper.exe", $hash) Then
		downloadAndVerify($URL, "Update_Helper.exe", $dataFolder, $hash)

	EndIf





	; Launch Update_Helper.exe that will remove SAMUpdater.exe and renaming Update.dat to SAMUpdater.exe
	writeLogEchoToConsole("[Info]: New updates downloaded." & @CRLF & @CRLF)
	writeLogEchoToConsole("[Info]: Starting update procedure, launching Update_Helper..." & @CRLF & @CRLF)

	Run($dataFolder & "\Update_Helper.exe", $dataFolder)
	; Close SAMUpdater.exe to enable the update
	Exit


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: saveAppLaunchLocation
; Description ...: Save the application filename and full path in version.ini.
;				   Update_Helper will use this full path to apply the new update.
; Syntax ........: saveAppLaunchLocation($dataFolder)
; Parameters ....: $dataFolder          - Application data folder
; Return values .:
; Author ........: Error_998
; Modified ......:
; Remarks .......: version.ini key used: "LaunchingAppFullPath"
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func saveAppLaunchLocation($dataFolder)
	; Save application filename and full path
	If Not IniWrite($dataFolder & "\version.ini","SAMUpdater","LaunchingAppFullPath",@ScriptFullPath) Then
		writeLogEchoToConsole("[Warning]: Unable to save application full path to version.ini" & @CRLF)
	EndIf
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: autoUpdate
; Description ...: Checks if a new update is available, if there is then save the location of current application. Download the new
;				   updates and start Update_Helper.exe
; Syntax ........: autoUpdate($version, $updateURL, $dataFolder)
; Parameters ....: $version             - Current version of SAMUpdater
;                  $updateURL           - URL of version.dat
;                  $dataFolder          - Application data folder
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func autoUpdate($version, $updateURL, $dataFolder)

	; Skip if offline
	If Not $isOnline Then Return


	; If no update is available return
	If Not isNewUpdateAvailable($version, $updateURL, $dataFolder) Then
		Return
	EndIf

	; Save the location of SAMUpdater.exe and save it in version.ini
	saveAppLaunchLocation($dataFolder)

	; Update SAMUpdater and Update_Helper
	updateApp($dataFolder)
EndFunc