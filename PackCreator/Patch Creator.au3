#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\SAMUpdater\DataIO\Folders.au3"
#include "DataIO\ModPack.au3"


Opt('MustDeclareVars', 1)

Dim $aFilesServer
Dim $sPathServer = @DesktopDir & "\TestServer\Update 3\.minecraft"

Dim $aFilesClient
Dim $sPathClient = @DesktopDir & "\TestServer\Update 2\.minecraft"

Dim $aAddedFiles
Dim $aRemovedFiles
Dim $aUnchangedFiles[1]
Dim $aChangedFiles[1]


; A file can be in 1 of 4 states:
; 1) Added - dl
; 2) Removed - File is not on the server list, client added custom file
; 3) Unchanged - Skip
; 4) Changed - dl



func Patch()

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

Patch()


