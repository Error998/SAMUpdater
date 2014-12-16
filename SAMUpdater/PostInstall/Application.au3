#include-once
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)







; #FUNCTION# ====================================================================================================================
; Name ..........: lauchShortcut
; Description ...: Launches the application from the created shortcut
; Syntax ........: lauchShortcut($bRun, $linkFilename)
; Parameters ....: $bRun                - Boolean value, should the application be run or not.
;                  $linkFilename        - The filename of the shortcut with out the extention.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func lauchShortcut($bRun, $linkFilename)

	; Check if the shortcut exist
	If Not FileExists(@DesktopDir & '\' & $linkFilename & '.lnk') Then Return


	; Launch application
	If $bRun = "True" Then
		ConsoleWrite("[Info]: Launching application - " & $linkFilename & @CRLF & @CRLF)

		ShellExecute('"' & @DesktopDir & '\' & $linkFilename & '.lnk"', "", "", "open")

	EndIf

EndFunc