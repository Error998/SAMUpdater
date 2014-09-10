#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
Opt('MustDeclareVars', 1)



; #FUNCTION# ====================================================================================================================
; Name ..........: loadFileList
; Description ...: Download and load <modID>.xml
; Syntax ........: loadFileList($modpackURL, $dataFolder, $modID)
; Parameters ....: $modpackURL			- URL location to <modID>.xml
;                  $dataFolder 			- Application data folder
;				   $modID				- Unique ModID
;
; Return values .: XML array holding each File section
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func loadFileList($modpackURL, $dataFolder, $modID, $section)
	Local $xml
	Dim $fileSectionXML[4]

	; Download <modID>.xml
	ConsoleWrite("[Info]: Downloading modpack file list" & @CRLF)
	downloadFile($modpackURL, $dataFolder & "\PackData\" & $modID & "\" & $modID & ".xml")

	; Load and parse Packs.xml
	$xml = loadXML($dataFolder& "\PackData\" & $modID & "\" & $modID & ".xml")

	; Array for each file section
	$fileSectionXML[1] = getElements($xml, "Removed")
	$fileSectionXML[2] = getElements($xml, "Added")
	$fileSectionXML[3] = getElements($xml, "Changed")
	$fileSectionXML[4] = getElements($xml, "Unchanged")

	Return $fileSectionXML
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: parseFileList
; Description ...:
; Syntax ........: parseFileList($modpackURL, $dataFolder, $modID)
; Parameters ....: $modpackURL          - URL location to <modID>.xml
;                  $dataFolder          - Application data folder
; Return values .: 2 dimentional array	- Dim 1 = Modpack
;										- Dim 2 = All modpack elements (10)
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func parseFileList($modpackURL, $dataFolder, $modID, $section)
	Local $fileSectionXML

	; Load <modID>.xml
	$fileSectionXML = loadFileList($modpackURL, $dataFolder, $modID, $section)

	; Zero based 2d array holding mod modpacks, modpack elements
	Dim $modpackFiles[3][ $modpacksXML[0] ][5]
	ConsoleWrite("[Info]: " & UBound($modpacks) & " Modpacks available" & @CRLF)





	; Store all elemetns
	For $i = 0 To (UBound($modpacks) - 1)
		$modpacks[$i][0] = getElement($modpacksXML[$i + 1], "Filename")
		$modpacks[$i][1] = getElement($modpacksXML[$i + 1], "Extract")
		$modpacks[$i][2] = getElement($modpacksXML[$i + 1], "Path")
		$modpacks[$i][3] = getElement($modpacksXML[$i + 1], "md5")
		$modpacks[$i][4] = getElement($modpacksXML[$i + 1], "Size")
	Next

	Return $modpacks
EndFunc