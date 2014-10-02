#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.0.0.7
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "AutoUpdate\AutoUpdate.au3"
#include "DataIO\Folders.au3"
#include "DataIO\Packs.au3"
#include "Sound\Sounds.au3"
#include "DataIO\GUIData.au3"
#include "GUI\frmModpackSelection.au3"

Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.0.0.7"
Const $baseURL = "http://localhost/samupdater"
Const $updateURL = $baseURL & "/version.dat"
Const $musicURL = $baseURL & "/sounds/background.mp3"
Const $packsURL = $baseURL & "/packs.xml"

Global $dataFolder = @AppDataDir & "\SAMUpdater"
Local $modpacks

; ### Init Data Folders ###
ConsoleWrite("[Info]: Initializing folders..." & @CRLF)
createFolder($dataFolder & "\PackData\GUI")
createFolder($dataFolder & "\PackData\Sounds")
ConsoleWrite("[Info]: Folders initialized" & @CRLF & @CRLF)
; #########################


; Check and update SAMUpdater
autoUpdate($version, $updateURL, $dataFolder)


; Play background music
playBackgroundMusic($musicURL, $dataFolder, 22)

; Load and parse Packs.xml, returns 2d array [modpackNum][elements]
$modpacks = parsePacks($packsURL, $dataFolder)

;Initialize all Modpacks, create needed folders, download modpack descriptions, splash and icons
initModpacks($modpacks, $dataFolder)

; Initialize ModSelection GUI, download default files and background.
initGUImodSelection($baseURL, $dataFolder)

; Display Modpack selection GUI
DisplayModpackSelection()


MsgBox(64,"SAMUpdater version " & $version,"Development Mode" &@CRLF & "More stuff comming soon...")

;~ displayGUI()
	; Populate Modpacks
	; Select Modpack
		;Cache Modpack
		;Install Modpack
		;Configure Magic Launcher
		;Create Shortcuts


