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
	Local $packsXML


	; Download Packs.xml
	If $isOnline Then
		writeLogEchoToConsole("[Info]: Downloading pack list" & @CRLF)
		downloadFile($packsURL, $dataFolder & "\PackData\Packs.xml")
	EndIf

	; Load and parse Packs.xml
	$xml = loadXML($dataFolder& "\PackData\Packs.xml")

	; Array for each modpack
	$packsXML = getElements($xml, "Pack")


	Return $packsXML

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
	Local $packsXML
	Local $totalVisiblePacks = 0
	Local $visiblePackNumber = 0
	Local $PackVisible = "False"

	; Load Packs.xml
	$packsXML = loadPackList($packsURL, $dataFolder)


	; Calculate Visible Packs
	For $i =  0 To ($packsXML[0] - 1)
		If getElement($packsXML[$i + 1], "PackVisible") = "True" Then
			$totalVisiblePacks = $totalVisiblePacks + 1
		EndIf
	Next


	; Zero based 2d array holding all visible packs with pack elements
	Global $packs[$totalVisiblePacks][12]
	writeLogEchoToConsole("[Info]: Packs available: " & UBound($packs) & @CRLF & @CRLF)


	; Store all elemetns
	For $i = 0 To ($packsXML[0] - 1)
		$PackVisible = getElement($packsXML[$i + 1], "PackVisible")

		; Skip if Pack is not visible
		If $PackVisible <> "True" Then ContinueLoop

		$packs[$visiblePackNumber][0] = getElement($packsXML[$i + 1], "PackID")
		$packs[$visiblePackNumber][1] = getElement($packsXML[$i + 1], "PackName")
		$packs[$visiblePackNumber][2] = getElement($packsXML[$i + 1], "PackVersion")
		$packs[$visiblePackNumber][3] = getElement($packsXML[$i + 1], "ContentVersion")
		$packs[$visiblePackNumber][4] = getElement($packsXML[$i + 1], "PackDescriptionSHA1")
		$packs[$visiblePackNumber][5] = getElement($packsXML[$i + 1], "PackIconSHA1")
		$packs[$visiblePackNumber][6] = getElement($packsXML[$i + 1], "PackSplashSHA1")
		$packs[$visiblePackNumber][7] = getElement($packsXML[$i + 1], "PackDatabaseSHA1")
		$packs[$visiblePackNumber][8] = getElement($packsXML[$i + 1], "PackConfigSHA1")
		$packs[$visiblePackNumber][9] = getElement($packsXML[$i + 1], "PackRepository")
		$packs[$visiblePackNumber][10] = getElement($packsXML[$i + 1], "PackDownloadable")
		$packs[$visiblePackNumber][11] = getElement($packsXML[$i + 1], "PackVisible")

		$visiblePackNumber = $visiblePackNumber + 1
	Next

	Return $packs

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: initPackFolders
; Description ...: Create pack data and cache folders
; Syntax ........: initPackFolders($packs, $dataFolder)
; Parameters ....: $packs	            - 2D Array containing Packs.xml
;                  $dataFolder          - Applacations data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initPackFolders($packs, $dataFolder)
	writeLogEchoToConsole("[Info]: Initializing pack folders" & @CRLF)

	; Create all pack folders
	For $i = 0 To (UBound($packs) - 1)
		createFolder($dataFolder & "\PackData\ModPacks\" & $packs[$i][0] & "\Data")
		createFolder($dataFolder & "\PackData\ModPacks\" & $packs[$i][0] & "\Cache")
	Next

	writeLogEchoToConsole("[Info]: Pack folders initialized" & @CRLF & @CRLF)
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: initPackFiles
; Description ...: Download all pack GUI assets
; Syntax ........: initPackFiles($packs, $dataFolder)
; Parameters ....: $packs	            - 2D Array containing Packs.xml
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initPackFiles($packs, $dataFolder)
	; Download pack description, icon, splash, PackID.xml and PackID.cfg for each modpack
	Local $url
	Local $path

	Local $PackID
	Local $PackName
	Local $PackVersion
	Local $ContentVersion
	Local $PackDescriptionSHA1
	Local $PackIconSHA1
	Local $PackSplashSHA1
	Local $PackDatabaseSHA1
	Local $PackConfigSHA1
	Local $PackRepository
	Local $PackDownloadable
	Local $PackVisible


	; Skip if offline
	If Not $isOnline Then
		writeLogEchoToConsole("[Info]: Offline, skipping Pack asset download" & @CRLF & @CRLF)
		Return
	EndIf


	writeLogEchoToConsole("[Info]: Initializing Pack assets" & @CRLF)

	For $i = 0 To (UBound($packs) - 1)
		; Assign all Pack elemets
		$PackID = $packs[$i][0]
		$PackName = $packs[$i][1]
		$PackVersion = $packs[$i][2]
		$ContentVersion = $packs[$i][3]
		$PackDescriptionSHA1 = $packs[$i][4]
		$PackIconSHA1 = $packs[$i][5]
		$PackSplashSHA1 = $packs[$i][6]
		$PackDatabaseSHA1 = $packs[$i][7]
		$PackConfigSHA1 = $packs[$i][8]
		$PackRepository = $packs[$i][9]
		$PackDownloadable = $packs[$i][10]
		$PackVisible = $packs[$i][11]


		; Verify local file else download remote Description
		If Not $PackDescriptionSHA1 = "" Then
			$url = $PackRepository & "/packdata/modpacks/" & $PackID & "/data/description.rtf"
			$path = "PackData\Modpacks\" & $PackID & "\Data\description.rtf"

			verifyAndDownload($url, $path, $dataFolder, $PackDescriptionSHA1, 5, True)
		EndIf

		; Verify local file else download remote Pack Icon
		If Not $PackIconSHA1 = "" Then
			$url = $PackRepository & "/packdata/modpacks/" & $PackID & "/data/icon.jpg"
			$path = "PackData\Modpacks\" & $PackID & "\Data\icon.jpg"

			verifyAndDownload($url, $path, $dataFolder, $PackIconSHA1, 5, True)
		EndIf


		; Verify local file else download remote Pack Splash
		If Not $PackSplashSHA1 = "" Then
			$url = $PackRepository & "/packdata/modpacks/" & $PackID & "/data/splash.jpg"
			$path = "PackData\Modpacks\" & $PackID & "\Data\splash.jpg"

			verifyAndDownload($url, $path, $dataFolder, $PackSplashSHA1, 5, True)
		EndIf


		; Verify local file else download remote Pack Database
		$url = $PackRepository & "/packdata/modpacks/" & $PackID & "/data/" & $PackID & ".xml"
		$path = "PackData\Modpacks\" & $PackID & "\Data\" & $PackID & ".xml"

		verifyAndDownload($url, $path, $dataFolder, $PackDatabaseSHA1, 5, True)



		; Verify local file else download remote Pack Config
		$url = $PackRepository & "/packdata/modpacks/" & $PackID & "/data/" & $PackID & ".cfg"
		$path = "PackData\Modpacks\" & $PackID & "\Data\" & $PackID & ".cfg"

		verifyAndDownload($url, $path, $dataFolder, $PackConfigSHA1, 5, True)


	Next

	writeLogEchoToConsole("[Info]: Pack assets initialized" & @CRLF & @CRLF)

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: initPacks
; Description ...: Create pack folders and download pack GUI assets
; Syntax ........: initPacks($packs, $dataFolder)
; Parameters ....: $packs            	- 2d Array containing all the packs and pack data
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initPacks($packs, $dataFolder)
	;Create all needed pack folders
	initPackFolders($packs, $dataFolder)


	; Download pack files (Icon, splash, description, PackID.xml and PackID.cfg)
	initPackFiles($packs, $dataFolder)

EndFunc