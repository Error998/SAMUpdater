#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\..\SAMUpdater\DataIO\XML.au3"
#include "..\..\SAMUpdater\DataIO\Download.au3"
#include "FileState.au3"
#include "7Zip.au3"

Opt('MustDeclareVars', 1)



; #FUNCTION# ====================================================================================================================
; Name ..........: loadXMLfileSection
; Description ...: Read <modID>.xml and return a specific file section
; Syntax ........: loadXMLfileSection($modID, $dataFolder, $section)
; Parameters ....: $modID				- modID
;				   $dataFolder 			- Application data folder
;				   $section				- either "Removed" or "Files"
; Return values .: Trimed XML data containing a file section
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func loadXMLfileSection($modID, $dataFolder, $section)
	Local $xml
	Dim $filesSectionXML

	; Load and parse xml document
	$xml = loadXML($dataFolder & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml")

	; Array for each file section
	$filesSectionXML = getElement($xml, $section)


	Return $filesSectionXML
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getXMLfilesFromSection
; Description ...: Create an array containing each file + info from the XML section
; Syntax ........: getXMLfilesFromSection($modID, $dataFolder, $section)
; Parameters ....: $modID               - The modID
;                  $dataFolder          - Application data folder
;                  $section             - The section to return ("Removed" / "Files")
; Return values .: 2d Array with a zero based index containing each file info from <modID>.xml
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getXMLfilesFromSection($modID, $dataFolder, $section)
	Local $filesSectionXML
	Local $fileXML

	; Load <modID>.xml
	$filesSectionXML = loadXMLfileSection($modID, $dataFolder, $section)

	; Get the extended info of each file
	$fileXML = getElements($filesSectionXML, "File")


	; Store all elemetns
	Dim $aXMLFiles[ $fileXML[0] ][5]

	For $i = 0 To $fileXML[0] - 1
		$aXMLFiles[$i][0] = getElement($fileXML[$i + 1], "Filename")
		$aXMLFiles[$i][1] = getElement($fileXML[$i + 1], "Extract")
		$aXMLFiles[$i][2] = getElement($fileXML[$i + 1], "Path")
		$aXMLFiles[$i][3] = getElement($fileXML[$i + 1], "SHA1")
		$aXMLFiles[$i][4] = getElement($fileXML[$i + 1], "Size")
	Next

	Return $aXMLFiles
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: WriteSection
; Description ...: Writes a file info section from a 2d array
; Syntax ........: WriteSection($hFile, $section, $aSectionFileInfo)
; Parameters ....: $hFile               - File handle
;                  $section             - String section name
;                  $aSectionFileInfo    - An 2d array containing the file info
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Used internally by writeModpack() function
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func WriteSection($hFile, $section, $aSectionFileInfo)
	; Section header
	_ArrayDisplay($aSectionFileInfo)
	FileWriteLine($hFile, @TAB & '<' & $section & '>')

	; Write file info
	For $i = 1 To $aSectionFileInfo[0][0]
		FileWriteLine($hFile, @TAB & @TAB & '<File>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Filename>' & $aSectionFileInfo[$i][0] & '</Filename>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Extract>' & $aSectionFileInfo[$i][1] & '</Extract>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Path>' & $aSectionFileInfo[$i][2] & '</Path>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<SHA1>' & $aSectionFileInfo[$i][3] & '</SHA1>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Size>' & $aSectionFileInfo[$i][4] & '</Size>')
		FileWriteLine($hFile, @TAB & @TAB & '</File>')
	Next

	; End of Section
	FileWriteLine($hFile, @TAB & '</' & $section & '>')

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: WriteModpack
; Description ...: Creates the <modID>.xml file
; Syntax ........: WriteModpack($modPackID, $path, Byref $aFiles, Byref $aRemovedFiles)
; Parameters ....: $modPackID           - modpack ID, will also be used for the filename of the xml document
;                  $path                - Path where the fiel recursion started
;                  $aFiles              - Array of current files in the modpack
;                  $aRemovedFiles       - Array of all the files that has been removed from the modpack
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func WriteModpack($modPackID, $path, ByRef $aFiles, ByRef $aRemovedFiles)
	Local $hFile
	Local $aFilesWithFileInfo

	; Open a new xml document for writing
	$hFile = FileOpen(@ScriptDir & "\PackData\Modpacks\" & $modPackID & "\Data\" & $modPackID & ".xml", 10) ; erase + create dir
	If $hFile = -1 Then
		writeLogEchoToConsole("[ERROR]: Unable to create - " & @ScriptDir & "\PackData\Modpacks\" & $modPackID & "\Data\" & $modPackID & ".xml" & @CRLF)
		MsgBox(48, "Error creating xml document", "Unable to create xml document:" & @CRLF & @ScriptDir & "\PackData\Modpacks\" & $modPackID & "\Data\" & $modPackID & ".xml")
		Exit
	EndIf


		; XML Header
		writeLogEchoToConsole("[Info]: Creating " & $modPackID & ".xml document" & @CRLF)
		FileWriteLine($hFile,'<ModPack version="1.0">')


		; Get removed files info
		$aFilesWithFileInfo = _GetFileInfos($path, $aRemovedFiles)

		; Write Removed section
		writeLogEchoToConsole("[Info]: Writing removed section" & @CRLF)
		WriteSection($hFile, "Removed", $aFilesWithFileInfo)


		; Get server files info
		$aFilesWithFileInfo = _GetFileInfos($path, $aFiles)

		; Write Files section
		writeLogEchoToConsole("[Info]: Writing Files section" & @CRLF)
		WriteSection($hFile, "Files", $aFilesWithFileInfo)



		; Close XML Header
		FileWriteLine($hFile,'</ModPack>')

	; Close xml document
	FileClose($hFile)

	writeLogEchoToConsole("[Info]: Finnished writing " & $modPackID & ".xml" & @CRLF)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: _GetFileInfos
; Description ...: Internal function to convert a 1d file array to a 2d section modpack.xml file format
; Syntax ........: _GetFileInfos($path, $aFiles)
; Parameters ....: $path                - Path of where the recursion started.
;                  $aFiles              - An array of files
; Return values .: 2d array ontaining file info in <modID>.xml format
; Author ........: Error_998
; Modified ......:
; Remarks .......: If the file array is function will also return an array with index 0 set to 0
; Related .......: Internal function for WriteModpack()
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _GetFileInfos($path, $aFiles)
	; Return 0 filled array if aFiles contain no files
	If $aFiles[0] = 0 Then
		Dim $aFileInfo[1][5]
		$aFileInfo[0][0] = 0
		Return $aFileInfo
	EndIf

	Local $maxFileSize = 1024 * 1024 * 10 ; 10MB
	Dim $aFileInfo[ $aFiles[0] + 1 ][5]

	; Startup crypt libary to speedup hash generation
	 _Crypt_Startup()

	; Calculate info section for each file
	For $i =  1 To $aFiles[0]
		$aFileInfo[$i][0] =	getFilename($path & "\" & $aFiles[$i])

		$aFileInfo[$i][2] = getPath($aFiles[$i])

		; Only perform file operations if the file exist
		If FileExists($path & "\" & $aFiles[$i]) Then
			$aFileInfo[$i][3] = _Crypt_HashFile($path &  "\" & $aFiles[$i], $CALG_SHA1)
			$aFileInfo[$i][4] = getFileSize($path & "\" & $aFiles[$i])

		Else
			; Fill with black values since the file does not exist
			$aFileInfo[$i][3] = ""
			$aFileInfo[$i][4] = ""
		EndIf

		; If file bigger than 10MB it will have to be extracted
		If $aFileInfo[$i][4] > $maxFileSize Then
			$aFileInfo[$i][1] = "True"
		Else
			$aFileInfo[$i][1] = "False"
		EndIf
	Next

	; Close the crypt libary to free resources
	_Crypt_Shutdown()

	$aFileInfo[0][0] = $aFiles[0]


	Return $aFileInfo
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getRemovedSourceFiles
; Description ...: Calculate an array containing all the removed files that was ever part of the modpack
; Syntax ........: getRemovedSourceFiles($modID, $pathToSourceFiles)
; Parameters ....: $modID               - modID, also used with the location of the <modID>.xml file
;                  $pathToSourceFiles   - Path to the source files of the current mod state
; Return values .: A one dimentional array containing the full path and filenames of all removed files. Index 0 = file count
; Author ........: Error_998
; Modified ......:
; Remarks .......: If no files where ever removed, return a one dimentional array with index 0 = 0
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getRemovedSourceFiles($modID, $dataFolder, $aSourceFiles)
	; <modID>.xml does not exist return an empty filled array to prevent null error
	If Not FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml") Then

		Dim $aRemovedSourceFiles [1]
		$aRemovedSourceFiles[0] = 0

		writeLogEchoToConsole("[Info]: 0 Files are marked for removal in " & $modID & ".xml" & @CRLF)
		Return $aRemovedSourceFiles
	EndIf


	Dim $aRemovedSourceFiles		; Removed source files when comparing current files with xml files
	Dim $aRemovedXMLfiles			; File array of removed files from XML file
	Dim $removedXMLfiles			; XML files array for removed files
	Dim $aCurrentXMLFiles			; XML files array of current files
	Dim $aUnchangedFiles[1]			; Unused but needed by GetDiff


	; Read removed files already saved in <modID>.xml
	$removedXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")

	; Convert the XML files to aFiles array
	$aRemovedXMLfiles = convertXMLfilesToaFiles($removedXMLfiles)
	writeLogEchoToConsole("[Info]: Files are marked for removal in " & $modID & ".xml: " & $aRemovedXMLfiles[0] & @CRLF & @CRLF)


	writeLogEchoToConsole("[Info]: Calculate removed files between " & $modID & ".xml" & " and current files" & @CRLF)
	; Get current files from <modID>.xml
	$aCurrentXMLFiles = convertXMLfilesToaFiles( getXMLfilesFromSection($modID, $dataFolder, "Files"))


	; Calculate removed files bewteen current modpack state and <modID>.xml
	$aRemovedSourceFiles = GetDiff($aSourceFiles, $aCurrentXMLFiles, $aUnchangedFiles)
	writeLogEchoToConsole("[Info]: New files are marked for removal: " & $aRemovedSourceFiles[0] & @CRLF & @CRLF)


	; Merge the exsisting and newly removed files
	for $i = 1 To $aRemovedXMLfiles[0]
		_ArrayAdd($aRemovedSourceFiles, $aRemovedXMLfiles[$i])
	Next

	; Adjust new file count
	$aRemovedSourceFiles[0] = UBound($aRemovedSourceFiles) - 1


	Return $aRemovedSourceFiles
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: convertXMLfilesToaFiles
; Description ...: Convert a XML files array to a aFiles array (convert <modID>.xml file section to the same format as returned
;				   by the recurseFolder function)
; Syntax ........: convertXMLfilesToaFiles($aXMLFiles)
; Parameters ....: $aXMLFiles           - An array of XMLFiles section array.
; Return values .: An 2d array of files, Index 0 = file count
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func convertXMLfilesToaFiles($aXMLFiles)
	; If no files exsit return a 0 array to prevent Null errors
	If UBound($aXMLFiles) = 0 Then
		Dim $aFiles[1]
		$aFiles[0] = 0

		Return $aFiles
	EndIf


	; Dynamic array just big enought to store all files + file count in index 0
	Dim $aFiles[ UBound($aXMLFiles) + 1]


	; Index 0 contains number of files
	$aFiles[0] = UBound($aXMLFiles)

	for $i =  1 to UBound($aXMLFiles)
		If $aXMLFiles[$i - 1][2] = "" Then
			; Path is blank
			$aFiles[$i] = $aXMLFiles[$i - 1][0]
		Else
			; Include path
			$aFiles[$i] = $aXMLFiles[$i - 1][2] & "\" & $aXMLFiles[$i - 1][0]
		EndIf
	Next


	Return $aFiles
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getTotalModpackFilesizeFromXML
; Description ...: Calculates the total filesize in bytes of the Files section of <modID>.xml
; Syntax ........: getTotalModpackFilesizeFromXML($modID, $dataFolder)
; Parameters ....: $modID               - The modID
;                  $dataFolder          - Application data flder
; Return values .: total filesize of modpack in bytes
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getTotalModpackFilesizeFromXML($modID, $dataFolder)
	Local $currentXMLFiles
	Local $totalSize = 0

	; Get all the file info of the current files
	$currentXMLFiles = getXMLfilesFromSection($modID, $dataFolder, "Files")

	; Calculate total file size
	For $i =  0 to UBound($currentXMLFiles) - 1
		$totalSize = $totalSize + $currentXMLFiles[$i][4]
	Next

	Return $totalSize
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: saveModpack
; Description ...: Save the <modID>.xml file depending on the state of the current source files and save any previously removed
;				   files, including newly removed files
; Syntax ........: saveModpack($modID, $pathToSourceFiles)
; Parameters ....: $modID               - The modID, also used for determining the location of the saved file
;                  $pathToSourceFiles   - Path to the source files of the current mod state.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: If no removed files exsist (first time saving modpack) a blank <Removed> section will be created
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func saveModpack($modID, $dataFolder, $pathToSourceFiles)
	Dim $aSourceFiles
	Dim $aRemovedSourceFiles

	; Get current modpack files
	writeLogEchoToConsole("[Info]: Calculating current source files..." & @CRLF)
	$aSourceFiles = recurseFolders($pathToSourceFiles)
	writeLogEchoToConsole("[Info]: Source files found: " & UBound($aSourceFiles) - 1 & @CRLF & @CRLF)


	; ****** Get Removed Files **********
	writeLogEchoToConsole("[Info]: Calculating removed files..." & @CRLF)
	$aRemovedSourceFiles = getRemovedSourceFiles($modID, $dataFolder, $aSourceFiles)
	writeLogEchoToConsole("[Info]: Total files in removal section: " & (UBound($aRemovedSourceFiles) - 1) & @CRLF & @CRLF)

	; Write <modID>.xml
	WriteModpack($modID, $pathToSourceFiles, $aSourceFiles, $aRemovedSourceFiles)
EndFunc



Func splitLargeFiles($modID, $dataFolder)
	Local $currentXMLFiles
	Local $fullpath
	Local $cacheFolder = @ScriptDir & "\PackData\modpacks\" & $modID & "\cache"
	Dim $splitXMLFiles[1][5]
	Local $zipResult


	; Read Pack.xml
	;Get all the file info of the current files
	$currentXMLFiles = getXMLfilesFromSection($modID, $dataFolder, "Files")



	;_ArrayDisplay($currentXMLFiles)

	For $i = 0 to UBound($CurrentXMLFiles) - 1
		; Get files marked for extraction
		If $currentXMLFiles[$i][1] = "True" Then
			; full path + filename
			If $currentXMLFiles[$i][2] = "" Then
				$fullpath = $pathToSourceFiles & "\" & $currentXMLFiles[$i][0]
			Else
				$fullpath = $pathToSourceFiles & "\" & $currentXMLFiles[$i][2] & "\" & $currentXMLFiles[$i][0]
			EndIf


			ConsoleWrite("[Source]: " & $fullpath & @CRLF)
			ConsoleWrite("[Destination]: " & $cacheFolder & @CRLF)

			$zipResult = _7ZipAdd(0, $cacheFolder & "\" & $currentXMLFiles[$i][3], $fullpath, 0, 9, 0, 0, 0, 0, 0, "10m")
			If @error > 0 Then
				writeLogEchoToConsole("[Error]:  Failed to compress file!" & @CRLF)
				writeLogEchoToConsole($zipResult & @CRLF)
			EndIf

		EndIf

	Next
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getCompressedFilesInfo
; Description ...: Get the file info for all the compressed files
; Syntax ........: getCompressedFilesInfo($modID, $dataFolder)
; Parameters ....: $modID               - The Pack ID.
;                  $dataFolder          - Application data folder.
; Return values .: Array in the format of Pack.xml
; Author ........: Error_998
; Modified ......:
; Remarks .......: Data only, no tags
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getCompressedFilesInfo($modID, $dataFolder)
	Local $aCompressedFiles
	Local $compressedFolder = $dataFolder & "\PackData\modpacks\" & $modID & "\cache"
	Local $fileInfo

	$aCompressedFiles = recurseFolders($compressedFolder, "*.dat")

	$fileInfo = _GetFileInfos($compressedFolder, $aCompressedFiles)

	;_ArrayDisplay($fileInfo)

	Return $fileInfo
EndFunc



Func saveCompressedPack($modID, $dataFolder)
	Local $aCompressedFiles
	Local $aFiles
	Local $aRemovedFiles
	Local $hFile

	; Current Files
	writeLogEchoToConsole("[Info]: Reading Files section" & @CRLF)
	$aFiles = getXMLfilesFromSection($modID, $dataFolder, "Files")
	; Fix array count
	_ArrayInsert($aFiles,0, UBound($aFiles))

	; Removed Files
	writeLogEchoToConsole("[Info]: Reading Removed section" & @CRLF)
	$aRemovedFiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")

	; Add a row
	ReDim  $aRemovedFiles[UBound($aRemovedFiles) + 1][5]
	; Fix array count
	$aRemovedFiles[0][0] = UBound($aRemovedFiles) - 1



	; Compressed Files
	writeLogEchoToConsole("[Info]: Calculating Compressed files section" & @CRLF & @CRLF)
	$aCompressedFiles = getCompressedFilesInfo($modID, $dataFolder)




	; Open a new xml document for writing
	$hFile = FileOpen(@ScriptDir & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml", 10) ; erase + create dir
		If $hFile = -1 Then
			writeLogEchoToConsole("[ERROR]: Unable to create - " & @ScriptDir & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml" & @CRLF)
			MsgBox(48, "Error creating xml document", "Unable to create xml document:" & @CRLF & @ScriptDir & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml")
			Exit
		EndIf


		; XML Header
		writeLogEchoToConsole("[Info]: Creating final " & $modID & ".xml document" & @CRLF)
		FileWriteLine($hFile,'<ModPack version="1.0">')


		; Write Removed section
		writeLogEchoToConsole("[Info]: Writing removed section" & @CRLF)
		WriteSection($hFile, "Removed", $aRemovedFiles)


		; Write Files section
		writeLogEchoToConsole("[Info]: Writing Files section" & @CRLF)
		WriteSection($hFile, "Files", $aFiles)


		; Write Files section
		writeLogEchoToConsole("[Info]: Writing Compressed section" & @CRLF)
		WriteSection($hFile, "Compressed", $aCompressedFiles)

		; Close XML Header
		FileWriteLine($hFile,'</ModPack>')

	; Close xml document
	FileClose($hFile)

	writeLogEchoToConsole("[Info]: Finnished writing final " & $modID & ".xml" & @CRLF)

EndFunc