#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\SAMUpdater\DataIO\Folders.au3"
#include "DataIO\ModPack.au3"


Opt('MustDeclareVars', 1)

Local $modID = "Test"



; A file can be in 1 of 4 states:
; 1) Added - dl
; 2) Removed - File is not on the server list, client added custom file
; 3) Unchanged - Skip
; 4) Changed - dl



Func GetDiff(ByRef $aArray1, ByRef $aArray2, ByRef $aUnchangedFiles)
	Dim $aTemp[1]

	;No items in array
	$aTemp[0] = 0

	;For each item to search
	For $i = 1 to $aArray2[0]

		Dim $iKeyIndex = _ArrayBinarySearch($aArray1, $aArray2[$i], 1, $aArray1[0])
		If Not @error Then
			;These files are still the same
			_ArrayAdd($aUnchangedFiles, $aArray2[$i])
			$aUnchangedFiles[0] = $aUnchangedFiles[0] + 1
		Else
			;MsgBox(0, 'Entry Not found - Error: ' & @error, $i & ": " & $aArray2[$i])
			;ConsoleWrite($aArray2[$i] & @CRLF)
			_ArrayAdd($aTemp, $aArray2[$i])
			$aTemp[0] = $aTemp[0] + 1
		EndIf
	Next

	Return $aTemp
EndFunc


Func SplitChangedUnchangedFiles($sPath, $sPathNew, ByRef $aUnchangedFiles, ByRef $aChangedFiles)
	Dim $aTempUnchangedFiles[1]
	Dim $aTempChangedFiles[1]

	$aTempChangedFiles[0] = 0
	$aTempUnchangedFiles[0] = 0

	For $i = 1 To $aUnchangedFiles[0]
		; Create a md5 hash of the file.
		If _Crypt_HashFile($sPath & "\" & $aUnchangedFiles[$i], $CALG_MD5) = _Crypt_HashFile($sPathNew & "\" & $aUnchangedFiles[$i], $CALG_MD5) Then
			;ConsoleWrite("[OK] - " & $aFiles[$i] & @CRLF)
			_ArrayAdd($aTempUnchangedFiles, $aUnchangedFiles[$i])
			$aTempUnchangedFiles[0] = $aTempUnchangedFiles[0] + 1

		Else
			;ConsoleWrite("[FAILED] - " & $aFiles[$i] & @CRLF)
			_ArrayAdd($aTempChangedFiles, $aUnchangedFiles[$i])
			$aTempChangedFiles[0] = $aTempChangedFiles[0] + 1
		EndIf
	Next

	$aUnchangedFiles = $aTempUnchangedFiles
	$aChangedFiles = $aTempChangedFiles
EndFunc

func Test()
	Dim $aFilesServer
	Dim $sPathServer = @DesktopDir & "\1.7.10 - Forge"

	Dim $aFilesClient
	Dim $sPathClient = @DesktopDir & "\1.7.10\"

	Dim $aAddedFiles
	Dim $aRemovedFiles
	Dim $aUnchangedFiles[1]
	Dim $aChangedFiles[1]

	$aUnchangedFiles[0] = 0
	$aChangedFiles[0] = 0


	; Get server files and sort it in an array
	$aFilesServer = recurseFolders($sPathServer)

	ConsoleWrite("Server File Count: " & UBound($aFilesServer) - 1 & @CRLF)


	; Get client files
	$aFilesClient = recurseFolders($sPathClient)
	ConsoleWrite("Client File Count: " & UBound($aFilesClient) - 1 & @CRLF)


	; Get all new files
	$aAddedFiles = GetDiff($aFilesClient, $aFilesServer, $aUnchangedFiles)
	ConsoleWrite("New files added: " & UBound($aAddedFiles) - 1 & @CRLF)
	_ArrayDisplay($aAddedFiles, "Added Files")
	_ArrayDisplay($aFilesServer, "Server Files")

	ReDim $aUnchangedFiles[1]
	$aUnchangedFiles[0] = 0

	;Store all removed files
	$aRemovedFiles = GetDiff($aFilesServer, $aFilesClient, $aUnchangedFiles)
	ConsoleWrite("Files removed: " & UBound($aRemovedFiles) - 1 & @CRLF)
	_ArrayDisplay($aRemovedFiles, "Removed Files")


	; Above function also returns all the unchanged files
	;_ArrayDisplay($aUnchangedFiles)


	; Check if any of the unchanged files had any internal changes made and mark them as changed

	SplitChangedUnchangedFiles($sPathServer, $sPathClient, $aUnchangedFiles, $aChangedFiles)


	ConsoleWrite("Unchanged files: " & UBound($aUnchangedFiles) - 1 & @CRLF)
	_ArrayDisplay($aUnchangedFiles, "Unchanged Files")

	ConsoleWrite("Changed files: " & UBound($aChangedFiles) - 1 & @CRLF)
	_ArrayDisplay($aChangedFiles, "Changed Files")



	;~ $aAddedFiles
	;~ $aRemovedFiles
	;~ $aChangedFiles
	;~ $aUnchangedFiles
EndFunc








Dim $sPathServer = @DesktopDir & "\Folder A"
Dim $xml
$xml =  getXMLfilesFromSection($modID, @ScriptDir, "Removed")

_ArrayDisplay($xml)
