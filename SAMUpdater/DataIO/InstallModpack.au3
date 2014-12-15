#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)




; #FUNCTION# ====================================================================================================================
; Name ..........: installModPack
; Description ...: Installs files from cache to install folder and removes old files
; Syntax ........: installModPack($defaultInstallFolder, $modID, $dataFolder)
; Parameters ....: $defaultInstallFolder- Installation folder.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Will overwrite files that differ from the remote file hash
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func installModPack($defaultInstallFolder, $modID, $dataFolder)

	; Install
	installFromCache($defaultInstallFolder, $modID, $dataFolder)

	; Remove
	removeOldFiles($defaultInstallFolder, $modID, $dataFolder)

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: installFromCache
; Description ...: Installs files from cache to install folder
; Syntax ........: installModPack($defaultInstallFolder, $modID, $dataFolder)
; Parameters ....: $defaultInstallFolder- Installation folder.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Will overwrite files that differ from the remote file hash
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func installFromCache($defaultInstallFolder, $modID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Local $destinationFile
	Local $sourceFile
	Local $hash

	ConsoleWrite("[Info]: Reading files from " & $modID & ".xml" & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Files")


	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()


	For $i = 0 to UBound($currentXMLfiles) - 1

		$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]


		; Check if file already exists and if its changed
		If FileExists($destinationFile) Then
			$hash = _Crypt_HashFile($destinationFile, $CALG_MD5)

			; File is the same as remote
			If $hash = $currentXMLfiles[$i][3] Then
				ConsoleWrite("[Info]: File already installed, integrity check passed - " & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & @CRLF)

				; Skip file
				ContinueLoop

			EndIf
		EndIf


		$sourceFile = $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $currentXMLfiles[$i][3]

		; Create path and copy to installation folder
		if Not FileCopy($sourceFile, $destinationFile, 9) Then
			ConsoleWrite("[ERROR]: Unable to copy file to installation folder - " & $destinationFile & @CRLF)
			MsgBox($MB_ICONWARNING, "Error copying file to installation folder", "Unable to copy " & @CRLF & $sourceFile & @CRLF & "to" & @CRLF & $destinationFile)
			Exit
		EndIf

		ConsoleWrite("[Info}: File installed - " & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & @CRLF)

	Next

	ConsoleWrite(@CRLF)

	; Close the crypt libary to free resources
	_Crypt_Shutdown()

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: removeOldFiles
; Description ...: Delete all files marked for removal to recycle bin
; Syntax ........: removeOldFiles($defaultInstallFolder, $modID, $dataFolder)
; Parameters ....: $defaultInstallFolder- Installation folder.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: If a file can not be deleted a warning will be displayed, but the program will continue
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func removeOldFiles($defaultInstallFolder, $modID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Local $destinationFile
	Local $sourceFile


	ConsoleWrite("[Info]: Reading removed files from " & $modID & ".xml" & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")


	For $i = 0 to UBound($currentXMLfiles) - 1
		; Full path and filename of file to remove
		$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]

		; Skip if file was already removed
		If Not FileExists($destinationFile) Then
			ConsoleWrite("[Info]: File already removed - " & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & @CRLF)

			ContinueLoop
		EndIf


		; Send file to recyclebin
		If Not FileRecycle($destinationFile) Then
			; Could not delete file
			ConsoleWrite("[ERROR]: Unable to delete file - " & $destinationFile & @CRLF)
				MsgBox($MB_ICONWARNING , "Unable to delete file", "Unable to delete file: " & @CRLF & $destinationFile & @CRLF & @CRLF & "Please make sure that the file is not open or in use." & @CRLF & @CRLF& "The installation will continue but it is HIGHLY recommemded to restart the modpack installation afterwards!")

		Else
			; File deleted
			ConsoleWrite("[Info]: Successfully removed - " & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & @CRLF)
		EndIf

	Next

	ConsoleWrite("[Info]: Modpack file update complete" & @CRLF & @CRLF)
EndFunc