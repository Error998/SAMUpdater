#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
#include "..\DataIO\ModPack.au3"
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)

;~ Func updateCacheFromXML($modID, $dataFolder, $pathToSourceFiles)
;~ 	Dim $currentXMLfiles  ; All files that exist in the current modpack
;~ 	Local $file
;~ 	Local $hash

;~ 	ConsoleWrite("[Info]: Reading files from " & $modID & ".xml" & @CRLF)
;~ 	$currentXMLfiles = getXMLfilesFromSection($modID, @ScriptDir, "Files")


;~ 	; Startup crypt libary to speedup hash generation
;~ 	_Crypt_Startup()

;~ 	ConsoleWrite("[Info]: Creating cache..." & @CRLF)
;~ 	For $i = 0 to UBound($currentXMLfiles) - 1
;~ 		; Path + Filename
;~ 		$file = $pathToSourceFiles & "\" & $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0]


;~ 		; Check if source file exists
;~ 		If Not FileExists($file) Then
;~ 			ConsoleWrite("[ERROR]: Missing source file - " & $file & @CRLF)
;~ 			MsgBox(48, "Missing source file", "Unable to locate source file:" & @CRLF & $file & @CRLF & "Please check the path")
;~ 			Exit
;~ 		EndIf


;~ 		; Calculate source file hash
;~ 		$hash = _Crypt_HashFile($file, $CALG_MD5)


;~ 		; Check if cache file already exists
;~ 		If FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $hash) Then
;~ 				; Skip existing file
;~ 				ContinueLoop
;~ 		EndIf


;~ 		; Create path and copy to cache folder
;~ 		if Not FileCopy($file, $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache\" & $hash, 8) Then
;~ 			ConsoleWrite("[ERROR]: Unable to copy file to cache - " & $file & @CRLF)
;~ 			MsgBox(48, "Error copying file to cache", "Unable to copy " & @CRLF & $file & @CRLF & "to" & @CRLF & $dataFolder & "\PackData\Modpacks\" & $modID & "\Cache")
;~ 			Exit
;~ 		EndIf


;~ 	Next

;~ 	ConsoleWrite("[Info]: Cache updated successfully" & @CRLF)

;~ EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: cacheModpack
; Description ...: Download all modpack files into cache folder
; Syntax ........: cacheModpack($baseModURL, $modID, $dataFolder)
; Parameters ....: $baseModURL          - Base URL location containing the modpack files.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: <$basemodURL>/packdata/modpacks...
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func cacheModpack($baseModURL, $modID, $dataFolder)
	Local $uncachedFiles

	; Download <modID>.xml
	ConsoleWrite("[Info]: Downloading modpack file list - " & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml" & @CRLF)
	downloadFile($baseModURL & "/packdata/modpacks/" & $modID & "/data/" & $modID & ".xml", $dataFolder & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml")


	; Get a list of files that are not yet cached
	$uncachedFiles = getUncachedFileList($modID, $dataFolder)

	; Download and cache files if needed
	If $uncachedFiles[0] > 0 Then
		cacheFiles($baseModURL, $uncachedFiles, $modID, $dataFolder)
	EndIf

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: getUncachedFileList
; Description ...: Return a 1d array containing a list of uncached filenames
; Syntax ........: getUncachedFileList($modID, $dataFolder)
; Parameters ....: $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: Array of uncached filenames
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Index 0 = file count
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getUncachedFileList($modID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current modpack
	Dim $uncachedFiles[1]
	Local $filesize = 0
	Local $index
	Local $hash

	; Load <modID>.xml
	ConsoleWrite("[Info]: Parsing modpack file list from " & $modID & ".xml" & @CRLF & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Files")


	ConsoleWrite("[Info]: Caculating uncached files list..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To UBound($currentXMLfiles) - 1

		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3]) Then
			; File verified, skipping file
			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3], $CALG_MD5)
			If $hash = $currentXMLfiles[$i][3] then	ContinueLoop

		EndIf

		; Only add cache file if it wasnt added already
		If _ArraySearch($uncachedFiles, $currentXMLfiles[$i][3]) > -1 Then ContinueLoop


		; Unique cache file found
		_ArrayAdd($uncachedFiles, $currentXMLfiles[$i][3])

		; Total download filesize
		$filesize = $filesize + $currentXMLfiles[$i][4]

	Next

	; Shutdown the crypt library.
	_Crypt_Shutdown()

	$uncachedFiles[0] = UBound($uncachedFiles) - 1

	If $uncachedFiles[0] = 0 Then
		ConsoleWrite("[Info]: Cache is up to date" & @CRLF & @CRLF)
	Else
		ConsoleWrite("[Info]: " & $uncachedFiles[0] & " uncached files (" & getHumanReadableFilesize($filesize) & ") marked for download " & @CRLF & @CRLF)
	EndIf

	Return $uncachedFiles
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: cacheFiles
; Description ...: Download remote cache files
; Syntax ........: cacheFiles($baseModURL, $uncachedFiles, $modID, $dataFolder)
; Parameters ....: $baseModURL          - Base URL location containing the modpack files.
;                  $uncachedFiles       - 1D array with all the uncached filenames.
;                  $modID               - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func cacheFiles($baseModURL, $uncachedFiles, $modID, $dataFolder)
	Local $fileURL

	ConsoleWrite("[Info]: Downloading cache..." & @CRLF)

	; Download all uncached files
	For $i = 1 to $uncachedFiles[0]

		$fileURL = $baseModURL & "/packdata/modpacks/" & $modID & "/cache/" & $uncachedFiles[$i]

		ConsoleWrite("[Info]: Downloading - " & $modID & "/cache/" & $uncachedFiles[$i] & @CRLF)
		downloadAndVerify($fileURL, $uncachedFiles[$i], $dataFolder & "\PackData\Modpacks\" & $modID & "\cache", $uncachedFiles[$i])

	Next

	ConsoleWrite("[Info]: Modpack cache download complete" & @CRLF & @CRLF)

EndFunc