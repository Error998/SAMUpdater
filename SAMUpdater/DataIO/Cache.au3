#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include "..\DataIO\7Zip.au3"
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


	; Download all uncached files
	cacheFiles($PackRepository, $downloadQueue, $PackID, $dataFolder)



	; Extract compressed files cache files
	extractCache($PackID)


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
	Dim $downloadQueue[1][6]
	Local $totalFileSize = 0
	Local $hFile
	Local $hash
	Local $totalFiles
	Local $percentage
	Local $items
	Local $PackXMLDatabaseCompressed

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


	; Load <PackID>.xml if not already loaded
	If UBound($PackXMLDatabaseCurrentFiles) = 0 or $PackID <> $PackXMLDatabaseID Then

		writeLogEchoToConsole("[Info]: Parsing pack database from " & $PackID & ".xml" & @CRLF & @CRLF)

		$PackXMLDatabaseCurrentFiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")

	EndIf


	; Load Compressed section from <PackID>.xml
	$PackXMLDatabaseCompressed = getXMLfilesFromSection($PackID, $dataFolder, "Compressed")



	; Total files in Files section
	$totalFiles = UBound($PackXMLDatabaseCurrentFiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()

	For $i = 0 To $totalFiles

		; Populate database structure
		$repositoryDestinationFilename = $PackXMLDatabaseCurrentFiles[$i][0]
		$repositoryDestinationExtract = $PackXMLDatabaseCurrentFiles[$i][1]
		$repositoryDestinationPath = $PackXMLDatabaseCurrentFiles[$i][2]
		$repositoryHash = $PackXMLDatabaseCurrentFiles[$i][3]
		$repositoryFilesize = $PackXMLDatabaseCurrentFiles[$i][4]


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


		; Add compressed volumes to the download queue
		If $repositoryDestinationExtract = "True" Then

			$repositoryFilesize = addCompressedVolumesToDownloadQueue($repositoryHash, $PackXMLDatabaseCompressed, $downloadQueue)

			; Add the total volume size to the total download size
			$totalFileSize = $totalFileSize + $repositoryFilesize

			ContinueLoop
		EndIf


		; File is not compressed, add to queue if the file wasnt added already
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
; Name ..........: addCompressedVolumesToDownloadQueue
; Description ...: Adds the compressed file and all its volume files if split to the download queue
; Syntax ........: addCompressedVolumesToDownloadQueue($hash, $PackXMLDatabaseCompressed, Byref $downloadQueue)
; Parameters ....: $hash                		- The hash value of the original compressed file.
;                  $PackXMLDatabaseCompressed	- The Compressed section in <PackID>.xml
;                  $downloadQueue       		- [in/out] The download queue.
; Return values .: Total filesize of the volumes combined.
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func addCompressedVolumesToDownloadQueue($hash, $PackXMLDatabaseCompressed, ByRef $downloadQueue)
	Local $parentHash
	Local $items
	Local $totalFileSize

	; Pack Database structure
	Local $repositoryCompressedDestinationFilename
	Local $repositoryCompressedDestinationExtract
	Local $repositoryCompressedDestinationPath
	Local $repositoryCompressedHash
	Local $repositoryCompressedFilesize

	; Download Queue structure
	Local $downloadQueueSourceLocation
	Local $downloadQueueSourceFilename
	Local $downloadQueueDestinationLocation
	Local $downloadQueueDestinationFilename
	Local $downloadQueueSourceHash
	Local $downloadQueueFilesize


	; Find all volumes
	For $i = 0 To UBound($PackXMLDatabaseCompressed) - 1

		$repositoryCompressedDestinationFilename = $PackXMLDatabaseCompressed[$i][0]
		$repositoryCompressedDestinationExtract =$PackXMLDatabaseCompressed[$i][1]
		$repositoryCompressedDestinationPath = $PackXMLDatabaseCompressed[$i][2]
		$repositoryCompressedHash = $PackXMLDatabaseCompressed[$i][3]
		$repositoryCompressedFilesize = $PackXMLDatabaseCompressed[$i][4]

		; Remove .7z.xxx from the volume filename to get the parent Hash value
		$parentHash = StringLeft($repositoryCompressedDestinationFilename, StringLen($repositoryCompressedDestinationFilename) - 7)


		If $parentHash = $hash Then
			; Check if file already exist
			If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryCompressedDestinationFilename) And $repositoryCompressedFilesize > 0 Then

				; Check if local file hash matches
				If $repositoryCompressedHash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryCompressedDestinationFilename, $CALG_SHA1) Then

					; Valid file already exsits, skipping download
					ContinueLoop

				EndIf
			EndIf

			; Add to download queue
			$downloadQueueSourceLocation =  $PackRepository & "/packdata/modpacks/" & $PackID & "/cache"
			$downloadQueueSourceFilename = $repositoryCompressedDestinationFilename
			$downloadQueueDestinationLocation = $dataFolder & "\PackData\ModPacks\" & $PackID & "\Cache"
			$downloadQueueDestinationFilename = $repositoryCompressedDestinationFilename
			$downloadQueueSourceHash = $repositoryCompressedHash
			$downloadQueueFilesize = $repositoryCompressedFilesize

			$items = $downloadQueueSourceLocation  & "|" & $downloadQueueSourceFilename & "|" & $downloadQueueDestinationLocation & "|" & $downloadQueueDestinationFilename & "|" & $downloadQueueSourceHash & "|" & $downloadQueueFilesize

			; Add compressed volume file to the download queue
			_ArrayAdd($downloadQueue, $items)


			; Total filesize of volumes
			$totalFileSize = $totalFileSize + $repositoryCompressedFilesize

		EndIf

	Next


	Return $totalFileSize

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

	; Sa ity check - If there is nothing to download then return
	If $downloadQueueCount = 0 Then Return


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
; Remarks .......: $PackXMLDatabaseID stores the PackID of the pack's who's Info button was clicked
;				   Used in the download button to compare if its necessary to re-read the current files for pack
; Related .......: Index 0 = file count
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getStatusInfoOfUncachedFiles($PackID, $dataFolder, ByRef $totalFileSize)
	Dim $uncachedFiles[1]
	Local $filesize = 0
	Local $hash
	Local $totalFiles
	Local $percentage
	Local $PackXMLDatabaseCompressed

	; Pack Database structure
	Local $repositoryDestinationFilename
	Local $repositoryDestinationExtract
	Local $repositoryDestinationPath
	Local $repositoryHash
	Local $repositoryFilesize


	; Load <PackID>.xml if not already loaded
	If UBound($PackXMLDatabaseCurrentFiles) = 0 or $PackID <> $PackXMLDatabaseID Then

		writeLogEchoToConsole("[Info]: Parsing pack database from " & $PackID & ".xml" & @CRLF & @CRLF)

		$PackXMLDatabaseCurrentFiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")

	EndIf

	; Store packID for currentXMLFiles
	$PackXMLDatabaseID = $PackID


	; Load Compressed section from <PackID>.xml
	$PackXMLDatabaseCompressed = getXMLfilesFromSection($PackID, $dataFolder, "Compressed")

	; Total files in Files section
	$totalFiles = UBound($PackXMLDatabaseCurrentFiles) - 1


	writeLog("[Info]: Caculating uncached files..." & @CRLF)

	; Startup crypt libary to speedup hash generation
	_Crypt_Startup()


	For $i = 0 To $totalFiles

		; Populate database structure
		$repositoryDestinationFilename = $PackXMLDatabaseCurrentFiles[$i][0]
		$repositoryDestinationExtract = $PackXMLDatabaseCurrentFiles[$i][1]
		$repositoryDestinationPath = $PackXMLDatabaseCurrentFiles[$i][2]
		$repositoryHash = $PackXMLDatabaseCurrentFiles[$i][3]
		$repositoryFilesize = $PackXMLDatabaseCurrentFiles[$i][4]


		; Display progress percentage
		$percentage = Round($i / $totalFiles * 100, 2)

		; Update Progress bar
		setAdvInfoSplashProgress($percentage)

		; Format percentage
		$percentage = "(" & StringFormat("%.2f", $percentage)  & "%)"

		ConsoleWrite(@CR & "[Info]: Caculating uncached files " & $percentage)


		; Skip if remote file size is 0
		If $repositoryFilesize = 0 Then ContinueLoop


		; Verify file if it already exists
		If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash, $CALG_SHA1)

			; File verified, skipping file
			If $hash = $repositoryHash then	ContinueLoop

		EndIf

		;Is the file compressed?
		If $repositoryDestinationExtract = "True" Then
			$repositoryFilesize = getFilesizeOfUncachedVolume($PackID, $repositoryHash, $PackXMLDatabaseCompressed)
		EndIf

		; Unique cache file found
		_ArrayAdd($uncachedFiles, $repositoryDestinationPath & "\" & $repositoryDestinationFilename & "#ADD")

		; Total download filesize
		$filesize = $filesize + $repositoryFilesize

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



; #FUNCTION# ====================================================================================================================
; Name ..........: getFilesizeOfUncachedVolume
; Description ...: Gets the total filesize for all the unchaced files in the compressed section
; Syntax ........: getFilesizeOfUncachedVolume($PackID, $hash, $PackXMLDatabaseCompressed)
; Parameters ....: $PackID              		- The Pack ID.
;                  $hash               		 	- Parent hash of compressed file.
;                  $PackXMLDatabaseCompressed	- The Compressed section in <PackID>.xml
; Return values .: Total Filesize of compressed file (All volumes)
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getFilesizeOfUncachedVolume($PackID, $hash, $PackXMLDatabaseCompressed)
	Local $parentHash
	Local $totalFileSize

	; Pack Database structure
	Local $repositoryCompressedDestinationFilename
	Local $repositoryCompressedDestinationExtract
	Local $repositoryCompressedDestinationPath
	Local $repositoryCompressedHash
	Local $repositoryCompressedFilesize


	; Find all volumes
	For $i = 0 To UBound($PackXMLDatabaseCompressed) - 1

		$repositoryCompressedDestinationFilename = $PackXMLDatabaseCompressed[$i][0]
		$repositoryCompressedDestinationExtract =$PackXMLDatabaseCompressed[$i][1]
		$repositoryCompressedDestinationPath = $PackXMLDatabaseCompressed[$i][2]
		$repositoryCompressedHash = $PackXMLDatabaseCompressed[$i][3]
		$repositoryCompressedFilesize = $PackXMLDatabaseCompressed[$i][4]

		; Remove .7z.xxx from the volume filename to get the parent Hash value
		$parentHash = StringLeft($repositoryCompressedDestinationFilename, StringLen($repositoryCompressedDestinationFilename) - 7)


		If $parentHash = $hash Then
			; Check if file already exist
			If FileExists($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryCompressedDestinationFilename) And $repositoryCompressedFilesize > 0 Then

				; Check if local file hash matches
				If $repositoryCompressedHash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryCompressedDestinationFilename, $CALG_SHA1) Then

					; Valid file already exsits, skipping download
					ContinueLoop

				EndIf
			EndIf

			; Total filesize of volumes
			$totalFileSize = $totalFileSize + $repositoryCompressedFilesize

		EndIf

	Next


	Return $totalFileSize

