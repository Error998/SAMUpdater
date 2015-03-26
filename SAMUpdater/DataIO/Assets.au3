#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)

; #FUNCTION# ====================================================================================================================
; Name ..........: initAssetSettings
; Description ...: Downloads assets.cfg
; Syntax ........: initAssetSettings($baseURL, $dataFolder)
; Parameters ....: $baseURL             - Base URL location for the assets.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Must be called before playing background music, or file must already exist
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initAssetSettings($baseURL, $dataFolder)

	; Download assets.cfg
	If $isOnline Then
		writeLogEchoToConsole("[Info]: Initializing Asset configuration" & @CRLF)
		downloadFile($baseURL & "/packdata/assets/assets.cfg", $dataFolder & "\PackData\Assets\assets.cfg")
	EndIf

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


	; Download assets.cfg
	initAssetSettings($baseURL, $dataFolder)



	writeLogEchoToConsole("[Info]: Initializing Sound data" & @CRLF)


	; Download background.mp3
	$url = $baseURL & "/packdata/assets/sounds/background.mp3"
	$path = "\PackData\Assets\Sounds\background.mp3"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "Sounds", "BackgroundMusicSHA1", "")

	; Download background music with a retry count of 5 and display progress indicator
	if $isOnline Then
		verifyAndDownload($url, $path, $dataFolder, $hash, 5, True)
	EndIf

	$backgroundPlayLenght = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "Sounds", "BackgroundMusicPlayLenght", "10")

	writeLogEchoToConsole("[Info]: Initialized" & @CRLF & @CRLF)


	Return $backgroundPlayLenght
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: initGUIPackSelectionAssets
; Description ...: Check if local GUIPackSelection assets match remote assets if not download remote assets
; Syntax ........: initGUIPackSelectionAssets($baseURL, $dataFolder)
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
Func initGUIPackSelectionAssets($baseURL, $dataFolder)
	local $hashListXML
	Local $path
	Local $url
	Local $hash


	; Download background.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/background.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\background.jpg"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "PackSelectionGUI", "BackgroundSHA1", "")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaulticon.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaulticon.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaulticon.jpg"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "PackSelectionGUI", "DefaultIconSHA1", "")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultsplash.jpg
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultsplash.jpg"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultsplash.jpg"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "PackSelectionGUI", "DefaultSplashSHA1", "")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultdescription.rtf
	$url = $baseURL & "/packdata/assets/gui/modpackselection/defaultdescription.rtf"
	$path = "\PackData\Assets\GUI\ModpackSelection\defaultdescription.rtf"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "PackSelectionGUI", "DefaultDescriptionSHA1", "")

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


	; Download please wait background
	$url = $baseURL & "/packdata/assets/gui/advinfo/plswaitbackground.jpg"
	$path = "\PackData\Assets\GUI\AdvInfo\plswaitbackground.jpg"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "AdvInfoGUI", "PleaseWaitBackgroundSHA1", "")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download AdvInfo GUI background
	$url = $baseURL & "/packdata/assets/gui/advinfo/background.jpg"
	$path = "\PackData\Assets\GUI\AdvInfo\background.jpg"
	$hash = IniRead($dataFolder &  "\PackData\Assets\assets.cfg", "AdvInfoGUI", "BackgroundSHA1", "")

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


	; Initialize Pack Selection GUI assets, download default files and background.
	initGUIPackSelectionAssets($baseURL, $dataFolder)



	; Initialize Advanced Info GUI assets
	initGUIadvInfoAssets($baseURL, $dataFolder)



	writeLogEchoToConsole("[Info]: GUI assets initialized" & @CRLF & @CRLF)
EndFunc
