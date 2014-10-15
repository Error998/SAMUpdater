#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\..\SAMUpdater\DataIO\XML.au3"
#include "..\..\SAMUpdater\DataIO\Download.au3"
Opt('MustDeclareVars', 1)



; #FUNCTION# ====================================================================================================================
; Name ..........: loadXMLfileSection
; Description ...: Read <modID>.xml and return a specific file section
; Syntax ........: loadFileList($modpackURL, $dataFolder, $modID)
; Parameters ....: $modID				- modID
;				   $dataFolder 			- Application data folder
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
	$xml = loadXML($dataFolder & "\PackData\Modpacks\" & $modID & "\" & $modID & ".xml")

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
		$aXMLFiles[$i][3] = getElement($fileXML[$i + 1], "md5")
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
	FileWriteLine($hFile, @TAB & '<' & $section & '>')

	; Write file info
	For $i = 1 To $aSectionFileInfo[0][0]
		FileWriteLine($hFile, @TAB & @TAB & '<File>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Filename>' & $aSectionFileInfo[$i][0] & '</Filename>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Extract>' & $aSectionFileInfo[$i][1] & '</Extract>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Path>' & $aSectionFileInfo[$i][2] & '</Path>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<md5>' & $aSectionFileInfo[$i][3] & '</md5>')
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
	$hFile = FileOpen(@ScriptDir & "\PackData\Modpacks\" & $modPackID & "\" & $modPackID & ".xml", 10) ; erase + create dir
	If $hFile = -1 Then
		ConsoleWrite("[ERROR]: Unable to create - " & @ScriptDir & "\PackData\Modpacks\" & $modPackID & "\" & $modPackID & ".xml" & @CRLF)
		MsgBox(48, "Error creating xml document", "Unable to create xml document:" & @CRLF & @ScriptDir & "\PackData\Modpacks\" & $modPackID & "\" & $modPackID & ".xml")
		Exit
	EndIf


		; XML Header
		ConsoleWrite("[Info]: Creating " & $modPackID & ".xml document" & @CRLF)
		FileWriteLine($hFile,'<ModPack version="1.0">')


		; Get removed files info
		$aFilesWithFileInfo = _GetFileInfos($path, $aRemovedFiles)

		; Write Removed section
		ConsoleWrite("[Info]: Writing removed section" & @CRLF)
		WriteSection($hFile, "Removed", $aFilesWithFileInfo)


		; Get server files info
		$aFilesWithFileInfo = _GetFileInfos($path, $aFiles)

		; Write Files section
		ConsoleWrite("[Info]: Writing Files section" & @CRLF)
		WriteSection($hFile, "Files", $aFilesWithFileInfo)



		; Close XML Header
		FileWriteLine($hFile,'</ModPack>')

	; Close xml document
	FileClose($hFile)

	ConsoleWrite("[Info]: Finnished writing " & $modPackID & ".xml" & @CRLF)


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
	If $aFiles[0] = 0 Then
		Dim $aFileInfo[1][5]
		$aFileInfo[0][0] = 0

	Else
		Dim $aFileInfo[ $aFiles[0] + 1 ][5]

		; Startup crypt libary to speedup hash generation
		 _Crypt_Startup()

		; Calculate info section for each file
		For $i =  1 To $aFiles[0]
			$aFileInfo[$i][0] =	getFilename($path & "\" & $aFiles[$i])
			$aFileInfo[$i][1] = "FALSE"
			$aFileInfo[$i][2] = getPath($aFiles[$i])
			$aFileInfo[$i][3] = _Crypt_HashFile($path &  "\" & $aFiles[$i], $CALG_MD5)
			$aFileInfo[$i][4] = getFileSize($path & "\" & $aFiles[$i])
		Next

		; Close the crypt libary to free resources
		_Crypt_Shutdown()

		$aFileInfo[0][0] = $aFiles[0]
	EndIf

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
Func getRemovedSourceFiles($modID, $pathToSourceFiles)
	; Read removed files already saved in <modID>.xml

	; Calculate removed files bewteen current server state and <modID>.xml


	; Merge the exsisting and newly removed files


	; If above calulations return no files return an empty filled array to prevent null error
	Dim $aRemovedSourceFiles [1]
	$aRemovedSourceFiles[0] = 0

	Return $aRemovedSourceFiles
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
Func saveModpack($modID, $pathToSourceFiles)
	Dim $aSourceFiles
	Dim $aRemovedSourceFiles

	; Get server files
	$aSourceFiles = recurseFolders($pathToSourceFiles)
	ConsoleWrite("[Info]: Source File Count: " & UBound($aSourceFiles) - 1 & @CRLF)


	; ****** Get Removed Files **********
	$aRemovedSourceFiles = getRemovedSourceFiles($modID, $pathToSourceFiles)


	; Write <modID>.xml
	WriteModpack($modID, $pathToSourceFiles, $aSourceFiles, $aRemovedSourceFiles)
EndFunc



Func readModpack($modID, $dataFolder)



EndFunc