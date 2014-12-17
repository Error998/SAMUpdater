#include-once
#include <INet.au3>
#include <InetConstants.au3>

#include "Folders.au3"
Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: downloadFile
; Description ...: Download remote file and reties if it fails
; Syntax ........: downloadFile($sURL, $sPath, [$retryCount = 5])
; Parameters ....: $URL					- URL of what you want to download
;                  $path				- Full path including filename of where you want to save the downloaded file
;				   $retryCount			- Optional, how many times a failed download should be retried.  Default is 5 times
; Return values .: Success				- True
;				   Failure				- False
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func downloadFile($URL, $path, $retryCount = 5)
	Local $errorNumber
	For $i = 1 To $retryCount
		InetGet($URL, $path, BitOR($INET_FORCERELOAD, $INET_BINARYTRANSFER, $INET_FORCEBYPASS))
		$errorNumber = @error
		if $errorNumber <>  0 Then

			; All retries failed
			If $i = $retryCount Then
				writeLogEchoToConsole("[ERROR]: Failed to download file retry " & $retryCount & " of " & $retryCount & @CRLF)
				writeLog("[ERROR]: Download error code - " & $errorNumber)
				writeLog("[ERROR]: URL                 - " & $URL)
				writeLog("[ERROR]: Path                - " & $path &  @CRLF)

				; Download failed
				Return False
			Else
				; Wait 10 seconds then retry
				writeLogEchoToConsole("[WARNING]: Failed to download file retry " & $i & " of " & $retryCount & @CRLF)
				writeLog("[ERROR]: Download error code - " & $errorNumber)
				writeLog("[ERROR]: URL                 - " & $URL)
				writeLog("[ERROR]: Path                - " & $path & @CRLF)

				writeLogEchoToConsole("[Info]: Retrying download in 10 seconds")
				For $x = 1 To 10
					Sleep(1000)
					ConsoleWrite(".")
				Next
				writeLogEchoToConsole(@CRLF & @CRLF)
			EndIf
		Else
			; Download was successful
			Return True
		EndIf
	Next

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: downloadAndVerify
; Description ...: Downloads remote file and if a hash is supplied verifies file integrity
; Syntax ........: downloadAndVerify($fileURL, $filename, $dataFolder, [$hash = ""], [$retryCount = 3])
; Parameters ....: $fileURL             - Remote file URL to download
;                  $filename            - Filename to use for the downloaded file
;                  $dataFolder          - Application data folder
;                  $hash                - (Optional) MD5 hash to verify file integrity
;                  $retryCount          - (Optional) How many times file should be redownloaded if integrity fails
; Return values .: Success				- True
;				   Failure				- Exit Application
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func downloadAndVerify($fileURL, $filename, $dataFolder, $hash = "", $retryCount = 5)

	For $i = 1 to $retryCount
		; Download File
		if Not downloadFile($fileURL, $dataFolder & "\" & $filename) Then
			writeLogEchoToConsole("[ERROR]: Download failed - " & $filename & @CRLF)
			writeLogEchoToConsole("[ERROR]: Please check your internet connection!" & @CRLF)
			writeLogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
			MsgBox(48, "Download failed", "Please check your internet connection" & @CRLF & "Then run SAMUpdater again")
			Exit
		EndIf


		; Skip file integrity check if no hash was given
		If $hash = "" Then
			Return True
		EndIf


		; Verify hash with downloaded file
		If compareHash($dataFolder & "\" & $filename, $hash) Then
			writeLogEchoToConsole("[Info]: File integrity passed - " & $filename & @CRLF)
			Return True

		ElseIf $i = $retryCount Then
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $retryCount & " out of " & $retryCount & " times - " & $filename & @CRLF)
			writeLogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
			MsgBox(48, "Downloaded file integerity Failed", "Please contact your mod pack creator")
			Exit

		Else
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $i & " of " & $retryCount & " times" & @CRLF)

			; Removing corrupt file
			writeLog("[ERROR]: Deleting corrupt file - " & $dataFolder & "\" & $filename)
			FileRecycle($dataFolder & "\" & $filename)


			; Wait 10 seconds then restart download
			writeLogEchoToConsole("[Info]: Restarting download in 10 seconds")
			For $x = 1 To 10
				Sleep(1000)
				ConsoleWrite(".")
			Next
			writeLogEchoToConsole(@CRLF & @CRLF)


		EndIf
	Next

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: verifyAndDownload
; Description ...: Verifies is supplied hash equals local file, if not downloads remote file and verifies file integrity
; Syntax ........: verifyAndDownload($fileURL, $filename, $dataFolder, $hash = "", [$retryCount = 3])
; Parameters ....: $fileURL             - Remote file URL to download
;                  $filename            - Filename to use for the downloaded file
;                  $dataFolder          - Application data folder
;                  $hash                - MD5 hash to verify file integrity
;                  $retryCount          - (Optional) How many times file should be redownloaded if integrity fails
; Return values .: Success				- True
;				   Failure				- Exit Application
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func verifyAndDownload($fileURL, $filename, $dataFolder, $hash, $retryCount = 3)

	; Verify hash with downloaded file
	If FileExists($dataFolder & "\" & $filename) Then
		If compareHash($dataFolder & "\" & $filename, $hash) Then
			writeLogEchoToConsole("[Info]: File integrity passed - " & $filename & @CRLF)
			Return True
		EndIf
	EndIf


	For $i = 1 to $retryCount
		; Download File
		writeLogEchoToConsole("[Info]: Downloading - " & $filename & @CRLF)
		if Not downloadFile($fileURL, $dataFolder & "\" & $filename) Then
			writeLogEchoToConsole("[ERROR]: Download failed - " & $filename & @CRLF)
			writeLogEchoToConsole("[ERROR]: Please check your internet connection!" & @CRLF)
			writeLogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
			MsgBox(48, "Download failed", "Please check your internet connection" & @CRLF & "Then run SAMUpdater again")
			Exit
		EndIf


		; Verify hash with downloaded file
		If compareHash($dataFolder & "\" & $filename, $hash) Then
			writeLogEchoToConsole("[Info]: File integrity passed - " & $filename & @CRLF)
			Return True

		ElseIf $i = $retryCount Then

			; All retries failed
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $retryCount & " out of " & $retryCount & " times - " & $filename & @CRLF)
			writeLogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
			MsgBox(48, "Downloaded file integerity Failed", "Please contact your mod pack creator")
			Exit

		Else

			writeLogEchoToConsole("[ERROR]: File integrity failed " & $i & " of " & $retryCount & " times, restarting download" & @CRLF)

			; Wait 10 seconds then retry download
			writeLogEchoToConsole("[Info]: Retrying download in 10 seconds")
			For $x = 1 To 10
				Sleep(1000)
				ConsoleWrite(".")
			Next
			writeLogEchoToConsole(@CRLF & @CRLF)
		EndIf


	Next

EndFunc