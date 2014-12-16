#include-once
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)





; #FUNCTION# ====================================================================================================================
; Name ..........: initLogs
; Description ...: Open a log file
; Syntax ........: initLogs($dataFolder)
; Parameters ....: $dataFolder          - Application data folder.
; Return values .: Log file handle
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initLogs($dataFolder)
	Local $filename
	Local $hLog ; Log file handle


	$filename = $dataFolder & "\Logs\" & @YEAR & @MON & @MDAY & "-" & @HOUR & "-" & @MIN & "-" & @SEC & ".log"

	; Open Log file
	$hLog = FileOpen($filename, $FO_CREATEPATH + $FO_APPEND)

	; Check if file was opened successfully
	If $hLog = -1 Then
		ConsoleWrite("[Error]: Failed to create log file - " & $filename & @CRLF & @CRLF)
		MsgBox($MB_ICONERROR, "Failed to create log file", "Unable to create log file!" & @CRLF & $filename)
		Exit
	EndIf


	; Create a log file entry
	FileWriteLine($hLog, @HOUR & ":" & @MIN & ":" & @SEC & " [Info]: Log file created - " & $filename)


	; Return log file handle
	Return $hLog
EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: closeLog
; Description ...: Function is called when the application exits, closes log file
; Syntax ........: closeLog()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func closeLog()

	writeLog("[Info]: Closing kernel32.dll")
	DllClose($hdllKernel32)

	writeLog("[Info]: Closing application")

	; Close log file
	FileClose($hLog)

EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: writeLog
; Description ...: Adds an entry to the log file
; Syntax ........: writeLog($text)
; Parameters ....: $text                - Text to be added to log file.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func writeLog($text)

	FileWriteLine($hLog, @HOUR & ":" & @MIN & ":" & @SEC & " " & $text)

EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: writeLogEchoToConsole
; Description ...: Adds entry to log file and echo entry to console
; Syntax ........: writeLogEchoToConsole($text)
; Parameters ....: $text                - Text to write to logfile and console.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func writeLogEchoToConsole($text)

	; Write the log entry
	writeLog($text)

	; Check if a warning was used
	If StringInStr($text, "[Warning]") <> 0 Then
		; Set console color to yellow
		setConsoleColor($FOREGROUND_Light_Yellow)

		; Echo to console
		ConsoleWrite($text)

		; Set console color back to green
		setConsoleColor($FOREGROUND_Light_green)

		Return

	EndIf


	; Check if an error was used
	If StringInStr($text, "[Error]") <> 0 Then
		; Set console color to red
		setConsoleColor($FOREGROUND_Light_Red)

		; Echo to console
		ConsoleWrite($text)

		; Set console color back to green
		setConsoleColor($FOREGROUND_Light_green)

		Return
	EndIf



	; Echo to console
	ConsoleWrite($text)

EndFunc