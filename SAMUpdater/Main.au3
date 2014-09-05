#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=0.0.0.5
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "AutoUpdate\AutoUpdate.au3"
#include "DataIO\Folders.au3"
#include "Sound\Sounds.au3"
Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.0.0.5"
Const $updateURL = "http://localhost/samupdater/version.dat"
Const $musicURL = "http://localhost/samupdater/sounds/background.mp3"
Global $dataFolder = @AppDataDir & "\SAMUpdater"


; ### Init Data Folders ###
ConsoleWrite("[Info]: Initializing folders..." & @CRLF)
createFolder($dataFolder)
createFolder($dataFolder & "\PackData")
createFolder($dataFolder & "\PackData\Sounds")
ConsoleWrite("[Info]: Folders initialized" & @CRLF & @CRLF)
; #########################


; Check and update SAMUpdater
autoUpdate($version, $updateURL, $dataFolder)


; Play background music
playBackgroundMusic($musicURL, $dataFolder, 227)

MsgBox(64,"End of App","")

;~ displayGUI()
	; Populate Modpacks
	; Select Modpack
		;Cache Modpack
		;Install Modpack
		;Configure Magic Launcher
		;Create Shortcuts


