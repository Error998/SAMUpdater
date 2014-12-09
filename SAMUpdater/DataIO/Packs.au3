#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
#include "..\DataIO\Folders.au3"

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
; Name ..........: parsePacks
; Description ...:
; Syntax ........: parsePacks($packsURL, $dataFolder)
; Parameters ....: $packsURL            - URL location to Packs.xml
;                  $dataFolder          - Application data folder
; Return values .: 2 dimentional array	- Dim 1 = Modpack
;										- Dim 2 = All modpack elements (12)
; Author ........: Error_998
; Modified ......:
; Remarks .......: Zero based 2d array holding mod modpacks, modpack elements
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func parsePacks($packsURL, $dataFolder)
	Local $modpacksXML


	; Load Packs.xml
	$modpacksXML = loadPackList($packsURL, $dataFolder)


	; Zero based 2d array holding mod modpacks, modpack elements
	Global $modpacks[ $modpacksXML[0] ][14]
	ConsoleWrite("[Info]: Modpacks available: " & UBound($modpacks) & @CRLF & @CRLF)


	; Store all elemetns
	For $i = 0 To ($modpacksXML[0] - 1)
		$modpacks[$i][0] = getElement($modpacksXML[$i + 1], "ModPackID")
		$modpacks[$i][1] = getElement($modpacksXML[$i + 1], "ModPackName")
		$modpacks[$i][2] = getElement($modpacksXML[$i + 1], "ModPackVersion")
		$modpacks[$i][3] = getElement($modpacksXML[$i + 1], "GameVersion")
		$modpacks[$i][4] = getElement($modpacksXML[$i + 1], "Description")
		$modpacks[$i][5] = getElement($modpacksXML[$i + 1], "DescriptionMD5")
		$modpacks[$i][6] = getElement($modpacksXML[$i + 1], "ModPackIcon")
		$modpacks[$i][7] = getElement($modpacksXML[$i + 1], "ModPackIconMD5")
		$modpacks[$i][8] = getElement($modpacksXML[$i + 1], "ModPackSplash")
		$modpacks[$i][9] = getElement($modpacksXML[$i + 1], "ModPackSplashMD5")
		$modpacks[$i][10] = getElement($modpacksXML[$i + 1], "ForgeID")
		$modpacks[$i][11] = getElement($modpacksXML[$i + 1], "URL")
		$modpacks[$i][12] = getElement($modpacksXML[$i + 1], "Active")
		$modpacks[$i][13] = parsePath(getElement($modpacksXML[$i + 1], "DefaultInstallFolder"))
	Next

	Return $modpacks

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: initModpackFolders
; Description ...: Create modpack data and cache folder
; Syntax ........: initModpackFolders($modpacks, $dataFolder)
; Parameters ....: $modpacks            - 2D Array containing Packs.xml
;                  $dataFolder          - Applacations data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initModpackFolders($modpacks, $dataFolder)
	ConsoleWrite("[Info]: Initializing Modpack folders" & @CRLF)

	; Create all modpack folders
	For $i = 0 To (UBound($modpacks) - 1)
		createFolder($dataFolder & "\PackData\ModPacks\" & $modpacks[$i][0] & "\Data")
		createFolder($dataFolder & "\PackData\ModPacks\" & $modpacks[$i][0] & "\Cache")
	Next

	ConsoleWrite("[Info]: Modpack folders initialized" & @CRLF & @CRLF)
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: initModpackFiles
; Description ...: Download all modpack GUI assets
; Syntax ........: initModpackFiles($modpacks, $dataFolder)
; Parameters ....: $modpacks            - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initModpackFiles($modpacks, $dataFolder)
	; Download Modpack description, icon and splash files for each modpack
	Local $url
	Local $path
	Local $hash

	ConsoleWrite("[Info]: Initializing Modpack assets" & @CRLF)

	For $i = 0 To (UBound($modpacks) - 1)

		; Verify local file else download remote Description
		If Not $modpacks[$i][4] = "" Then
			$url = $modpacks[$i][11] & "/packdata/modpacks/" & $modpacks[$i][0] & "/data/" & $modpacks[$i][4]
			$path = "\PackData\Modpacks\" & $modpacks[$i][0] & "\Data\" & $modpacks[$i][4]
			$hash = $modpacks[$i][5]

			verifyAndDownload($url, $path, $dataFolder, $hash)
		EndIf

		; Verify local file else download remote ModPackIcon
		If Not $modpacks[$i][6] = "" Then
			$url = $modpacks[$i][11] & "/packdata/modpacks/" & $modpacks[$i][0] & "/data/" & $modpacks[$i][6]
			$path = "\PackData\Modpacks\" & $modpacks[$i][0] & "\Data\" & $modpacks[$i][6]
			$hash = $modpacks[$i][7]

			verifyAndDownload($url, $path, $dataFolder, $hash)
		EndIf


		; Verify local file else download remote ModPackSplash
		If Not $modpacks[$i][8] = "" Then
			$url = $modpacks[$i][11] & "/packdata/modpacks/" & $modpacks[$i][0] & "/data/" & $modpacks[$i][8]
			$path = "\PackData\Modpacks\" & $modpacks[$i][0] & "\Data\" & $modpacks[$i][8]
			$hash = $modpacks[$i][9]

			verifyAndDownload($url, $path, $dataFolder, $hash)
		EndIf
	Next

	ConsoleWrite("[Info]: Modpack assets initialized" & @CRLF & @CRLF)

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: initModpacks
; Description ...: Create modpack folders and download modpack GUI assets
; Syntax ........: initModpacks($modpacks, $dataFolder)
; Parameters ....: $modpacks            - The modID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initModpacks($modpacks, $dataFolder)
	;Create all needed Modpack folders
	initModpackFolders($modpacks, $dataFolder)


	; Download Modpack files (Icon, splash and description)
	initModpackFiles($modpacks, $dataFolder)

EndFunc