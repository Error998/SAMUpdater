#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
#include "..\DataIO\ModPack.au3"
#include "..\DataIO\Folders.au3"

Opt('MustDeclareVars', 1)


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
	Local $hFile
	Local $hash
	Local $totalFiles
	Local $percentage

	; Load <modID>.xml
	writeLogEchoToConsole("[Info]: Parsing modpack file list from " & $modID & ".xml" & @CRLF & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Files")

	; Total files in Files section
	$totalFiles = UBound($currentXMLfiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To $totalFiles

		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)
		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"

		ConsoleWrite(@CR & "[Info]: Caculating uncached files " & $percentage)


		; If remote file size is 0, create a blank cache file
		If $currentXMLfiles[$i][4] = 0 Then

			; Create a empty cache file
			$hFile = FileOpen($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3], 2)
			FileClose($hFile)

			ContinueLoop
		EndIf



		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3]) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3], $CALG_SHA1)

			; File verified, skipping file
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

	ConsoleWrite(@CRLF)

	If $uncachedFiles[0] = 0 Then
		writeLogEchoToConsole("[Info]: Cache is up to date" & @CRLF & @CRLF)
	Else
		writeLogEchoToConsole("[Info]: " & $uncachedFiles[0] & " uncached files (" & getHumanReadableFilesize($filesize) & ") marked for download " & @CRLF & @CRLF)
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

	writeLogEchoToConsole("[Info]: Downloading cache..." & @CRLF)

	; Download all uncached files
	For $i = 1 to $uncachedFiles[0]

		$fileURL = $baseModURL & "/packdata/modpacks/" & $modID & "/cache/" & $uncachedFiles[$i] & ".dat"

		; Shortend console entry
		ConsoleWrite(@CR & "[Info]: (" & $i & "/" & $uncachedFiles[0] & ") Downloading - " & $uncachedFiles[$i])
		; Detailed log entry
		writeLog("[Info]: (" & $i & "/" & $uncachedFiles[0] & ") Downloading - " & $dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $uncachedFiles[$i] & ".dat")

		; Download file then verify if it matches remote hash entry
		downloadAndVerify($fileURL, $uncachedFiles[$i], $dataFolder & "\PackData\Modpacks\" & $modID & "\cache", $uncachedFiles[$i], 5, True)


	Next

	writeLogEchoToConsole("[Info]: Modpack cache download complete" & @CRLF & @CRLF)

EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: getStatusInfoOfUncachedFiles
; Description ...: Return a 1d array containing a list of uncached filenames
; Syntax ........: getStatusInfoOfUncachedFiles($modID, $dataFolder, byRef $totalFileSize)
; Parameters ....: $modID               - The modID.
;                  $dataFolder          - Application data folder.
;				   $totalFileSize		- (In/Out) Total filesize of uncached files
; Return values .: Array of uncached filenames
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Index 0 = file count
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getStatusInfoOfUncachedFiles($modID, $dataFolder, ByRef $totalFileSize)
	Dim $uncachedFiles[1]
	Dim $currentXMLfiles ; All files that exist in the current modpack
	Local $filesize = 0
	Local $hash
	Local $totalFiles
	Local $percentage


	; Load <modID>.xml
	$currentXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Files")


	; Total files in Files section
	$totalFiles = UBound($currentXMLfiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To $totalFiles

		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)
		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"

		ConsoleWrite(@CR & "[Info]: Caculating uncached files " & $percentage)


		; Skip if remote file size is 0
		If $currentXMLfiles[$i][4] = 0 Then ContinueLoop


		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3]) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $modID & "\cache\" & $currentXMLfiles[$i][3], $CALG_SHA1)

			; File verified, skipping file
			If $hash = $currentXMLfiles[$i][3] then	ContinueLoop

		EndIf



		; Unique cache file found
		_ArrayAdd($uncachedFiles, $currentXMLfiles[$i][2] & "\" & $currentXMLfiles[$i][0] & "#ADD")

		; Total download filesize
		$filesize = $filesize + $currentXMLfiles[$i][4]

	Next


	; Shutdown the crypt library.
	_Crypt_Shutdown()


	; Return total filesize
	$totalFileSize = $filesize

	; Store number of uncached files in index zero
	$uncachedFiles[0] = UBound($uncachedFiles) - 1

	ConsoleWrite(@CRLF)


	Return $uncachedFiles
EndFunc