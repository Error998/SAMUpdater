#include-once
#include <Crypt.au3>
#include "RecFileListToArray.au3"

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
; Return values .: Failure			- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......: All parent folders will be created if they dont exsist
Func createFolder($sPath)
	If (doesFolderExist($sPath)) Then
		ConsoleWrite("[Info]: Using folder - " & $sPath & @CRLF)
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
; Return values .: Failure			- Application closes
; Author ........: Error_998
; Modified ......:
; Remarks .......: Remove the leading \ from the path to delete the folder
Func removeFile($sPath)
	If (FileRecycle($sPath) = True) Then
		ConsoleWrite("[Info]: Deleted - " & $sPath & @CRLF)
	ElseIf FileExists($sPath) Then
		ConsoleWrite("[ERROR]: Unable to delete - " & $sPath & @CRLF)
		MsgBox(48,"Unable to delete file!", "Please make sure the file or folder is not currently in use or open." & @CRLF & _
				  "Close the offending application then restart SAMUpater" & @CRLF & "Click OK to close SAMUpdater")
		Exit
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
Func getFileSize($sPath)
	Local $fSize = FileGetSize($sPath)
	if @error = -1 Then
		ConsoleWrite("[Error]: Unable to get file size - " & $sPath & @CRLF)
		Return 0
	Else
		Return $fSize
	EndIf
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: compareHash
; Description ...: Verifies a MD5 hash with a file
; Syntax ........: compareHash($sPath, $bCacheHash)
; Parameters ....: $sPath               - Path including filename of the file to be verified
;                  $bCacheHash          - MD5 hash
; Return values .: Success				- True
;				   Failure				- False
; Author ........: Error_998
; Modified ......:
; Remarks .......: File must exist
; Related .......: Consider using _Crypt_Startup() to optimize performance of the crypt library when calling compareHash in
;				   quick succession.
; Link ..........:
; Example .......: No
; ===============================================================================================================================
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



; #FUNCTION# ====================================================================================================================
; Name ..........: getFilename
; Description ...: Get just the filename from a string containing a path + filename
; Syntax ........: getFilename($sPath)
; Parameters ....: $sPath               - Full path to file.
; Return values .: filename
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getFilename($sPath)
	Local $i

	If $sPath = "" Then
		Return ""
	EndIf

	$i = StringInStr($sPath,"\", 0, -1)
	Return StringRight($sPath, (StringLen($sPath) - $i))

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: getPath
; Description ...: Get just the path from a string containing a path + filename
; Syntax ........: getPath($sPath)
; Parameters ....: $sPath               - Full path to file
; Return values .: Path of file
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getPath($sPath)
	Local $i
	Local $sLen

	$i = StringInStr($sPath,"\", 0, -1)

	Return StringLeft($sPath, $i - 1)
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: recurseFolders
; Description ...: Recurse a path returning a sorted array of path + filenames
; Syntax ........: recurseFolders($sPath[, $sExcludeFile = ""[, $sExcludeEntireFolder = ""]])
; Parameters ....: $sPath               - Path to recurse
;                  $sExcludeFile        - [optional] Any files that should be excluded from the search, seperate with ;
;                  $sExcludeEntireFolder- [optional] Any folders that should be excluded from the search, seperate with ;
; Return values .: A one dimentional array containing the path + filenames
; Author ........: Error_998
; Modified ......:
; Remarks .......: Index zero contains the number of items in the array, files start at index 1
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func recurseFolders($sPath, $sExcludeFile = "", $sExcludeEntireFolder = "")
    ; A sorted list of all files and folders with optional exclusions
	local $aFiles = _RecFileListToArray($sPath, "*|" & $sExcludeFile & "|" & $sExcludeEntireFolder, 1, 1, 1)
	if @error = 1 Then
		if @extended = 9 Then
			; Error 9 =  no files found
			; Set aFiles as an array that as 0 files in it
			Dim $aFiles[1]
			$aFiles[0] = 0
		Else
			ConsoleWrite("[ERROR]: Unable to recurse folders - Error code:" & " Extended: " &  @extended & @CRLF)
			MsgBox(48, "Error recursing folders", "Unable to recurse folders: " & @CRLF & $sPath & @CRLF & @CRLF & "Error code: " & @extended)

			; Continue app and prevent crashing when doing opperations on an array with no items
			; Set aFiles as an array that as 0 files in it
			Dim $aFiles[1]
			$aFiles[0] = 0
		EndIf

	Else
		; Sort final array if it contains files
		_ArraySort($aFiles, 0, 1)

	EndIf

	Return $aFiles
EndFunc
