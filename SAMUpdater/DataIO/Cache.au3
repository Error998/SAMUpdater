#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
#include "..\DataIO\ModPack.au3"
#include "..\DataIO\Folders.au3"
#include "..\DataIO\UserSettings.au3"

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: cachePack
; Description ...: Download all pack files into cache folder
; Syntax ........: cachePack($PackRepository, $PackID, $dataFolder)
; Parameters ....: $PackRepository          - Location of the pack repository.
;                  $PackID        	        - The PackID.
;                  $dataFolder      	    - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: <$PackRepository>/packdata/modpacks...
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func cachePack($PackRepository, $PackID, $dataFolder)
	Local $uncachedFiles
	Local $reply

	; Get a list of files that are not yet cached
	$uncachedFiles = getUncachedFileList($PackID, $dataFolder)

	; Cache is up to date, return
	If $uncachedFiles[0] = 0 Then Return




	; If offline and cache is incomplete let the user know
	If Not $isOnline Then
		writeLogEchoToConsole("[Warning]: Offline but found " & $uncachedFiles[0] & " uncached files." & @CRLF)
		writeLogEchoToConsole("[Warning]: Please switch to online mode to download the uncache files." & @CRLF)


		$reply = MsgBox($MB_ICONWARNING + $MB_YESNO, "Missing cache files", "Would you like to switch to online mode and download the missing cache files?" & @CRLF  & @CRLF & " Clicking NO will close the application.")


		; Cache files missing, staying offline, closing app since we cant continue
		If $reply = $IDNO Then

			writeLogEchoToConsole("[Info]: User opted not to switch to Online mode." & @CRLF)
			writeLogEchoToConsole("[Info]: Application will now close" & @CRLF)
			Exit

		EndIf


		; Switch to Online mode
		$isOnline = True

		; Save new user setting
		setUserSettingNetworkMode("Online", $dataFolder)

	EndIf



	cacheFiles($PackRepository, $uncachedFiles, $PackID, $dataFolder)


EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: getUncachedFileList
; Description ...: Return a 1d array containing a list of uncached filenames
; Syntax ........: getUncachedFileList($PackID, $dataFolder)
; Parameters ....: $PackID               - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: Array of uncached filenames
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Index 0 = file count
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getUncachedFileList($PackID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current pack
	Dim $uncachedFiles[1]
	Local $filesize = 0
	Local $hFile
	Local $hash
	Local $totalFiles
	Local $percentage

	; Load <PackID>.xml
	writeLogEchoToConsole("[Info]: Parsing pack file list from " & $PackID & ".xml" & @CRLF & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")

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
			$hFile = FileOpen($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $currentXMLfiles[$i][3], 2)
			FileClose($hFile)

			ContinueLoop
		EndIf



		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $currentXMLfiles[$i][3]) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $currentXMLfiles[$i][3], $CALG_SHA1)

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
; Syntax ........: cacheFiles($PackRepository, $uncachedFiles, $PackID, $dataFolder)
; Parameters ....: $PackRepository      - Location of the pack repository.
;                  $uncachedFiles       - 1D array with all the uncached filenames.
;                  $PackID               - The PackID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func cacheFiles($PackRepository, $uncachedFiles, $PackID, $dataFolder)
	Local $fileURL

	writeLogEchoToConsole("[Info]: Downloading cache..." & @CRLF)

	; Download all uncached files
	For $i = 1 to $uncachedFiles[0]

		$fileURL = $PackRepository & "/packdata/modpacks/" & $PackID & "/cache/" & $uncachedFiles[$i] & ".dat"

		; Shortend console entry
		ConsoleWrite(@CR & "[Info]: (" & $i & "/" & $uncachedFiles[0] & ") Downloading - " & $uncachedFiles[$i])
		; Detailed log entry
		writeLog("[Info]: (" & $i & "/" & $uncachedFiles[0] & ") Downloading - " & $dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $uncachedFiles[$i] & ".dat")

		; Download file then verify if it matches remote hash entry
		downloadAndVerify($fileURL, $uncachedFiles[$i], $dataFolder & "\PackData\Modpacks\" & $PackID & "\cache", $uncachedFiles[$i], 5, True)


	Next

	writeLogEchoToConsole("[Info]: Pack cache download complete" & @CRLF & @CRLF)

EndFunc







; #FUNCTION# ====================================================================================================================
; Name ..........: getStatusInfoOfUncachedFiles
; Description ...: Return a 1d array containing a list of uncached filenames
; Syntax ........: getStatusInfoOfUncachedFiles($PackID, $dataFolder, byRef $totalFileSize)
; Parameters ....: $PackID               - The PackID.
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
Func getStatusInfoOfUncachedFiles($PackID, $dataFolder, ByRef $totalFileSize)
	Dim $uncachedFiles[1]
	Dim $currentXMLfiles ; All files that exist in the current modpack
	Local $filesize = 0
	Local $hash
	Local $totalFiles
	Local $percentage


	; Load <PackID>.xml
	$currentXMLfiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")


	; Total files in Files section
	$totalFiles = UBound($currentXMLfiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To $totalFiles

		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)

		; Update Progress bar
		setAdvInfoSplashProgress($percentage)

		; Format percentage
		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"

		ConsoleWrite(@CR & "[Info]: Caculating uncached files " & $percentage)


		; Skip if remote file size is 0
		If $currentXMLfiles[$i][4] = 0 Then ContinueLoop


		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $currentXMLfiles[$i][3]) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $currentXMLfiles[$i][3], $CALG_SHA1)

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