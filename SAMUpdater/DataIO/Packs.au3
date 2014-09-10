#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
Opt('MustDeclareVars', 1)



; #FUNCTION# ====================================================================================================================
; Name ..........: loadPackList
; Description ...: Download and load Packs.xml
; Syntax ........: loadPackList($packsURL, $dataFolder)
; Parameters ....: $packsURL            - URL location to Packs.xml
;                  $dataFolder          - Application data folder
; Return values .: XML document
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func loadPackList($packsURL, $dataFolder)
	Local $xml
	Local $modpacksXML

	; Download Packs.xml
	ConsoleWrite("[Info]: Downloading mod pack list" & @CRLF)
	downloadFile($packsURL, $dataFolder & "\PackData\Packs.xml")

	; Load and parse Packs.xml
	$xml = loadXML($dataFolder& "\PackData\Packs.xml")

	; Array for each modpack
	$modpacksXML = getElements($xml, "ModPack")


	Return $modpacksXML

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: parseModpack
; Description ...:
; Syntax ........: parseModpack($packsURL, $dataFolder)
; Parameters ....: $packsURL            - URL location to Packs.xml
;                  $dataFolder          - Application data folder
; Return values .: 2 dimentional array	- Dim 1 = Modpack
;										- Dim 2 = All modpack elements (10)
; Author ........: Error_998
; Modified ......:
; Remarks .......: Zero based 2d array holding mod modpacks, modpack elements
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func parseModpack($packsURL, $dataFolder)
	Local $modpacksXML


	; Load Packs.xml
	$modpacksXML = loadPackList($packsURL, $dataFolder)


	; Zero based 2d array holding mod modpacks, modpack elements
	Dim $modpacks[ $modpacksXML[0] ][10]
	ConsoleWrite("[Info]: " & UBound($modpacks) & " Modpacks available" & @CRLF)


	; Store all elemetns
	For $i = 0 To (UBound($modpacks) - 1)
		$modpacks[$i][0] = getElement($modpacksXML[$i + 1], "ModPackID")
		$modpacks[$i][1] = getElement($modpacksXML[$i + 1], "ModPackName")
		$modpacks[$i][2] = getElement($modpacksXML[$i + 1], "ServerVersion")
		$modpacks[$i][3] = getElement($modpacksXML[$i + 1], "NewsPage")
		$modpacks[$i][4] = getElement($modpacksXML[$i + 1], "ModPackIcon")
		$modpacks[$i][5] = getElement($modpacksXML[$i + 1], "Description")
		$modpacks[$i][6] = getElement($modpacksXML[$i + 1], "ServerConnection")
		$modpacks[$i][7] = getElement($modpacksXML[$i + 1], "ForgeID")
		$modpacks[$i][8] = getElement($modpacksXML[$i + 1], "URL")
		$modpacks[$i][9] = getElement($modpacksXML[$i + 1], "Active")
	Next

	Return $modpacks

EndFunc