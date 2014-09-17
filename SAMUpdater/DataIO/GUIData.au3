#include-once
#include <Array.au3>
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"

Opt('MustDeclareVars', 1)

; #FUNCTION# ====================================================================================================================
; Name ..........: loadGUIMD5List
; Description ...: Download GUI.xml and return specified form's MD5 file list
; Syntax ........: loadPackList($packsURL, $dataFolder)
; Parameters ....: $guiURL        	    - URL location to gui.xml
;                  $dataFolder          - Application data folder
;				   $guiID				- The xml node in GUI.xml to return
; Return values .: XML document
; Author ........: Error_998
; Modified ......:
; Remarks .......: $guiID is used to return a specific forms data, GUI.XML can contain more than 1 forms data
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func loadGUIMD5List($guiURL, $dataFolder, $guiID)
	Local $xml
	Local $MD5ListXML

	; Download gui.xml
	downloadFile($guiURL, $dataFolder & "\PackData\GUI\GUI.xml")

	; Load and parse gui.xml
	$xml = loadXML($dataFolder& "\PackData\GUI\GUI.xml")

	; Array for each modpack
	$MD5ListXML = getElements($xml, $guiID)


	Return $MD5ListXML

EndFunc




Func initGUImodSelection($baseURL, $dataFolder)
	local $MD5ListXML
	Local $path
	Local $url
	Local $hash

	; Get list of MD5 hashes from gui.xml
	$MD5ListXML = loadGUIMD5List($baseURL & "/gui/gui.xml", $dataFolder, "ModPackSelection")


	; Download background.jpg
	$url = $baseURL & "/gui/background.jpg"
	$path = "\PackData\GUI\background.jpg"
	$hash = getElement($MD5ListXML[1], "BackgroundMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaulticon.jpg
	$url = $baseURL & "/gui/defaulticon.jpg"
	$path = "\PackData\GUI\defaulticon.jpg"
	$hash = getElement($MD5ListXML[1], "DefaultIconMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultsplash.jpg
	$url = $baseURL & "/gui/defaultsplash.jpg"
	$path = "\PackData\GUI\defaultsplash.jpg"
	$hash = getElement($MD5ListXML[1], "DefaultSplashMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)


	; Download defaultdescription.rtf
	$url = $baseURL & "/gui/defaultdescription.rtf"
	$path = "\PackData\GUI\defaultdescription.rtf"
	$hash = getElement($MD5ListXML[1], "DefaultDescriptionMD5")

	verifyAndDownload($url, $path, $dataFolder, $hash)

	ConsoleWrite("[Info]: Initialized" & @CRLF & @CRLF)

EndFunc


