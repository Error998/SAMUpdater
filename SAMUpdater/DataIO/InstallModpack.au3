#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Folders.au3"
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
	Local $recycle


	; Install
	installFromCache($defaultInstallFolder, $modID, $dataFolder)


	; Should files be permanently deleted or sent to recycle bin
	$recycle = IniRead($dataFolder & "\Settings\settings.ini", "Files", "DeleteToRecycleBin", "False")


	; Remove
	removeOldFiles($defaultInstallFolder, $modID, $dataFolder, $recycle)

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
	Local $totalFiles
	Local $fileCopyStatus

	writeLogEchoToConsole("[Info]: Reading files from " & $modID & ".xml" & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Files")


	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	$totalFiles = UBound($currentXMLfiles) - 1

	For $i = 0 to $totalFiles

		; Full filename and path to install location
		If $currentXMLfiles[$i][2] = "" Then
			$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][0]
		Else
			$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]
		EndIf

		; Check if file already exists and if its changed
		If FileExists($destinationFile) Then
			$hash = _Crypt_HashFile($destinationFile, $CALG_SHA1)

			; File is the same as remote
			If $hash = $currentXMLfiles[$i][3] Then

				trimPathToFitConsole("[Info]: (" & $i + 1 & "\" & $totalFiles + 1 & ") File already installed - ", $destinationFile)

				; Skip file
				ContinueLoop

			EndIf
		EndIf


		$sourceFile = $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $currentXMLfiles[$i][3]

		; Create path and copy to installation folder
		$fileCopyStatus = FileCopy($sourceFile, $destinationFile, BitOR($FC_OVERWRITE , $FC_CREATEPATH) )
		if $fileCopyStatus = 0 Then
			writeLogEchoToConsole("[ERROR]: Unable to copy file to installation folder - " & $destinationFile & @CRLF)
			MsgBox($MB_ICONWARNING, "Error copying file to installation folder", "Unable to copy " & @CRLF & $sourceFile & @CRLF & "to" & @CRLF & $destinationFile)
			Exit
		EndIf

		trimPathToFitConsole("[Info]: (" & $i + 1 & "\" & $totalFiles + 1 & ") File installed - ", $destinationFile)

	Next

	writeLogEchoToConsole(@CRLF)

	; Close the crypt libary to free resources
	_Crypt_Shutdown()

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: removeOldFiles
; Description ...: Delete all files marked for removal to recycle bin
; Syntax ........: removeOldFiles($defaultInstallFolder, $modID, $dataFolder, $recycle)
; Parameters ....: $defaultInstallFolder- Installation folder.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
;				   $recycle				- true send to recycle bin, false permanently delete file
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: If a file can not be deleted a warning will be displayed, but the program will continue
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func removeOldFiles($defaultInstallFolder, $modID, $dataFolder, $recycle)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Local $destinationFile
	Local $sourceFile
	Local $totalFiles


	writeLogEchoToConsole("[Info]: Reading removed files from " & $modID & ".xml" & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")


	$totalFiles = UBound($currentXMLfiles) - 1


	For $i = 0 to $totalFiles

		; Full path and filename of file to remove
		If $currentXMLfiles[$i][2] = "" Then
			$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][0]
		Else
			$destinationFile = $defaultInstallFolder & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]
		EndIf


		; Skip if file was already removed
		If Not FileExists($destinationFile) Then

			trimPathToFitConsole("[Info]: (" & $i + 1 & "\" & $totalFiles + 1 & ") File already removed - ", $destinationFile)

			ContinueLoop
		EndIf



		; Delete File
		removeFile($destinationFile, $recycle)

		; File deleted
		trimPathToFitConsole("[Info]: (" & $i + 1 & "\" & $totalFiles + 1& ") Successfully removed - ", $destinationFile)



	Next

	writeLogEchoToConsole("[Info]: Modpack file update complete" & @CRLF & @CRLF)
EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: getStatusInfoOfFilesToRemove
; Description ...: Creates an array of all files that has to be removed and is currently present in installation
; Syntax ........: getStatusInfoOfFilesToRemove($defaultInstallFolder, $modID, $dataFolder)
; Parameters ....: $defaultInstallFolder- Installation folder.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: Array of files that need to be removed
; Author ........: Error_998
; Modified ......:
; Remarks .......: Index zero  = file count
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getStatusInfoOfFilesToRemove($defaultInstallFolder, $modID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Dim $removeFiles[1]   ; All files that has to be removed and is currently present in installation
	Local $destinationFile
	Local $sourceFile
	Local $totalFiles
	Local $percentage

	writeLog("[Info]: Calculating files that needs removing..." & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")


	$totalFiles = UBound($currentXMLfiles) - 1


	For $i = 0 to $totalFiles

		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)
		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"
		ConsoleWrite(@CR & "[Info]: Calculating files that needs removing..." & $percentage)



		; Filename of file to remove
		If $currentXMLfiles[$i][2] = "" Then
			$destinationFile = $currentXMLfiles[$i][0]
		Else
			$destinationFile = $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]
		EndIf


		; Skip if file was already removed
		If Not FileExists($defaultInstallFolder & "\" & $destinationFile) Then ContinueLoop


		; Add file marked for removal that is present in current installation
		_ArrayAdd($removeFiles, $destinationFile & "#DEL")

	Next

	; Update file count in index zero
	$removeFiles[0] = UBound($removeFiles) - 1

	ConsoleWrite(@CRLF)

	Return $removeFiles
EndFunc