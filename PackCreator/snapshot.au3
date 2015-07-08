#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\SAMUpdater\GUI\Colors.au3"
#include "..\SAMUpdater\DataIO\Folders.au3"
#include "..\SAMUpdater\DataIO\Logs.au3"
#include "DataIO\ModPack.au3"
#include "DataIO\Cache.au3"


Opt('MustDeclareVars', 1)


Global $hdllKernel32 = initColors()
Global $hLog = initLogs(@ScriptDir)

; Close the log file on application exit
OnAutoItExitRegister("closeLog")


; Set console color
setConsoleColor($FOREGROUND_Light_Green)


func Test()
	Dim $aFilesServer
	Dim $sPathServer = "C:\Games Installed\Terraria"

	Dim $aFilesClient
	Dim $sPathClient = @DesktopDir & "\TestServer\Terraria"

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


Func modpackStats()
	Dim $removedXMLfiles  ; All files that were removed from modpack
	Dim $currentXMLfiles  ; All files that exist in the current modpack


	$removedXMLfiles =  getXMLfilesFromSection($modID, @ScriptDir, "Removed")
	ConsoleWrite("[Info]: Files marked for removal: " & UBound($removedXMLfiles) & @CRLF)

	$currentXMLfiles = getXMLfilesFromSection($modID, @ScriptDir, "Files")

	ConsoleWrite("[Info]: Modpack consists out of " & UBound($currentXMLfiles) & " files" & @CRLF)
	ConsoleWrite("[Info]: Modpack size: " & getHumanReadableFilesize( getTotalModpackFilesizeFromXML($modID, @ScriptDir) ) & @CRLF)

EndFunc

Local $modID = "Terraria"
Dim $pathToSourceFiles = @DesktopDir & "\TestServer\Terraria"

;~ Local $modID = "KSP"
;~ Dim $pathToSourceFiles = "C:\Data\Games - ISO\Kerbal Space Program\Kerbal Space Program"

;~ Local $modID = "StarMade"
;~ Dim $pathToSourceFiles = @DesktopDir & "\TestServer\StarMade"

;~ Local $modID = "Mechanical"
;~ Dim $pathToSourceFiles = @DesktopDir & "\TestServer\New Age Update 7\.minecraft"

;Local $modID = "Crash_Landing"
;Dim $pathToSourceFiles = "C:\Users\Jock\Desktop\TestServer\Crash_Landing\Update 1.1.3\.minecraft"

; InitFolders
writeLogEchoToConsole("Initialize Folders" & @CRLF)
createFolder(@ScriptDir & "\PackData\modpacks\" & $modID & "\data")
createFolder(@ScriptDir & "\PackData\modpacks\" & $modID & "\cache")
writeLogEchoToConsole("Folders initialized" & @CRLF & @CRLF)
; Folders initialized

;~ test()

saveModpack($modID, @ScriptDir, $pathToSourceFiles)

modpackStats()

updateCachefromXML($modID, @ScriptDir, $pathToSourceFiles)

splitLargeFiles($modID, @ScriptDir)

saveCompressedPack($modID, @ScriptDir)

modpackStats()
