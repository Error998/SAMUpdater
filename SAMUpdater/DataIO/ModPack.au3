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



