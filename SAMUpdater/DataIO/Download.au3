#include-once
#include <INet.au3>
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
	For $i = 1 To $retryCount
		InetGet($URL, $path, 9)
		if @error <>  0 Then
			; All retries failed
			If $i = $retryCount Then
				writeLogEchoToConsole("[ERROR]: Failed to download file retry " & $retryCount & " of " & $retryCount & @CRLF)
				; Download failed
				Return False
			Else
				; Wait 10 seconds then retry
				writeLogEchoToConsole("[WARNING]: Failed to download file retry " & $i & " of " & $retryCount & @CRLF)
				writeLogEchoToConsole("[Info]: Retrying download in 10 seconds")
				For $x = 1 To 10
					Sleep(1000)
					writeLogEchoToConsole(".")
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
Func downloadAndVerify($fileURL, $filename, $dataFolder, $hash = "", $retryCount = 3)

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
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $i & " of " & $retryCount & " times, restarting download" & @CRLF)
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
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $retryCount & " out of " & $retryCount & " times - " & $filename & @CRLF)
			writeLogEchoToConsole("[ERROR]: If the issue persist please contact your mod pack creator" & @CRLF & @CRLF)
			MsgBox(48, "Downloaded file integerity Failed", "Please contact your mod pack creator")
			Exit

		Else
			writeLogEchoToConsole("[ERROR]: File integrity failed " & $i & " of " & $retryCount & " times, restarting download" & @CRLF)
		EndIf
	Next

EndFunc