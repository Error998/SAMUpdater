#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)




; #FUNCTION# ====================================================================================================================
; Name ..........: installModPack
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
Func installModPack($defaultInstallFolder, $modID, $dataFolder)
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
			MsgBox(48, "Error copying file to installation folder", "Unable to copy " & @CRLF & $sourceFile & @CRLF & "to" & @CRLF & $destinationFile)
			Exit
		EndIf

		ConsoleWrite("[Info}: File installed - " & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & @CRLF)

	Next

	; Close the crypt libary to free resources
	_Crypt_Shutdown()

EndFunc