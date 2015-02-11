#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\GUI\update.ico
#AutoIt3Wrapper_Outfile=..\..\..\..\..\..\..\wamp\www\samupdater\update_helper.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=Update helper for samupdater.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.0.8
#AutoIt3Wrapper_Res_LegalCopyright=Do What The Fuck You Want To Public License, Version 2 - www.wtfpl.net
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\Folders.au3"
#include "..\DataIO\Logs.au3"
#include "..\GUI\Colors.au3"


Opt('MustDeclareVars', 1)

; ### Init Varibles ###
Const $version = "0.0.0.8"
Global $dataFolder = @AppDataDir & "\SAMUpdater"

; Initialize colors used in console window
Global $hdllKernel32 = initColors()

; Log file handle
Global $hLog = initLogs($dataFolder)

Local $updatePath

; Close the log file on application exit
OnAutoItExitRegister("closeLog")

; Set console color
setConsoleColor($FOREGROUND_Light_Green)




; #FUNCTION# ====================================================================================================================
; Name ..........: verifyUpdateFiles
; Description ...:
; Syntax ........: verifyUpdateFiles()
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

	writelogEchoToConsole("[Info]: Checking update file integrity" & @CRLF)

	; Sanity check to make sure a update actually exists
	If Not FileExists(@ScriptDir & "\update.dat") Then
		writelogEchoToConsole("[ERROR]: Update file not found, please run SAMUpdater again." & @CRLF)
		writelogEchoToConsole("[ERROR]: Is this issue persists contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Update file not found","Could not locate Update.dat! Please run SAMUpdater again.")
		Exit
	EndIf


	_FileReadToArray(@ScriptDir & "\version.dat", $versionInfo)
	; Check if the version.dat does contain the location of SAMUpdater.exe
	If $versionInfo[0] <> 7 Then
		writelogEchoToConsole("[ERROR]: Could not locate the location of SAMUpdater from version.dat" & @CRLF)
		writelogEchoToConsole("[ERROR]: Please run SAMUpdater again." & @CRLF)
		writelogEchoToConsole("[ERROR]: If the issue persist contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Invalid version.dat", "Please run SAMUpdater again")
		Exit
	EndIf


	; Verify the integrity of update.dat
	If Not compareHash(@ScriptDir & "\update.dat", $versionInfo[3]) Then
		writelogEchoToConsole("[ERROR]: File corrupt, integrity failed - Update.dat, please run SAMUpdater again" & @CRLF)
		writelogEchoToConsole("[ERROR]: If the issue persist contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Invalid update.dat", "Please run SAMUpdater again")
		Exit
	EndIf

	writelogEchoToConsole("[Info]: File integrity passed" & @CRLF & @CRLF)
	Return $versionInfo[7]
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
Func UpdateSAMUpdater()
	Local $updatePath

	; Verify Update.dat and version.dat
	$updatePath = verifyUpdateFiles()


	; Delete the old SAMUpdater.exe
	writelog("[Info]: Deleting " & $updatePath & "\SAMUpdater.exe")
	removeFile($updatePath & "\SAMUpdater.exe")


	; Install the update
	If Not FileMove(@ScriptDir & "\update.dat", $updatePath & "\SAMUpdater.exe") Then
		writelogEchoToConsole("[ERROR]: Unable to apply the update to SAMUpdater.exe" & @CRLF)
		writelogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Unable to update SAMUpdater", "Please redownload the latest SAMUpdater")
		Exit
	EndIf

	Return $updatePath
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
$updatePath = UpdateSAMUpdater()


writelogEchoToConsole("[Info]: Update successful" & @CRLF & @CRLF)
writelogEchoToConsole("[Info]: Launching SAMUpdater" & @CRLF)


Run($updatePath & "\SAMUpdater.exe", $updatePath)
Exit

