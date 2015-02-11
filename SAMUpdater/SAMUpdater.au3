#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=GUI\samupdater.ico
#AutoIt3Wrapper_Outfile=samupdater.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=SA Minecraft Update Utility
#AutoIt3Wrapper_Res_ProductVersion=0.1.0.0
#AutoIt3Wrapper_Res_Fileversion=0.1.0.0
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


Opt('MustDeclareVars', 1)


; ### Init Varibles ###
Const $version = "0.1.0.0"
Const $baseURL = "http://localhost/samupdater"
;Const $baseURL = "http://local.saminecraft.co.za/sam/samupdater"
Const $updateURL = $baseURL & "/version.dat"
Const $packsURL = $baseURL & "/packdata/packs.xml"
Global $dataFolder = @AppDataDir & "\SAMUpdater"

; Initialize colors used in console window
Global $hdllKernel32 = initColors()

; Log file handle
Global $hLog = initLogs($dataFolder)

Global $userSettingSoundOn
Global $modpacks

Local $modpackNum



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



; Check and update SAMUpdater
autoUpdate($version, $updateURL, $dataFolder)



; Initialize settings.ini
initUserSettings($dataFolder)



; Play background music
playBackgroundMusic($dataFolder)


; Load and parse Packs.xml, returns 2d array [modpackNum][elements]
$modpacks = parsePacks($packsURL, $dataFolder)



;Initialize all Modpacks, create needed folders, download modpack descriptions, splash and icons
initModpacks($modpacks, $dataFolder)



; Initialize all GUI assets (pictures, backgrounds, descriptions, etc)
initGUIAssets($baseURL, $dataFolder)



; Display Modpack selection GUI
$modpackNum = DisplayModpackSelection()



; Exit application - no modpack was selected to download
If $modpackNum = -1 Then

	Exit

EndIf


; Log entries
writeLog("[Info]: Modpack Information" & @CRLF)
writeLog("[Info]: Modpack ID            - " & $modpacks[$modpackNum][0] & @CRLF)
writeLog("[Info]: Modpack Name          - " & $modpacks[$modpackNum][1] & @CRLF)
writeLog("[Info]: Modpack Description   - " & $modpacks[$modpackNum][2] & @CRLF)
writeLog("[Info]: Remote Repository URL - " & $modpacks[$modpackNum][11] & @CRLF)
writeLog("[Info]: Installation Folder   - " & $modpacks[$modpackNum][13] & @CRLF)
writeLog("[Info]: Shortcut target       - " & $modpacks[$modpackNum][14] & @CRLF)
writeLog("[Info]: Shortcut name         - " & $modpacks[$modpackNum][15] & @CRLF)
writeLog("[Info]: Launch Application    - " & $modpacks[$modpackNum][16] & @CRLF & @CRLF)


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