EndFunc



Func extractCache($PackID)
	Local $PackXMLDatabaseCurrentFiles
	Local $hash

	; Pack Database structure
	Local $repositoryDestinationFilename
	Local $repositoryDestinationExtract
	Local $repositoryDestinationPath
	Local $repositoryHash
	Local $repositoryFilesize


	; Load <PackID>.xml if not already loaded
	If UBound($PackXMLDatabaseCurrentFiles) = 0 or $PackID <> $PackXMLDatabaseID Then

		writeLogEchoToConsole("[Info]: Parsing pack database from " & $PackID & ".xml" & @CRLF & @CRLF)

		$PackXMLDatabaseCurrentFiles = getXMLfilesFromSection($PackID, $dataFolder, "Files")

	EndIf

	; Init 7Zip libs
	_7ZipStartup()

	; Find each compressed file
	For $i = 0 to UBound($PackXMLDatabaseCurrentFiles) - 1

		; Polulate database structure
		$repositoryDestinationFilename = $PackXMLDatabaseCurrentFiles[$i][0]
		$repositoryDestinationExtract = $PackXMLDatabaseCurrentFiles[$i][1]
		$repositoryDestinationPath = $PackXMLDatabaseCurrentFiles[$i][2]
		$repositoryHash = $PackXMLDatabaseCurrentFiles[$i][3]
		$repositoryFilesize = $PackXMLDatabaseCurrentFiles[$i][4]


		; File is not compressed skip
		If $repositoryDestinationExtract <> "True" Then ContinueLoop


		; Check if it needs to be extracted
		If FileExists($dataFolder & "\PackData\ModPacks\" & $PackID & "\cache\" & $repositoryHash) Then

			$hash = _Crypt_HashFile($dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash, $CALG_SHA1)

			If $hash = $repositoryHash Then

				ContinueLoop
			EndIf
		EndIf


		writeLogEchoToConsole("[Info]: Extracting - " & $dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash & ".7z.001" & @CRLF)

		_7ZIPExtract(0, $dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash & ".7z.001", $dataFolder & "\PackData\Modpacks\" & $PackID & "\cache\" & $repositoryHash)
		If @error <> 0 Then
			writeLogEchoToConsole("[Error]: Extracting file failed - " & $repositoryHash & ".7z.001" & @CRLF)
		EndIf

	Next

	; Close 7Zip Libs
	_7ZipShutdown()

EndFunc