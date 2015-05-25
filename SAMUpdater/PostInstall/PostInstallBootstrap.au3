#include-once
#include "MagicLauncher.au3"
#include "Application.au3"

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: PostInstall
; Description ...: All the modules that can be run after the installation is done.
; Syntax ........: PostInstall($PackID, $dataFolder)
; Parameters ....: $PackID              - The Pack ID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Each module listed here must check on its own to determine if it should run or not
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PostInstall($PackID, $dataFolder)

	; Post Intall Magic Launcher
	PostInstallMagicLauncher($PackID, $dataFolder)

	; Post Install some generic stuff?
	PostInstallGeneric($PackID, $dataFolder)

	; Create a desktop shotcut
	PostInstallApplicationShortcut($PackID, $dataFolder)

	; Launch the application
	PostInstallLaunchApplication($PackID, $dataFolder)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: PostInstallMagicLauncher
; Description ...: Auto confgure Magic Launcher
; Syntax ........: PostInstallMagicLauncher($PackID, $dataFolder)
; Parameters ....: $PackID              - Pack ID.
;                  $dataFolder          - Application data folder
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PostInstallMagicLauncher($PackID, $dataFolder)
	Local $packType
	Local $ForgeVersion
	Local $RAM


	$packType = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "General", "PackType", "Generic")

	; If not MagicLaucher pack type then skip
	If $packType <> "MagicLauncher" Then Return


	; Get the Forge version of the pack
	$ForgeVersion = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", $packType, "ForgeVersion", "")

	; Get the RAM setting for the Magic Launcher Profile
	$RAM = Int(IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", $packType, "RAM", "1536"))



	configureMagicLauncher($PackID, $ForgeVersion, $RAM)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: PostInstallGeneric
; Description ...:
; Syntax ........: PostInstallGeneric($PackID, $dataFolder)
; Parameters ....: $PackID              - An unknown value.
;                  $dataFolder          - An unknown value.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PostInstallGeneric($PackID, $dataFolder)
	Local $packType
	Local $runPostInstallApp

	$packType = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "General", "PackType", "Generic")

	; If not Generic pack type then skip
	If $packType <> "Generic" Then Return


	runPostInstall($PackID, $dataFolder)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: runPostInstall
; Description ...: Run an application after installation marked in <PackID.ini>\Generic\PostInstall
; Syntax ........: runPostInstall($PackID, $dataFolder)
; Parameters ....: $PackID              - An unknown value.
;                  $dataFolder          - An unknown value.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func runPostInstall($PackID, $dataFolder)
	Local $runPostInstallApp


	$runPostInstallApp = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Generic", "PostInstall", "NONE")

	; Skip if no post install app has to be run
	if $runPostInstallApp = "NONE" Then Return

	; Parse path
	$runPostInstallApp = parsePath($runPostInstallApp)


	; Run post install app
	writeLogEchoToConsole("[Info]: Launching post install application - " & getFilename($runPostInstallApp) & @CRLF)

	ShellExecuteWait(getFilename($runPostInstallApp), "", getPath($runPostInstallApp), "open")

	writeLogEchoToConsole("[Info]: Post install done." & @CRLF)


EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: PostInstallApplicationShortcut
; Description ...: Creates a application shortcut on the desktop
; Syntax ........: PostInstallApplicationShortcut($PackID, $dataFolder)
; Parameters ....: $PackID              - Pack ID.
;                  $dataFolder          - Application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PostInstallApplicationShortcut($PackID, $dataFolder)
	Local $shortcutTarget
	Local $shortcutName
	Local $shortcutLaunch

	$shortcutTarget = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Shortcut", "ShortcutTarget", "")

	; Sanity check, skip is no target present
	If $shortcutTarget = "" Then Return

	; Name
	$shortcutName = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Shortcut", "ShortcutName", "")


	; Create desktop shortcut
	createDesktopShortcut($shortcutTarget, $shortcutName)

EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: PostInstallLaunchApplication
; Description ...: Launch application from the shortcut on the desktop
; Syntax ........: PostInstallLaunchApplication($PackID, $dataFolder)
; Parameters ....: $PackID              - Pack ID.
;                  $dataFolder          - The application data folder.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PostInstallLaunchApplication($PackID, $dataFolder)
	Local $shortcutTarget
	Local $shortcutName
	Local $shortcutLaunch

	$shortcutTarget = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Shortcut", "ShortcutTarget", "")

	; Sanity check, skip is no target present
	If $shortcutTarget = "" Then Return

	; Name
	$shortcutName = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Shortcut", "ShortcutName", "")

	; Launch after update is complete
	$shortcutLaunch = IniRead($dataFolder & "\PackData\ModPacks\" & $PackID & "\Data\"  & $PackID & ".ini", "Shortcut", "LaunchShortcutAfterUpdate", "True")

	; Skip if application is not set to launch
	If $shortcutLaunch <> "True" Then Return

	; Launch installed application
	lauchShortcut($shortcutName)

EndFunc