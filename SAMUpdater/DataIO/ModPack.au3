#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
;#include "FileState.au3"

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
		$aXMLFiles[$i][3] = getElement($fileXML[$i + 1], "md5")
		$aXMLFiles[$i][4] = getElement($fileXML[$i + 1], "Size")
	Next

	Return $aXMLFiles
EndFunc



;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: _GetFileInfos
;~ ; Description ...: Internal function to convert a 1d file array to a 2d section modpack.xml file format
;~ ; Syntax ........: _GetFileInfos($path, $aFiles)
;~ ; Parameters ....: $path                - Path of where the recursion started.
;~ ;                  $aFiles              - An array of files
;~ ; Return values .: 2d array ontaining file info in <modID>.xml format
;~ ; Author ........: Error_998
;~ ; Modified ......:
;~ ; Remarks .......: If the file array is function will also return an array with index 0 set to 0
;~ ; Related .......: Internal function for WriteModpack()
;~ ; Link ..........:
;~ ; Example .......: No
;~ ; ===============================================================================================================================
;~ Func _GetFileInfos($path, $aFiles)
;~ 	; Return 0 filled array if aFiles contain no files
;~ 	If $aFiles[0] = 0 Then
;~ 		Dim $aFileInfo[1][5]
;~ 		$aFileInfo[0][0] = 0
;~ 		Return $aFileInfo
;~ 	EndIf


;~ 	Dim $aFileInfo[ $aFiles[0] + 1 ][5]

;~ 	; Startup crypt libary to speedup hash generation
;~ 	 _Crypt_Startup()

