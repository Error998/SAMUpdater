#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)

; #FUNCTION# ====================================================================================================================
; Name ..........: loadAssetHashList
; Description ...: Download assets.xml and return specified assetID's MD5 file list
; Syntax ........: loadAssetHashList($assetsURL, $dataFolder, [$dontDownload = false])
; Parameters ....: $assetsURL      	    - URL location to assets.xml
;                  $dataFolder          - Application data folder
;				   $assetID				- The xml node in assets.xml to return
;				   $dontDownload		- (Optional) Set to True to not redownload the assset.xml file
; Return values .: XML document
; Author ........: Error_998
; Modified ......:
; Remarks .......: $assetID is used to return a specific asset groups data, assets.xml can contain more than 1 asset group
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func loadAssetHashList($assetURL, $dataFolder, $assetID, $dontDownload = False)
	Local $xml
	Local $hashListXML

	; Should we redownload assets.xml
	If $dontDownload = False And $isOnline = True Then
		; Download assets.xml
		downloadFile($assetURL, $dataFolder & "\PackData\Assets\assets.xml")
	EndIf


	; Load and parse assets.xml
	$xml = loadXML($dataFolder & "\PackData\Assets\assets.xml")

	; Array for selected asset group
	$hashListXML = getElements($xml, $assetID)

	Return $hashListXML

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: initSoundAssets
; Description ...: Check if local sound assets match remote assets if not download remote assets
; Syntax ........: initSoundAssets($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URL location for the assets
;                  $dataFolder          - Application data folder
; Return values .: Background sound play lenght in seconds
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initSoundAssets($baseURL, $dataFolder)
	local $hashListXML
	Local $path
	Local $url
	Local $hash
	Local $backgroundPlayLenght

	writeLogEchoToConsole("[Info]: Initializing Sound data" & @CRLF)


	; Get list of hashes from assets.xml
	$hashListXML = loadAssetHashList($baseURL & "/packdata/assets/assets.xml", $dataFolder, "Sounds")

	; Download background.mp3
	$url = $baseURL & "/packdata/assets/sounds/background.mp3"
	$path = "\PackData\Assets\Sounds\background.mp3"
	$hash = getElement($hashListXML[1], "BackgroundMusicSHA1")

	; Download background music with a retry count of 5 and display progress indicator
	if $isOnline Then
		verifyAndDownload($url, $path, $dataFolder, $hash, 5, True)
	EndIf

	$backgroundPlayLenght = getElement($hashListXML[1], "BackgroundMusicPlayLenght")

	writeLogEchoToConsole("[Info]: Initialized" & @CRLF & @CRLF)


	Return $backgroundPlayLenght
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: initGUImodSelectionAssets
; Description ...: Check if local GUImodSelection assets match remote assets if not download remote assets
; Syntax ........: initGUImodSelectionAssets($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URLlocation for the assets.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initGUImodSelectionAssets($baseURL, $dataFolder)
	local $hashListXML
	Local $path
	Local $url
	Local $hash


	; Get list of hashes from assets.xml
	$hashListXML = loadAssetHashList($baseURL & "/packdata/assets/assets.xml", $dataFolder, "ModPackSelection")


	; Download background.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/background.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\background.jpg"
	$hash = getElement($hashListXML[1], "BackgroundSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaulticon.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaulticon.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaulticon.jpg"
	$hash = getElement($hashListXML[1], "DefaultIconSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultsplash.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultsplash.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	$hash = getElement($hashListXML[1], "DefaultSplashSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultdescription.rtf
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultdescription.rtf"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"
	$hash = getElement($hashListXML[1], "DefaultDescriptionSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)



EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: initGUIadvInfoAssets
; Description ...: Check if local GUIadvInfo assets match remote assets if not download remote assets
; Syntax ........: initGUIadvInfoAssets($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URLlocation for the assets.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initGUIadvInfoAssets($baseURL, $dataFolder)
	local $hashListXML
	Local $path
	Local $url
	Local $hash


	; Get list of hashes from assets.xml
	$hashListXML = loadAssetHashList($baseURL & "/packdata/assets/assets.xml", $dataFolder, "AdvInfo")


	; Download please wait background
	$url = $baseURL & "/packdata/assets/gui/advinfo/plswaitbackground.jpg"
	$path = "\PackData\Assets\GUI\AdvInfo\plswaitbackground.jpg"
	$hash = getElement($hashListXML[1], "PleaseWaitBackgroundSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download AdvInfo GUI background
	$url = $baseURL & "/packdata/assets/gui/advinfo/background.jpg"
	$path = "\PackData\Assets\GUI\AdvInfo\background.jpg"
	$hash = getElement($hashListXML[1], "BackgroundSHA1")

	verifyAndDownload($url, $path, $dataFolder, $hash)

EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: initGUIAssets
; Description ...: Initialize all GUI assets (backgrounds, pictures, descriptions, etc.)
; Syntax ........: initGUIAssets($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URLlocation for the assets
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initGUIAssets($baseURL, $dataFolder)

	; Skip if offline
	If Not $isOnline Then
		writeLogEchoToConsole("[Info]: Offline, skipping GUI asset downloads" & @CRLF & @CRLF)
		Return
	EndIf



	writeLogEchoToConsole("[Info]: Initializing GUI assets" & @CRLF)


	; Initialize ModSelection GUI assets, download default files and background.
	initGUImodSelectionAssets($baseURL, $dataFolder)



	; Initialize Advanced Info GUI assets
	initGUIadvInfoAssets($baseURL, $dataFolder)



	writeLogEchoToConsole("[Info]: GUI assets initialized" & @CRLF & @CRLF)
EndFunc
