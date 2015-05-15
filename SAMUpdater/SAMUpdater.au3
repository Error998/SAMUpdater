#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=GUI\samupdater.ico
#AutoIt3Wrapper_Outfile=samupdater.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=SA Minecraft Update Utility
#AutoIt3Wrapper_Res_ProductVersion=0.5.0.3
#AutoIt3Wrapper_Res_Fileversion=0.5.0.3
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
#include "GUI\frmPackSelection.au3"
#include "GUI\frmSelectFolder.au3"
#include "PostInstall\MagicLauncher.au3"
#include "PostInstall\Application.au3"
#include "OfflineMode\OfflineMode.au3"

Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.5.0.3"
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
createFolder($dataFolder & "\PackData\Assets\GUI\AdvInfo")
createFolder($dataFolder & "\PackData\Assets\GUI\ModpackSelection")
createFolder($dataFolder & "\PackData\Assets\GUI\Progress")
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



; Initialize all GUI assets (pictures, backgrounds, descriptions, etc)
initGUIAssets($baseURL, $dataFolder)



; Load and parse Packs.xml, returns 2d array [packNum][elements]
$packs = parsePacks($packsURL, $dataFolder)



;Initialize all Packs, create needed folders, download pack descriptions, splash and icons
initPacks($packs, $dataFolder)



; Display Pack Selection GUI
$packNum = DisplayPackSelection()


; Exit application - no modpack was selected to download
If $packNum = -1 Then

	Exit

EndIf



; Assign all Pack elemets
Local $PackID = $packs[$packNum][0]
Local $PackName = $packs[$packNum][1]
Local $PackVersion = $packs[$packNum][2]
Local $ContentVersion = $packs[$packNum][3]
Local $PackDescriptionSHA1 = $packs[$packNum][4]
Local $PackIconSHA1 = $packs[$packNum][5]
Local $PackSplashSHA1 = $packs[$packNum][6]
Local $PackDatabaseSHA1 = $packs[$packNum][7]
Local $PackConfigSHA1 = $packs[$packNum][8]
Local $PackRepository = $packs[$packNum][9]
Local $PackDownloadable = $packs[$packNum][10]
Local $PackVisible = $packs[$packNum][11]


; Log entries
writeLog("[Info]: Selected Pack Information" & @CRLF)
writeLog("[Info]: Pack ID               - " & $PackID & @CRLF)
writeLog("[Info]: Pack Name             - " & $PackName & @CRLF)
writeLog("[Info]: Pack Version          - " & $PackVersion & @CRLF)
writeLog("[Info]: Content Version       - " & $ContentVersion & @CRLF)
writeLog("[Info]: Pack Repository       - " & $PackRepository & @CRLF)



; Cache pack
cachePack($PackRepository, $PackID, $dataFolder)




; Custom Pre-install stuff




;Install Pack
;installPack($PackID, $dataFolder)
Exit


; Custom Post install stuff
configureMagicLauncher($PackID, $ForgeVersion, 1536)





; Create desktop shortcut
createDesktopShortcut($packs[$packNum][14], $packs[$packNum][15])



writeLogEchoToConsole("[Info]: Update is complete" & @CRLF & @CRLF)
MsgBox($MB_ICONINFORMATION, "Update complete", "The update is now complete", 20)



; Launch installed application
lauchShortcut($packs[$packNum][16], $packs[$packNum][15])







