#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\GUI\update.ico
#AutoIt3Wrapper_Outfile=..\..\..\..\..\..\..\wamp\www\samupdater\update_helper.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=Update helper for samupdater.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.2.0
#AutoIt3Wrapper_Res_LegalCopyright=Do What The Fuck You Want To Public License, Version 2 - www.wtfpl.net
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\Folders.au3"
#include "..\DataIO\Logs.au3"
#include "..\DataIO\UserSettings.au3"
#include "..\GUI\Colors.au3"


Opt('MustDeclareVars', 1)

; ### Init Varibles ###
Const $version = "0.0.2.0"

Global $dataFolder = @AppDataDir & "\SAMUpdater"

; Initialize colors used in console window
Global $hdllKernel32 = initColors()

; Log file handle
Global $hLog = initLogs($dataFolder)

; Close the log file on application exit
OnAutoItExitRegister("closeLog")


; Set console color
setConsoleColor($FOREGROUND_Light_Green)


; Initialize User Settings
initUserSettings($dataFolder)


Local $path




; #FUNCTION# ====================================================================================================================
; Name ..........: verifyUpdateFiles
; Description ...: Checks in update.dat exist and matches Hash.
; Syntax ........: verifyUpdateFiles($dataFolder)
; Parameters ....: $dataFolder			- Appliaction data folder
; Return values .: Success				- Path to SAMUpdater.exe
;				   Failure				- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......: version.ini should be current
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func verifyUpdateFiles($dataFolder)
	Local $path
	Local $hash

	writelogEchoToConsole("[Info]: Checking update file integrity" & @CRLF)

	; Sanity check to make sure a update actually exists
	If Not FileExists($dataFolder & "\update.dat") Then
		writelogEchoToConsole("[ERROR]: Update file not found, please run SAMUpdater again." & @CRLF)
		writelogEchoToConsole("[ERROR]: Is this issue persists contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Update file not found","Could not locate Update.dat! Please run SAMUpdater again.")
		Exit
	EndIf



	; Verify the integrity of update.dat
	$hash = IniRead($dataFolder & "\version.ini", "SAMUpdater", "SHA1", "")

	If Not compareHash($dataFolder & "\update.dat", $hash) Then
		writelogEchoToConsole("[ERROR]: File corrupt, integrity failed - update.dat" & @CRLF)
		writelogEchoToConsole("[ERROR]: Please run SAMUpdater again" & @CRLF)
		writelogEchoToConsole("[ERROR]: If the issue persist contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Invalid update.dat", "Please run SAMUpdater again")
		Exit
	EndIf

	writelogEchoToConsole("[Info]: File integrity passed" & @CRLF & @CRLF)


EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: getFullUpdatePath
; Description ...: Get the path + filename of the application that launched Updater_Helper
; Syntax ........: getFullUpdatePath($dataFolder)
; Parameters ....: $dataFolder          - Application data folder
; Return values .: Full path with filename of the launching application
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getFullUpdatePath($dataFolder)
	Local $fullPath


	$fullPath = IniRead($dataFolder & "\version.ini", "SAMUpdater", "LaunchingAppFullPath", "")
	If $fullPath = "" Then
		writelogEchoToConsole("[ERROR]: Path to Updater was not located in version.ini" & @CRLF)
		writelogEchoToConsole("[ERROR]: Please run SAMUpdater again."  & @CRLF)
		MsgBox($MB_ICONERROR, "Invalid version.ini", "Do not run Update_Helper directly, please launch SAMUpdater again.")
		Exit
	EndIf

	Return $fullPath
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateSAMUpdater
; Description ...: Verify update.dat and version.dat, remove old SAMUpdater and install new version
; Syntax ........: UpdateSAMUpdater()
; Parameters ....:
; Return values .: Success					- Returns the path to SAMUpdater.exe
; 				   Failure					- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func UpdateSAMUpdater($dataFolder)
	Local $fullPath
	Local $path
	Local $recycle

	; Verify Update.dat
	verifyUpdateFiles($dataFolder)

	; Path + Filename
	$fullPath = getFullUpdatePath($dataFolder)
	; Path Only
	$path = getPath($fullPath)

	; Delete the old SAMUpdater.exe
	trimPathToFitConsole("[Info]: Deleting ", $fullPath)


	; Read user setting (Recycle bin or permanent delete file)
	$recycle = IniRead($dataFolder & "\Settings\settings.ini", "Files", "DeleteToRecycleBin", "False")


	removeFile($fullPath, $recycle)

	; If SAMUpdater was renamed to something it will be removed above, but we have to also
	; make sure that SAMUpdater.exe does not exist else we cant update.
	If FileExists($path & "\SAMUpdater.exe") Then
		trimPathToFitConsole("[Info]: Deleting ", $path & "\SAMUpdater.exe")
		removeFile($path & "\SAMUpdater.exe", $recycle)
	EndIf


	; Install the update
	If Not FileMove($dataFolder & "\update.dat", $path & "\SAMUpdater.exe") Then
		writelogEchoToConsole("[ERROR]: Unable to apply the update to SAMUpdater.exe" & @CRLF)
		writelog("[ERROR]: Unable to move " & $dataFolder & "\update.dat to " & $path & "\SAMUpdater.exe")
		writelogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Unable to update SAMUpdater", "Please redownload the latest SAMUpdater")
		Exit
	EndIf

	Return $path
EndFunc







; ########## Main ##########
writelog("[Info]: Update_Helper launched")
writelogEchoToConsole("[Info]: Update_Helper version " & $version & @CRLF & @CRLF)

; Wait 5 seconds for SAMUpdater to close completely
writelogEchoToConsole("[Info]: Waiting 5 seconds for SAMUpdater to close")
For $i = 1 To 5
	ConsoleWrite(".")
	Sleep(1000)
Next
ConsoleWrite(@CRLF & @CRLF)


; Update SAMupdater
$path = UpdateSAMUpdater($dataFolder)


writelogEchoToConsole("[Info]: Update successful" & @CRLF & @CRLF)
writelogEchoToConsole("[Info]: Launching SAMUpdater" & @CRLF)


Run($path & "\SAMUpdater.exe", $path)
Exit

