#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\..\SAMUpdater\DataIO\XML.au3"
#include "..\..\SAMUpdater\DataIO\Download.au3"
#include "ModPack.au3"

Opt('MustDeclareVars', 1)

Func updateCacheFromXML($modID, $dataFolder, $pathToSourceFiles)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Local $file
	Local $hash

	ConsoleWrite("[Info]: Reading files from " & $modID & ".xml" & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, @ScriptDir, "Files")


	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	ConsoleWrite("[Info]: Creating cache..." & @CRLF)
	For $i = 0 to UBound($currentXMLfiles) - 1
		; Path + Filename
		$file = $pathToSourceFiles & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]


		; Check if source file exists
		If Not FileExists($file) Then
			ConsoleWrite("[ERROR]: Missing source file - " & $file & @CRLF)
			MsgBox(48, "Missing source file", "Unable to locate source file:" & @CRLF & $file & @CRLF & "Please check the path")
			Exit
		EndIf


		; Calculate source file hash
		$hash = _Crypt_HashFile($file, $CALG_MD5)


		; Check if cache file already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $hash) Then
				; Skip existing file
				ContinueLoop
		EndIf


		; Create path and copy to cache folder
		if Not FileCopy($file, $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $hash, 8) Then
			ConsoleWrite("[ERROR]: Unable to copy file to cache - " & $file & @CRLF)
			MsgBox(48, "Error copying file to cache", "Unable to copy " & @CRLF & $file & @CRLF & "to" & @CRLF & $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache")
			Exit
		EndIf


	Next

	ConsoleWrite("[Info]: Cache updated successfully" & @CRLF)

EndFunc
