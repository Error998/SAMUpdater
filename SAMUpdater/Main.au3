#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=GUI\samupdater.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=SA Minecraft Update Utility
#AutoIt3Wrapper_Res_Fileversion=0.0.1.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "AutoUpdate\AutoUpdate.au3"
#include "DataIO\Folders.au3"
#include "DataIO\Packs.au3"
#include "Sound\Sounds.au3"
#include "DataIO\Assets.au3"
#include "GUI\frmModpackSelection.au3"

Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.0.1.1"
Const $baseURL = "http://localhost/samupdater"
;Const $baseURL = "https://dl.dropboxusercontent.com/u/68260490/Games/Minecraft/SAM/samupdater"
Const $updateURL = $baseURL & "/version.dat"
Const $packsURL = $baseURL & "/packdata/packs.xml"

Global $dataFolder = @AppDataDir & "\SAMUpdater"
Local $modpacks
Local $modpackNum

; ### Init Data Folders ###
ConsoleWrite("[Info]: Initializing folders..." & @CRLF)
createFolder($dataFolder & "\PackData\Assets\GUI\ModpackSelection")
createFolder($dataFolder & "\PackData\Assets\Sounds")
ConsoleWrite("[Info]: Folders initialized" & @CRLF & @CRLF)
; #########################


; Check and update SAMUpdater
autoUpdate($version, $updateURL, $dataFolder)


; Play background music
playBackgroundMusic($dataFolder, 227)

; Load and parse Packs.xml, returns 2d array [modpackNum][elements]
$modpacks = parsePacks($packsURL, $dataFolder)

;Initialize all Modpacks, create needed folders, download modpack descriptions, splash and icons
initModpacks($modpacks, $dataFolder)

; Initialize ModSelection GUI assets, download default files and background.
initGUImodSelectionAssets($baseURL, $dataFolder)

; Display Modpack selection GUI
$modpackNum = DisplayModpackSelection()

; Exit application - no modpack was selected to download
If $modpackNum = -1 Then
	ConsoleWrite("[Info]: Exiting application" & @CRLF)
	Exit
EndIf



MsgBox(64,"SAMUpdater version " & $version,"Development Mode" &@CRLF & "More stuff comming soon...")

;~ displayGUI()
	; Populate Modpacks
	; Select Modpack

		;Cache Modpack
		;Install Modpack
		;Configure Magic Launcher
		;Create Shortcuts