;~ 	; Calculate info section for each file
;~ 	For $i =  1 To $aFiles[0]
;~ 		$aFileInfo[$i][0] =	getFilename($path & "\" & $aFiles[$i])
;~ 		$aFileInfo[$i][1] = "FALSE"
;~ 		$aFileInfo[$i][2] = getPath($aFiles[$i])

;~ 		; Only perform file operations if the file exist
;~ 		If FileExists($path & "\" & $aFiles[$i]) Then
;~ 			$aFileInfo[$i][3] = _Crypt_HashFile($path &  "\" & $aFiles[$i], $CALG_MD5)
;~ 			$aFileInfo[$i][4] = getFileSize($path & "\" & $aFiles[$i])

;~ 		Else
;~ 			; Fill with black values since the file does not exist
;~ 			$aFileInfo[$i][3] = ""
;~ 			$aFileInfo[$i][4] = ""
;~ 		EndIf

;~ 	Next

;~ 	; Close the crypt libary to free resources
;~ 	_Crypt_Shutdown()

;~ 	$aFileInfo[0][0] = $aFiles[0]


;~ 	Return $aFileInfo
;~ EndFunc



;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: getRemovedSourceFiles
;~ ; Description ...: Calculate an array containing all the removed files that was ever part of the modpack
;~ ; Syntax ........: getRemovedSourceFiles($modID, $pathToSourceFiles)
;~ ; Parameters ....: $modID               - modID, also used with the location of the <modID>.xml file
;~ ;                  $pathToSourceFiles   - Path to the source files of the current mod state
;~ ; Return values .: A one dimentional array containing the full path and filenames of all removed files. Index 0 = file count
;~ ; Author ........: Error_998
;~ ; Modified ......:
;~ ; Remarks .......: If no files where ever removed, return a one dimentional array with index 0 = 0
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: No
;~ ; ===============================================================================================================================
;~ Func getRemovedSourceFiles($modID, $dataFolder, $aSourceFiles)
;~ 	; <modID>.xml does not exist return an empty filled array to prevent null error
;~ 	If Not FileExists($dataFolder & "\PackData\Modpacks\" & $modID & "\Data\" & $modID & ".xml") Then

;~ 		Dim $aRemovedSourceFiles [1]
;~ 		$aRemovedSourceFiles[0] = 0

;~ 		ConsoleWrite("[Info]: 0 Files are marked for removal in " & $modID & ".xml" & @CRLF)
;~ 		Return $aRemovedSourceFiles
;~ 	EndIf


;~ 	Dim $aRemovedSourceFiles		; Removed source files when comparing current files with xml files
;~ 	Dim $aRemovedXMLfiles			; File array of removed files from XML file
;~ 	Dim $removedXMLfiles			; XML files array for removed files
;~ 	Dim $aCurrentXMLFiles			; XML files array of current files
;~ 	Dim $aUnchangedFiles[1]			; Unused but needed by GetDiff


;~ 	; Read removed files already saved in <modID>.xml
;~ 	$removedXMLfiles = getXMLfilesFromSection($modID, $dataFolder, "Removed")

;~ 	; Convert the XML files to aFiles array
;~ 	$aRemovedXMLfiles = convertXMLfilesToaFiles($removedXMLfiles)
;~ 	ConsoleWrite("[Info]: " & $aRemovedXMLfiles[0] & " Files are marked for removal in " & $modID & ".xml" & @CRLF & @CRLF)


;~ 	ConsoleWrite("[Info]: Calculate removed files between " & $modID & ".xml" & " and current files" & @CRLF)
;~ 	; Get current files from <modID>.xml
;~ 	$aCurrentXMLFiles = convertXMLfilesToaFiles( getXMLfilesFromSection($modID, $dataFolder, "Files"))


;~ 	; Calculate removed files bewteen current modpack state and <modID>.xml
;~ 	$aRemovedSourceFiles = GetDiff($aSourceFiles, $aCurrentXMLFiles, $aUnchangedFiles)
;~ 	ConsoleWrite("[Info]: " & $aRemovedSourceFiles[0] & " New files are marked for removal" & @CRLF & @CRLF)


;~ 	; Merge the exsisting and newly removed files
;~ 	for $i = 1 To $aRemovedXMLfiles[0]
;~ 		_ArrayAdd($aRemovedSourceFiles, $aRemovedXMLfiles[$i])
;~ 	Next

;~ 	; Adjust new file count
;~ 	$aRemovedSourceFiles[0] = UBound($aRemovedSourceFiles) - 1


;~ 	Return $aRemovedSourceFiles
;~ EndFunc




;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: convertXMLfilesToaFiles
;~ ; Description ...: Convert a XML files array to a aFiles array (convert <modID>.xml file section to the same format as returned
;~ ;				   by the recurseFolder function)
;~ ; Syntax ........: convertXMLfilesToaFiles($aXMLFiles)
;~ ; Parameters ....: $aXMLFiles           - An array of XMLFiles section array.
;~ ; Return values .: An 2d array of files, Index 0 = file count
;~ ; Author ........: Error_998
;~ ; Modified ......:
;~ ; Remarks .......:
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: No
;~ ; ===============================================================================================================================
;~ Func convertXMLfilesToaFiles($aXMLFiles)
;~ 	; If no files exsit return a 0 array to prevent Null errors
;~ 	If UBound($aXMLFiles) = 0 Then
;~ 		Dim $aFiles[1]
;~ 		$aFiles[0] = 0

;~ 		Return $aFiles
;~ 	EndIf


;~ 	; Dynamic array just big enought to store all files + file count in index 0
;~ 	Dim $aFiles[ UBound($aXMLFiles) + 1]


;~ 	; Index 0 contains number of files
;~ 	$aFiles[0] = UBound($aXMLFiles)

;~ 	for $i =  1 to UBound($aXMLFiles)
;~ 		If $aXMLFiles[$i - 1][2] = "" Then
;~ 			; Path is blank
;~ 			$aFiles[$i] = $aXMLFiles[$i - 1][0]
;~ 		Else
;~ 			; Include path
;~ 			$aFiles[$i] = $aXMLFiles[$i - 1][2] & "\" & $aXMLFiles[$i - 1][0]
;~ 		EndIf
;~ 	Next


;~ 	Return $aFiles
;~ EndFunc



;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name ..........: getTotalModpackFilesizeFromXML
;~ ; Description ...: Calculates the total filesize in bytes of the Files section of <modID>.xml
;~ ; Syntax ........: getTotalModpackFilesizeFromXML($modID, $dataFolder)
;~ ; Parameters ....: $modID               - The modID
;~ ;                  $dataFolder          - Application data flder
;~ ; Return values .: total filesize of modpack in bytes
;~ ; Author ........: Error_998
;~ ; Modified ......:
;~ ; Remarks .......:
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: No
;~ ; ===============================================================================================================================
;~ Func getTotalModpackFilesizeFromXML($modID, $dataFolder)
;~ 	Local $currentXMLFiles
;~ 	Local $totalSize = 0

;~ 	; Get all the file info of the current files
;~ 	$currentXMLFiles = getXMLfilesFromSection($modID, $dataFolder, "Files")

;~ 	; Calculate total file size
;~ 	For $i =  0 to UBound($currentXMLFiles) - 1
;~ 		$totalSize = $totalSize + $currentXMLFiles[$i][4]
;~ 	Next

;~ 	Return $totalSize
;~ EndFunc