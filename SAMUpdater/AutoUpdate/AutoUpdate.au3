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
;				   $updateURL		 	- URL of version.dat
;				   $dataFolder		 	- Application data folder
; Return values .: Update available	 	- True
;				   Update current	 	- False
; Author ........: Error_998
; Modified ......:
; Remarks .......:version.dat must have the following data
;				  <SAMUpdater.exe version number>
;				  <SAMUpdater.exe URL>
;				  <SAMUpdater.exe Hash>
;				  <Update Helper.exe version number>
;				  <Update Helper.exe URL>
;				  <Update_Helper.exe Hash>
;				  [Path to SAMUpdater.exe saved at runtime]
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func isNewUpdateAvailable($version, $updateURL, $dataFolder)
	Local $versionInfo

	writeLogEchoToConsole("[Info]: Checking if an update is available..." & @CRLF)
	downloadAndVerify($updateURL, "version.dat", $dataFolder)

	; Read version.dat
	_FileReadToArray($dataFolder & "\version.dat", $versionInfo)

	If $versionInfo[1] > $version Then
		writeLogEchoToConsole("[Info]: New version available!" & @CRLF)
		writeLogEchoToConsole("[Info]: Current Version: " & $version & " - New Version " & $versionInfo[1] & @CRLF & @CRLF)
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
; Remarks .......: version.dat must exist
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateApp($dataFolder)
	Local $versionInfo

	; Read version.dat - file must exist
	_FileReadToArray($dataFolder & "\version.dat", $versionInfo)

	; Download new SAMUpdater.exe and save it as Update.dat
	writeLogEchoToConsole("[Info]: Downloading new updates..." & @CRLF)
	downloadAndVerify($versionInfo[2], "update.dat", $dataFolder, $versionInfo[3])


	; Check if Update_Helper.exe actually needs updating
	If Not FileExists($dataFolder & "\" & "Update_Helper.exe") Then
		downloadAndVerify($versionInfo[5], "Update_Helper.exe", $dataFolder, $versionInfo[6])

	ElseIf Not compareHash($dataFolder & "\" & "Update_Helper.exe", $versionInfo[6]) Then
		downloadAndVerify($versionInfo[5], "Update_Helper.exe", $dataFolder, $versionInfo[6])

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
; Description ...: Save the path of the current running app to version.dat. Update_Helper will use this path to apply the new
;				   update.
; Syntax ........: saveAppLaunchLocation($dataFolder)
; Parameters ....: $dataFolder          - Application data folder
; Return values .: Failure				- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func saveAppLaunchLocation($dataFolder)
	Local $file = FileOpen($dataFolder & "\version.dat", 1)

	; Check if file opened for writing OK
	If $file = -1 Then
		writeLogEchoToConsole("[ERROR]: Unable to open version.dat for writing" & @CRLF & @CRLF)
		Exit
	EndIf

	; Append location of running app's path to version.dat
	FileWrite($file, @CRLF & @ScriptDir)

	FileClose($file)
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
	Local $updateAvailable = False

	; If no update is available return
	If Not isNewUpdateAvailable($version, $updateURL, $dataFolder) Then
		Return
	EndIf

	; Save the location of SAMUpdater.exe and save it in version.dat
	saveAppLaunchLocation($dataFolder)

	; Update SAMUpdater and Update_Helper
	updateApp($dataFolder)
EndFunc