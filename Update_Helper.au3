#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Crypt.au3>
#include <Array.au3>
#include <File.au3>

Opt('MustDeclareVars', 1)

Local $sUpdateURL = "http://127.0.0.1/SAMUpdater/version.dat"

Func compareHash($sPath, $bCacheHash)
	; Create a md5 hash of the file.
	Local $bHash = _Crypt_HashFile($sPath, $CALG_MD5)

	; Compare hash
	If $bHash = $bCacheHash Then
		Return True
	Else
		Return False
	EndIf

EndFunc


Func downloadFile($sURL, $sPath)
	; Retry 5 times
	For $i = 1 To 5
		InetGet($sURL, $sPath, 9)
		if (@error <>  0) Then
			; All retries failed
			If $i = 5 Then
				ConsoleWrite("[ERROR]: Failed to download file retry 5 of 5 - Giving up, please check your internet connection." & @CRLF)
				Exit
			Else
				; Wait 10 seconds then retry
				ConsoleWrite("[Error]: Failed to download file retry " & $i & " of 5" & @CRLF)
				ConsoleWrite("[Info]: Retrying download in 10 seconds")
				For $x = 1 To 10
					Sleep(1000)
					ConsoleWrite(".")
				Next
				ConsoleWrite(@CRLF)
			EndIf
		Else
			; Download was successful
			ExitLoop
		EndIf
	Next

EndFunc


Func UpdateSAMUpdater()
	Local $ver

	ConsoleWrite("[Info]: Checking update file integrity" & @CRLF)

	; Sanity check to make sure a update actually exists
	If Not FileExists(@WorkingDir & "\Update.dat") Then
		ConsoleWrite("[ERROR]: Update file not found, please run SAMUpdater" & @CRLF)
		Exit
	EndIf

	downloadFile($sUpdateURL, @WorkingDir & "\version.dat")
	_FileReadToArray(@WorkingDir & "\version.dat", $ver)

	;Check Update hash
	If compareHash(@WorkingDir & "\Update.dat", $ver[3]) Then
		ConsoleWrite("[Info]: File integrity passed - Update.dat" & @CRLF)

		; Delete old file
		If FileExists(@WorkingDir & "\SAMUpdater.exe") Then
			If Not FileRecycle(@WorkingDir & "\SAMUpdater.exe") Then
				ConsoleWrite("[ERROR]: Unable to delete SAMUpdater.exe - Please remove this file manually and start Update_Helper again" & @CRLF)
				Exit
			EndIf
		EndIf

		If FileMove(@WorkingDir & "\Update.dat", @WorkingDir & "\SAMUpdater.exe") Then
			ConsoleWrite("[Info]: Update successful" & @CRLF)
			ConsoleWrite("[Info]: Now starting SAMUpdater.exe" & @CRLF)
			Run("SAMUpdater.exe", @WorkingDir)
			Exit
		Else
			ConsoleWrite("[ERROR]: Unable to apply the update to SAMUpdater.exe - Please remove SAMUpdater.exe manually and start Update_Helper again" & @CRLF)
			Exit
		EndIf
	Else
		; File corrupt
		ConsoleWrite("[ERROR]: File corrupt, integrity failed - Update.dat, please run SAMUpdater again" & @CRLF)
		Exit
	EndIf

EndFunc



; ***** Main ***********

ConsoleWrite("[Info]: Waiting for SAMUpdater to close")
For $i = 1 To 5
	ConsoleWrite(".")
	Sleep(1000)
Next
ConsoleWrite(@CRLF)


UpdateSAMUpdater()