#include-once
#include <INet.au3>
#include <InetConstants.au3>
#include <FTPEx.au3>

#include "Folders.au3"
Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: downloadFile
; Description ...: Download remote file and reties if it fails
; Syntax ........: downloadFile($sURL, $sPath, [$retryCount = 5])
; Parameters ....: $URL					- URL of what you want to download
;                  $path				- Full path including filename of where you want to save the downloaded file
;				   $retryCount			- Optional, how many times a failed download should be retried.  Default is 5 times
;				   $showProgress		- Optional, should progress be shown for the download. Default is false
; Return values .: Success				- True
;				   Failure				- False
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func downloadFile($URL, $path, $retryCount = 5, $showProgress = False)
	Local $errorNumber
	Local $hInetGet
	Local $spin[4] = ["-", "\", "|", "/"]
	Local $spinIndex = 0


	For $i = 1 To $retryCount
		; Download file in background
		$hInetGet = InetGet($URL, $path, BitOR($INET_FORCERELOAD, $INET_BINARYTRANSFER, $INET_FORCEBYPASS), $INET_DOWNLOADBACKGROUND)

		; Show download progress
		Do
			If $showProgress Then
				ConsoleWrite(@CR & "[Info]" & $spin[$spinIndex])

				$spinIndex += 1
				If $spinIndex = 4 Then $spinIndex = 0
			EndIf

			; Pause
			Sleep(150)

		Until InetGetInfo($hInetGet, $INET_DOWNLOADCOMPLETE)

		; Get InetGet error info
		$errorNumber = InetGetInfo($hInetGet, $INET_DOWNLOADERROR)

		; Close InetGet handle
		InetClose($hInetGet)


		if $errorNumber <>  0 Then

			; All retries failed
			If $i = $retryCount Then
				If $showProgress Then
					writeLogEchoToConsole(@CRLF & "[ERROR]: Failed to download file retry " & $retryCount & " of " & $retryCount & @CRLF)
				Else
					writeLogEchoToConsole("[ERROR]: Failed to download file retry " & $retryCount & " of " & $retryCount & @CRLF)
				EndIf
				writeLog("[ERROR]: Download error code - " & $errorNumber)
				writeLog("[ERROR]: URL                 - " & $URL)
				writeLog("[ERROR]: Path                - " & $path &  @CRLF)

				; Download failed
				Return False
			Else
				; Wait 10 seconds then retry
				If $showProgress Then
					writeLogEchoToConsole(@CRLF & "[WARNING]: Failed to download file retry " & $i & " of " & $retryCount & @CRLF)
				Else
					writeLogEchoToConsole("[WARNING]: Failed to download file retry " & $i & " of " & $retryCount & @CRLF)
				EndIf
				writeLog("[ERROR]: Download error code - " & $errorNumber)
				writeLog("[ERROR]: URL                 - " & $URL)
				writeLog("[ERROR]: Path                - " & $path & @CRLF)

				writeLogEchoToConsole("[Info]: Retrying download in 10 seconds")
				For $x = 1 To 10
					Sleep(1000)
					ConsoleWrite(".")
				Next
				writeLogEchoToConsole(@CRLF & @CRLF)

				; Reset progress spin index
				$spinIndex = 0
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
;                  $hash                - (Optional) hash to verify file integrity
;                  $retryCount          - (Optional) How many times file should be redownloaded if integrity fails
;				   $showProgress		- (Optional) Show download progress, default is false
; Return values .: Success				- True
;				   Failure				- Exit Application
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func downloadAndVerify($fileURL, $filename, $dataFolder, $hash = "", $retryCount = 5, $showProgress = False)

	For $i = 1 to $retryCount
		; Download File
		if Not downloadFile($fileURL, $dataFolder & "\" & $filename, $retryCount, $showProgress) Then
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
			writeLogEchoToConsole(@CR & "[Info]: File integrity passed - " & $filename & @CRLF)
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
;                  $hash                - Hash to verify file integrity
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

			; Trimed path to display in console
			trimPathToFitConsole(@CR & "[Info]: File integrity passed - ", $dataFolder & "\" & $filename)

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
			writeLogEchoToConsole(@CR & "[Info]: File integrity passed - " & $filename & @CRLF)
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