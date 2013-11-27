#include-once
Opt('MustDeclareVars', 1)


; #FUNCTION# ===================================================================
; Name...........: doesFolderExist($sPath)
; Description ...: Checks if a folder exists on the local machine
; Syntax.........: doesFolderExist($sPath)
; Parameters ....: Path to folder to check
; Return values .: Success - Returns True
;                  Failure - Returns False
; Author ........: Error_998
; Modified ......:
; Remarks .......:
Func doesFolderExist($sPath)

	If DirGetSize($sPath) = -1 Then
		Return False
	Else
		Return True
	EndIf
EndFunc


; #FUNCTION# ===================================================================
; Name...........: createFolder($sPath)
; Description ...: Checks if the folder exists if not creates it
; Syntax.........: createFolder($sPath)
; Parameters ....: Path to folder to create
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: App will close if the folder can not be created!
Func createFolder($sPath)
	If (doesFolderExist($sPath)) Then
		ConsoleWrite("[Info]: Using folder -  " & $sPath & @CRLF)
	Else
		DirCreate($sPath)
		If @error = -1 Then
			ConsoleWrite("[ERROR]: Failed to create folder - " & $sPath & @CRLF)
			Exit
		EndIf
		ConsoleWrite("[Info]: Folder created - " & $sPath & @CRLF)
	EndIf
EndFunc


; #FUNCTION# ===================================================================
; Name...........: removeFile($sPath)
; Description ...: Send a file or entire folder to the recycle bin
; Syntax.........: removeFile($sPath)
; Parameters ....: Path to the file or folder to delete
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Remove the leading \ from the path to delete the folder
;                  App does not close if file or folder could not be deleted
;                  This behaviour might change in the future..
Func removeFile($sPath)
	If (FileRecycle($sPath) = True) Then
		ConsoleWrite("[Info]: Deleted - " & $sPath & @CRLF)
	ElseIf FileExists($sPath) Then
		ConsoleWrite("[ERROR]: Unable to delete - " & $sPath & @CRLF)
		; Exit 0_o should we stop here or continue and hope for the best?
    Else
        ConsoleWrite("[Info]: Does not exist, consider it removed - " & $sPath & @CRLF)
	EndIf

EndFunc


; #FUNCTION# ===================================================================
; Name...........: fileSize($sPath)
; Description ...: Returns the filesize in bytes
; Syntax.........: fileSize($sPath)
; Parameters ....: Path to the file
; Return values .: Success - Returns filesize in bytes
;                  Failure - Returns 0
; Author ........: Error_998
; Modified ......:
; Remarks .......:
Func fileSize($sPath)
	Local $fSize = FileGetSize($sPath)
	if @error = -1 Then
		ConsoleWrite("[Error]: Unable to get file size - " & $sPath & @CRLF)
		Return 0
	Else
		Return $fSize
	EndIf
EndFunc


;createFolder(@AppDataDir & "\.minecraft")
;removeFile(@AppDataDir & "\.minecraft")


