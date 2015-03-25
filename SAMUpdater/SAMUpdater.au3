#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=GUI\samupdater.ico
#AutoIt3Wrapper_Outfile=samupdater.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=SA Minecraft Update Utility
#AutoIt3Wrapper_Res_ProductVersion=0.4.0.0
#AutoIt3Wrapper_Res_Fileversion=0.4.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Do What The Fuck You Want To Public License, Version 2 - www.wtfpl.net
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <MsgBoxConstants.au3>
#include "AutoUpdate\AutoUpdate.au3"
#include "DataIO\Folders.au3"
#include "DataIO\Packs.au3"
#include "DataIO\Assets.au3"
#include "DataIO\Cache.au3"
#include "DataIO\InstallModpack.au3"
#include "DataIO\Logs.au3"
#include "DataIO\UserSettings.au3"
#include "Sound\Sounds.au3"
#include "GUI\Colors.au3"
#include "GUI\frmModpackSelection.au3"
#include "PostInstall\MagicLauncher.au3"
#include "PostInstall\Application.au3"
#include "OfflineMode\OfflineMode.au3"

Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.4.0.0"
Const $baseURL = "http://localhost/samupdater"
;Const $baseURL = "http://local.saminecraft.co.za/sam/samupdater"
Const $updateURL = $baseURL & "/version.ini"
Const $packsURL = $baseURL & "/packdata/packs.xml"
Global $dataFolder = @AppDataDir & "\SAMUpdater"
Global $isOnline = "True"

; Initialize colors used in console window
Global $hdllKernel32 = initColors()

; Log file handle
Global $hLog = initLogs($dataFolder)

Global $userSettingSoundOn
Global $packs

Local $packNum



; Close the log file on application exit
OnAutoItExitRegister("closeLog")


; Set console color
setConsoleColor($FOREGROUND_Light_Green)


; ### Init Data Folders ###
writeLogEchoToConsole("[Info]: Initializing folders..." & @CRLF)
createFolder($dataFolder & "\PackData\Assets\GUI\ModpackSelection")
createFolder($dataFolder & "\PackData\Assets\GUI\AdvInfo")
createFolder($dataFolder & "\PackData\Assets\Sounds")
createFolder($dataFolder & "\Settings")
writeLogEchoToConsole("[Info]: Folders initialized" & @CRLF & @CRLF)
; #########################



; Initialize settings.ini
initUserSettings($dataFolder)



; Determine is Updater is online or not
$isOnline = getSettingIsOnline($dataFolder)

If $isOnline Then
	; Online
	writeLogEchoToConsole("[Info]: SAMUpdater is currently in Online Mode" & @CRLF & @CRLF)
Else
	; Offline
	writeLogEchoToConsole("[Warning]: SAMUpdater is currently in Offline Mode" & @CRLF & @CRLF)

	; Prompt user to switch to Online mode

	toggleNetworkMode()
EndIf


; ************** Initialization Done **************



; Check and update SAMUpdater
autoUpdate($version, $updateURL, $dataFolder)



; Play background music
playBackgroundMusic($dataFolder)


; Load and parse Packs.xml, returns 2d array [packNum][elements]
$packs = parsePacks($packsURL, $dataFolder)



;Initialize all Modpacks, create needed folders, download modpack descriptions, splash and icons
initPacks($packs, $dataFolder)

Exit

; Initialize all GUI assets (pictures, backgrounds, descriptions, etc)
initGUIAssets($baseURL, $dataFolder)



; Display Modpack selection GUI
$packNum = DisplayModpackSelection()



; Exit application - no modpack was selected to download
If $packNum = -1 Then

	Exit

EndIf


; Log entries
writeLog("[Info]: Selected Pack Information" & @CRLF)
writeLog("[Info]: Pack ID               - " & $packs[$packNum][0] & @CRLF)
writeLog("[Info]: Pack Name             - " & $packs[$packNum][1] & @CRLF)
writeLog("[Info]: Pack Description      - " & $packs[$packNum][2] & @CRLF)
writeLog("[Info]: Pack Repository       - " & $packs[$packNum][11] & @CRLF)


; Cache modpack
cacheModpack($modpacks[$modpackNum][11], $modpacks[$modpackNum][0], $dataFolder)




; Custom Pre-install stuff



;Install Modpack
installModPack($modpacks[$modpackNum][13], $modpacks[$modpackNum][0], $dataFolder)



; Custom Post install stuff
configureMagicLauncher($modpacks[$modpackNum][0], $modpacks[$modpackNum][10], 1536)





; Create desktop shortcut
createDesktopShortcut($modpacks[$modpackNum][14], $modpacks[$modpackNum][15])



writeLogEchoToConsole("[Info]: Update is complete" & @CRLF & @CRLF)
MsgBox($MB_ICONINFORMATION, "Update complete", "The update is now complete", 20)



; Launch installed application
lauchShortcut($modpacks[$modpackNum][16], $modpacks[$modpackNum][15])







