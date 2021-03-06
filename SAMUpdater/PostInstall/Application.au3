#include-once
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)







; #FUNCTION# ====================================================================================================================
; Name ..........: launchShortcut
; Description ...: Launches the application from the created shortcut
; Syntax ........: launchShortcut($bRun, $linkFilename)
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
Func launchShortcut($linkFilename)

	; Check if the shortcut exist
	If Not FileExists(@DesktopDir & '\' & $linkFilename & '.lnk') Then Return


	; Launch application
	writeLogEchoToConsole("[Info]: Launching application - " & $linkFilename & @CRLF & @CRLF)

	ShellExecute('"' & @DesktopDir & '\' & $linkFilename & '.lnk"', "", "", "open")

EndFunc