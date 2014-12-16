#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)

; #FUNCTION# ====================================================================================================================
; Name ..........: loadAssetMD5List
; Description ...: Download assets.xml and return specified assetID's MD5 file list
; Syntax ........: loadAssetMD5List($assetsURL, $dataFolder, [$dontDownload = false])
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
Func loadAssetMD5List($assetURL, $dataFolder, $assetID, $dontDownload = False)
	Local $xml
	Local $MD5ListXML

	; Should we redownload assets.xml
	If $dontDownload = False Then
		; Download assets.xml
		downloadFile($assetURL, $dataFolder & "\PackData\Assets\assets.xml")
	EndIf


	; Load and parse assets.xml
	$xml = loadXML($dataFolder & "\PackData\Assets\assets.xml")

	; Array for selected asset group
	$MD5ListXML = getElements($xml, $assetID)

	Return $MD5ListXML

EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: initSoundAssets
; Description ...: Check if local sound assets match remote assets if not download remote assets
; Syntax ........: initSoundAssets($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URL location for the assets
;                  $dataFolder          - Application data folder
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initSoundAssets($baseURL, $dataFolder)
	local $MD5ListXML
	Local $path
	Local $url
	Local $hash

	; Get list of MD5 hashes from assets.xml
	$MD5ListXML = loadAssetMD5List($baseURL & "/packdata/assets/assets.xml", $dataFolder, "Sounds")


	; Download background.mp3
	$url = $baseURL & "/packdata/assets/sounds/background.mp3"
	$path = "\PackData\Assets\Sounds\background.mp3"
	$hash = getElement($MD5ListXML[1], "BackgroundMusicMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)
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
	local $MD5ListXML
	Local $path
	Local $url
	Local $hash

	writeLogEchoToConsole("[Info]: Initializing GUI assests" & @CRLF)


	; Get list of MD5 hashes from assets.xml
	$MD5ListXML = loadAssetMD5List($baseURL & "/packdata/assets/assets.xml", $dataFolder, "ModPackSelection")


	; Download background.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/background.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\background.jpg"
	$hash = getElement($MD5ListXML[1], "BackgroundMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaulticon.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaulticon.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaulticon.jpg"
	$hash = getElement($MD5ListXML[1], "DefaultIconMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultsplash.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultsplash.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	$hash = getElement($MD5ListXML[1], "DefaultSplashMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultdescription.rtf
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultdescription.rtf"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"
	$hash = getElement($MD5ListXML[1], "DefaultDescriptionMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)

	writeLogEchoToConsole("[Info]: GUI assets initialized" & @CRLF & @CRLF)

EndFunc


