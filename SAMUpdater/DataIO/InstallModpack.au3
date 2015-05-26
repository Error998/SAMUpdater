#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Folders.au3"
#include "..\DataIO\Download.au3"
#include "..\DataIO\UserSettings.au3"
#include "..\GUI\frmProgress.au3"


Opt('MustDeclareVars', 1)




; #FUNCTION# ====================================================================================================================
; Name ..........: installPack
; Description ...: Installs files from cache to install folder and removes old files
; Syntax ........: installPack($PackID, $dataFolder)
; Parameters ....: $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Will overwrite files that differ from the remote file hash
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func installPack($PackID, $dataFolder)
	Local $recycle
	Local $installationFolder
	Local $totalFiles
	Dim $removedXMLfiles


	; Get the Pack installation folder
	$installationFolder = getInstallFolder($PackID, $dataFolder)

	; Get the removed files
	writeLogEchoToConsole("[Info]: Reading removed files from " & $PackID & ".xml" & @CRLF)
	$removedXMLfiles = getXMLfilesFromSection($PackID, $dataFolder, "Removed")
	$totalFiles = UBound($PackXMLDatabaseCurrentFiles) + UBound($removedXMLfiles)

	writeLogEchoToConsole("[Info]: Installing pack..." & @CRLF)

	; Display the Progress GUI
	displayProgressGUI("Install pack and remove old files", "Installing pack...")



	; Install
	installFromCache($installationFolder, $PackID, $dataFolder, $PackXMLDatabaseCurrentFiles, $totalFiles)


	; Should files be permanently deleted or sent to recycle bin
	$recycle = getUserSettingDeleteToRecycleBin($dataFolder)

	; Remove
	removeOldFiles($installationFolder, $PackID, $dataFolder, $recycle, $removedXMLfiles, $totalFiles)


	closeProgressGUI()
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: installFromCache
; Description ...: Installs files from cache to install folder
; Syntax ........: installFromCache($installationFolder, $PackID, $dataFolder)
; Parameters ....: $installationFolder	- Pack installation folder.
;                  $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Will overwrite files that differ from the remote file hash
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func installFromCache($installationFolder, $PackID, $dataFolder, $currentXMLfiles, $total)
	Dim $currentXMLfiles  ; All files that exist in the current pack
	Local $destinationFile
	Local $sourceFile
	Local $hash
	Local $totalFiles
	Local $fileCopyStatus

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	$totalFiles = UBound($currentXMLfiles)


	For $i = 0 to $totalFiles - 1

		;Update Progress GUI
		updateProgressGUI($i, $totalFiles, $i, $total, $currentXMLfiles[$i][0])



		; Full filename and path to install location
		If $currentXMLfiles[$i][2] = "" Then
			$destinationFile = $installationFolder & "\" & $currentXMLfiles[$i][0]
		Else
			$destinationFile = $installationFolder & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]
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


		$sourceFile = $dataFolder & "\PackData\Modpacks\" & $PackID & "\Cache\" & $currentXMLfiles[$i][3]

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
; Description ...: Delete all files marked for removal
; Syntax ........: removeOldFiles($installationFolder, $PackID, $dataFolder, $recycle)
; Parameters ....: $installationFolder	- Pack installation folder.
;                  $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
;				   $recycle				- True : send to recycle bin
;										- False : permanently delete files
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: If a file can not be deleted a warning will be displayed, but the program will continue
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func removeOldFiles($installationFolder, $PackID, $dataFolder, $recycle, ByRef $removedXMLfiles, $total)
	Local $destinationFile
	Local $sourceFile
	Local $totalFiles


	$totalFiles = UBound($removedXMLfiles) - 1


	For $i = 0 to $totalFiles

		;Update Progress GUI
		updateProgressGUI($i, $totalFiles, $i + $total - $totalFiles, $total, $removedXMLfiles[$i][0])


		; Full path and filename of file to remove
		If $removedXMLfiles[$i][2] = "" Then
			$destinationFile = $installationFolder & "\" & $removedXMLfiles[$i][0]
		Else
			$destinationFile = $installationFolder & "\" & $removedXMLfiles[$i][2] & "\" & $removedXMLfiles[$i][0]
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

	writeLogEchoToConsole("[Info]: File update complete" & @CRLF & @CRLF)
EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: getStatusInfoOfFilesToRemove
; Description ...: Creates an array of all files that has to be removed and is currently present in installation
; Syntax ........: getStatusInfoOfFilesToRemove($installationFolder, $PackID, $dataFolder)
; Parameters ....: $installationFolder	- Pack installation folder.
;                  $PackID              - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: Array of files that need to be removed
; Author ........: Error_998
; Modified ......:
; Remarks .......: Index zero  = file count
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getStatusInfoOfFilesToRemove($installationFolder, $PackID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current pack
	Dim $removeFiles[1]   ; All files that has to be removed and is currently present in installation
	Local $destinationFile
	Local $sourceFile
	Local $totalFiles
	Local $percentage

	writeLog("[Info]: Calculating files that needs removing..." & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($PackID, $dataFolder, "Removed")


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
		If Not FileExists($installationFolder & "\" & $destinationFile) Then ContinueLoop


		; Add file marked for removal that is present in current installation
		_ArrayAdd($removeFiles, $destinationFile & "#DEL")

	Next

	; Update file count in index zero
	$removeFiles[0] = UBound($removeFiles) - 1

	ConsoleWrite(@CRLF)

	Return $removeFiles
EndFunc