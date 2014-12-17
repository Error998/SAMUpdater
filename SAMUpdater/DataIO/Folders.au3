#include-once
#include <Crypt.au3>
#include <StringConstants.au3>
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
		writeLogEchoToConsole("[Info]: Using folder - " & $sPath & @CRLF)
	Else
		DirCreate($sPath)
		If @error = -1 Then
			writeLogEchoToConsole("[ERROR]: Failed to create folder - " & $sPath & @CRLF)
			Exit
		EndIf
		writeLogEchoToConsole("[Info]: Folder created - " & $sPath & @CRLF)
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
		writeLogEchoToConsole("[Info]: Deleted - " & $sPath & @CRLF)
	ElseIf FileExists($sPath) Then
		writeLogEchoToConsole("[ERROR]: Unable to delete - " & $sPath & @CRLF)
		MsgBox(48,"Unable to delete file!", "Please make sure the file or folder is not currently in use or open." & @CRLF & _
				  "Close the offending application then restart SAMUpater" & @CRLF & "Click OK to close SAMUpdater")
		Exit
    Else
        writeLogEchoToConsole("[Info]: Does not exist, consider it removed - " & $sPath & @CRLF)
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
		writeLogEchoToConsole("[Error]: Unable to get file size - " & $sPath & @CRLF)
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
;				 : If the filesize is 0 the hash will always compare - this is a crypt derp
; Related .......: Consider using _Crypt_Startup() to optimize performance of the crypt library when calling compareHash in
;				   quick succession.
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func compareHash($sPath, $bCacheHash)
	; If the file size is 0 return True by default - This is a _Crypt_HashFile derp
	If FileGetSize($sPath) = 0 Then Return True

	; Create a md5 hash of the file.
	Local $bHash = _Crypt_HashFile($sPath, $CALG_MD5)

	; Compare hash
	If $bHash = $bCacheHash Then
		Return True
	Else
		writeLog("[ERROR]: Hash does not match - " & $bCacheHash)
		writeLog("[ERROR]: File                - " & $sPath)

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
			writeLogEchoToConsole("[ERROR]: Unable to recurse folders - Error code:" & " Extended: " &  @extended & @CRLF)
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





; #FUNCTION# ====================================================================================================================
; Name ..........: getHumanReadableFilesize
; Description ...: Converts a byte filesize value into a human readable value of either B/KB/MB/GB
; Syntax ........: getHumanReadableFilesize($byte)
; Parameters ....: $byte                - filesize in bytes
; Return values .: A String with human readable filesize
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getHumanReadableFilesize($byte)
	; Return Byte
	If $byte < 1024 Then
		$byte = $byte & "B"
		Return $byte
	EndIf


	; Return KB
	If $byte < 1048576 Then
		$byte = Round($byte / 1024, 1)
		$byte = $byte & "KB"
		Return $byte
	EndIf


	; Return MB
	if $byte < 1073741824 Then
		$byte = Round($byte / 1048576,1)
		$byte = $byte & "MB"
		Return $byte
	EndIf


	; Return GB 0_0 omg u insane?
	$byte = Round($byte / 1073741824, 3)
	$byte = $byte & "GB"
	Return $byte


EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: parsePath
; Description ...: Replace special folder shortcuts with real paths
; Syntax ........: parsePath($path)
; Parameters ....: $path                - Path string to check for conversion.
; Return values .: Converted path
; Author ........: Error_998
; Modified ......:
; Remarks .......: Supports %appdata%, %desktop%, %temp%, %programfiles%, %mydocuments% - Case sensitive!
; Related .......:
; Link ..........:
; Example .......: "%appdata%\.minecraft" -> "C:\Users\User\AppData\Roaming\.minecraft"
; ===============================================================================================================================
Func parsePath($path)

	$path = StringReplace($path, "%appdata%", @AppDataDir, 0, $STR_CASESENSE)
	$path = StringReplace($path, "%desktop%", @DesktopDir, 0, $STR_CASESENSE)
	$path = StringReplace($path, "%temp%", @TempDir, 0, $STR_CASESENSE)
	$path = StringReplace($path, "%programfiles%", @ProgramFilesDir, 0, $STR_CASESENSE)
	$path = StringReplace($path, "%mydocuments%", @MyDocumentsDir, 0, $STR_CASESENSE)

	Return $path
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: createDesktopShortcut
; Description ...: Creates a desktop shortcut if none exsit or shortcut differs
; Syntax ........: createDesktopShortcut($targetPath, $linkFilename)
; Parameters ....: $targetPath          - Full path + filename to target the shortcut must link to.
;                  $linkFilename        - Shortcut filename.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: $linkFilename must be without the .lnk extention or path (desktop will be used for path)
;				   No shortcut will be created if $targetPath or $linkFilename is empty
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createDesktopShortcut($targetPath, $linkFilename)
	Local $fullLinkPath ;  Path + filename
	Local $workingDir

	; Skip if target or link filename is blank
	If $targetPath = "" Or $linkFilename = "" Then Return


	$fullLinkPath = @DesktopDir & "\" & $linkFilename & ".lnk"
	$workingDir = getPath($targetPath)


	; Check if shortcut already exist
	If FileExists($fullLinkPath) Then

		; Get shortcut details
		 Local $aDetails = FileGetShortcut($fullLinkPath)


		; Check if the shortcut actually needs updating
		If $aDetails[0] = $targetPath And $aDetails[1] = $workingDir Then Return


		; Update shortcut
		If FileCreateShortcut($targetPath, $fullLinkPath, $workingDir) Then
			writeLogEchoToConsole("[Info]: Desktop shortcut updated - " & $linkFilename & @CRLF & @CRLF)

			; Shortcut updated
			Return

		EndIf

	EndIf



	; Shortcut does not exsit, create it
	If FileCreateShortcut($targetPath, $fullLinkPath, $workingDir) Then
		writeLogEchoToConsole("[Info]: Desktop shortcut created - " & $linkFilename & @CRLF & @CRLF)
	EndIf


EndFunc