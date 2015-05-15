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
#include "..\GUI\frmDownload.au3"

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
	Local $downloadQueue
	Local $userReply

	; Download Queue structure
	Local $downloadQueueSourceLocation
	Local $downloadQueueSourceFilename
	Local $downloadQueueDestinationLocation
	Local $downloadQueueDestinationFilename
	Local $downloadQueueSourceHash
	Local $downloadQueueFilesize
	Local $downloadQueueCount
	Local $downloadQueueTotalFilesize

	; Disable Parent GUI
	GUISetState(@SW_DISABLE, $frmPackSelection)
	GUISetState(@SW_DISABLE, $hAperture)


	; Display Please Wait splash screen
	displayAdvInfoSplash()


	; Get a list of files that are not yet cached
	$downloadQueue = getUncachedDownloadList($PackID, $dataFolder)


	; Turn off the splash
	closeAdvInfoSplash()

	; Re-enable forms
	GUISetState(@SW_ENABLE, $frmPackSelection)
	GUISetState(@SW_ENABLE, $hAperture)
	WinActivate("SAMUpdater v" & $version)


	; Assign queue count
	$downloadQueueCount = $downloadQueue[0][0]

	; Assign total filesize
	$downloadQueueTotalFilesize = $downloadQueue[0][5]


	; If there is nothing to download then return
	If $downloadQueueCount = 0 Then Return




	; If offline and cache is incomplete let the user know
	If Not $isOnline Then
		writeLogEchoToConsole("[Warning]: Offline but found " & $downloadQueueCount & " uncached files." & @CRLF)
		writeLogEchoToConsole("[Warning]: Please switch to online mode to download the uncache files." & @CRLF)


		$userReply = MsgBox($MB_ICONWARNING + $MB_YESNO, "Missing cache files", "Would you like to switch to online mode and download the missing cache files?" & @CRLF  & @CRLF & " Clicking NO will close the application.")


		; Cache files missing, staying offline, closing app since we cant continue
		If $userReply = $IDNO Then

			writeLogEchoToConsole("[Info]: User opted not to switch to Online mode." & @CRLF)
			writeLogEchoToConsole("[Info]: Application will now close" & @CRLF)
			Exit

		EndIf


		; Switch to Online mode
		$isOnline = True

		; Save new user setting
		setUserSettingNetworkMode("Online", $dataFolder)

	EndIf



	cacheFiles($PackRepository, $downloadQueue, $PackID, $dataFolder)


EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: getUncachedDownloadList
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
Func getUncachedDownloadList($PackID, $dataFolder)
	Dim $currentXMLfiles  ; All files that exist in the current pack
	Dim $downloadQueue[1][6]
	Local $totalFileSize = 0
	Local $hFile
	Local $hash
	Local $totalFiles
	Local $percentage
	Local $items

	; Pack Database structure
	Local $repositoryDestinationFilename
	Local $repositoryDestinationExtract
	Local $repositoryDestinationPath
	Local $repositoryHash
	Local $repositoryFilesize

	; Download Queue structure
	Local $downloadQueueSourceLocation
	Local $downloadQueueSourceFilename
	Local $downloadQueueDestinationLocation
	Local $downloadQueueDestinationFilename
	Local $downloadQueueSourceHash
	Local $downloadQueueFilesize


	; Load <PackID>.xml
	writeLogEchoToConsole("[Info]: Parsing pack database from " & $PackID & ".xml" & @CRLF & @CRLF)
	$currentXMLfiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")


	; Total files in Files section
	$totalFiles = UBound($currentXMLfiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To $totalFiles

		; Populate database structure
		$repositoryDestinationFilename = $currentXMLfiles[$i][0]
		$repositoryDestinationExtract = $currentXMLfiles[$i][1]
		$repositoryDestinationPath = $currentXMLfiles[$i][2]
		$repositoryHash = $currentXMLfiles[$i][3]
		$repositoryFilesize = $currentXMLfiles[$i][4]


		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)

		; Update Progress bar
		setAdvInfoSplashProgress($percentage)

		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"

		ConsoleWrite(@CR & "[Info]: Caculating download queue " & $percentage)


		; If remote file size is 0, create a blank cache file
		If $repositoryFilesize = 0 Then

			; Create a empty cache file
			$hFile = FileOpen($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash, 2)
			FileClose($hFile)

			ContinueLoop
		EndIf



		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash, $CALG_SHA1)

			; File verified, skipping file
			If $hash = $repositoryHash then	ContinueLoop

		EndIf


		; Only add cache file if it wasnt added already
		If _ArraySearch($downloadQueue, $repositoryHash, 0, 0, 0, 0, 0, 1) > -1 Then	ContinueLoop


		; Create delimited item list for to add to download queue
		$downloadQueueSourceLocation = $PackRepository & "/packdata/modpacks/" & $PackID & "/cache"
		$downloadQueueSourceFilename = $repositoryHash & ".dat"
		$downloadQueueDestinationLocation = $dataFolder & "\PackData\ModPacks\" & $PackID & "\Cache"
		$downloadQueueDestinationFilename = $repositoryHash
		$downloadQueueSourceHash = $repositoryHash
		$downloadQueueFilesize = $repositoryFilesize

		$items = $downloadQueueSourceLocation  & "|" & $downloadQueueSourceFilename & "|" & $downloadQueueDestinationLocation & "|" & $downloadQueueDestinationFilename & "|" & $downloadQueueSourceHash & "|" & $downloadQueueFilesize

		; Unique cache file found, add it to download queue
		_ArrayAdd($downloadQueue, $items)


		; Total download filesize
		$totalFileSize = $totalFileSize + $repositoryFilesize

	Next


	; Shutdown the crypt library.
	_Crypt_Shutdown()

	ConsoleWrite(@CRLF)


	; Store queue total filesize in array[0][5]
	$downloadQueue[0][5] = $totalFileSize

	; Store queue size in array[0][0]
	$downloadQueue[0][0] = UBound($downloadQueue) - 1


	; Check if the download queue is empty
	If $downloadQueue[0][0] = 0 Then
		writeLogEchoToConsole("[Info]: Cache is up to date and ready to be installed" & @CRLF & @CRLF)
	Else
		writeLogEchoToConsole("[Info]: " & $downloadQueue[0][0] & " uncached files (" & getHumanReadableFilesize($totalFileSize) & ") marked for download " & @CRLF & @CRLF)
	EndIf


	Return $downloadQueue

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
Func cacheFiles($PackRepository, $downloadQueue, $PackID, $dataFolder)
	Local $fileURL

	writeLogEchoToConsole("[Info]: Downloading cache..." & @CRLF)


	; Download Queue structure
	Local $downloadQueueSourceLocation
	Local $downloadQueueSourceFilename
	Local $downloadQueueDestinationLocation
	Local $downloadQueueDestinationFilename
	Local $downloadQueueSourceHash
	Local $downloadQueueFilesize
	Local $downloadQueueCount = $downloadQueue[0][0]
	Local $downloadQueueTotalFilesize = $downloadQueue[0][5]

	Local $totalBytesDownloaded = 0

	; Disable Parent GUI's
	GUISetState(@SW_DISABLE, $frmPackSelection)
	GUISetState(@SW_DISABLE, $hAperture)


	; Display the Download Progress GUI
	displayDownloadGUI("Download Pack", "Downloading Pack: " & $PackID)


	For $i = 1 To $downloadQueueCount

		; Populate download queue structure
		$downloadQueueSourceLocation = $downloadQueue[$i][0]
		$downloadQueueSourceFilename = $downloadQueue[$i][1]
		$downloadQueueDestinationLocation = $downloadQueue[$i][2]
		$downloadQueueDestinationFilename = $downloadQueue[$i][3]
		$downloadQueueSourceHash = $downloadQueue[$i][4]
		$downloadQueueFilesize = $downloadQueue[$i][5]


		;Update Console info
		ConsoleWrite(@CR & "[Info]: (" & $i & "/" & $downloadQueueCount & ") Downloading - " & $downloadQueueSourceFilename)


		; Detailed log entry
		writeLog("[Info]: (" & $i & "/" & $downloadQueueCount & ") Downloading - " & $downloadQueueDestinationLocation & "\" & $downloadQueueDestinationFilename)

		;GUI Download
		downloadFileV2($downloadQueueSourceLocation & "/" & $downloadQueueSourceFilename, $downloadQueueDestinationLocation & "\" & $downloadQueueDestinationFilename, $downloadQueueFilesize, $downloadQueueTotalFilesize, $totalBytesDownloaded, "Current File Progress (" & $i & " of " & $downloadQueueCount & ")", 5, True)


		$totalBytesDownloaded = $totalBytesDownloaded + $downloadQueueFilesize

	Next

	sleep(1000)

	closeDownloadGUI()

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