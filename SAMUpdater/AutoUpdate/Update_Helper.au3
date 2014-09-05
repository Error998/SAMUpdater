#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.0.0.3
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)

; ### Init Varibles ###
Const $version = "0.0.0.3"
Const $updateURL = "http://localhost/samupdater/version.dat"
Local $updatePath

; #FUNCTION# ====================================================================================================================
; Name ..........: verifyUpdateFiles
; Description ...:
; Syntax ........: verifyUpdateFiles($version, $updateURL)
; Parameters ....:
; Return values .: Success				- Path to SAMUpdater.exe
;				   Failure				- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......: version.dat should be current and contain the location of SAMUpdater.exe
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func verifyUpdateFiles()
	Local $versionInfo

	ConsoleWrite("[Info]: Checking update file integrity" & @CRLF)

	; Sanity check to make sure a update actually exists
	If Not FileExists(@ScriptDir & "\Update.dat") Then
		ConsoleWrite("[ERROR]: Update file not found, please run SAMUpdater" & @CRLF)
		ConsoleWrite("[ERROR]: Is this issue persists please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox(48, "Update file not found","Could not locate Update.dat! Please run SAMUpdater again.")
		Exit
	EndIf


	_FileReadToArray(@ScriptDir & "\version.dat", $versionInfo)
	; Check if the version.dat does contain the location of SAMUpdater.exe
	If $versionInfo[0] <> 7 Then
		ConsoleWrite("[ERROR]: Could not locate the location of SAMUpdater from version.dat" & @CRLF)
		ConsoleWrite("[ERROR]: Please run SAMUpdater again." & @CRLF)
		ConsoleWrite("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox(48, "Invalid version.dat", "Please run SAMUpdater again")
		Exit
	EndIf


	; Verify the integrity of Update.dat
	If Not compareHash(@ScriptDir & "\Update.dat", $versionInfo[3]) Then
		ConsoleWrite("[ERROR]: File corrupt, integrity failed - Update.dat, please run SAMUpdater again" & @CRLF)
		ConsoleWrite("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox(48, "Invalid Update.dat", "Please run SAMUpdater again")
		Exit
	EndIf

	ConsoleWrite("[Info]: File integrity passed" & @CRLF & @CRLF)
	Return $versionInfo[7]
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateSAMUpdater
; Description ...: Verify Update.dat and version.dat, remove old SAMUpdater and install new version
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
Func UpdateSAMUpdater()
	Local $updatePath

	; Verify Update.dat and version.dat
	$updatePath = verifyUpdateFiles()


	; Delete the old SAMUpdater.exe
	removeFile($updatePath & "\SAMUpdater.exe")


	; Install the update
	If Not FileMove(@ScriptDir & "\Update.dat", $updatePath & "\SAMUpdater.exe") Then
		ConsoleWrite("[ERROR]: Unable to apply the update to SAMUpdater.exe" & @CRLF)
		ConsoleWrite("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox(48, "Unable to update SAMUpdater", "Please run SAMUpdater again")
		Exit
	EndIf

	Return $updatePath
EndFunc



; ########## Main ##########

ConsoleWrite("[Info]: Update_Helper version " & $version & @CRLF & @CRLF)
; Wait 5 seconds for SAMUpdater to close completely
ConsoleWrite("[Info]: Waiting for SAMUpdater to close")
For $i = 1 To 5
	ConsoleWrite(".")
	Sleep(1000)
Next
ConsoleWrite(@CRLF & @CRLF)


; Update SAMupdater
$updatePath = UpdateSAMUpdater()


ConsoleWrite("[Info]: Update successful" & @CRLF & @CRLF)
ConsoleWrite("[Info]: Launching SAMUpdater" & @CRLF)

Run($updatePath & "\SAMUpdater.exe", $updatePath)
Exit

