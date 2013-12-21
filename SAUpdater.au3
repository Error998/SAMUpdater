#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=SAMUpdater.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <INet.au3>
#include <String.au3>
#include <Crypt.au3>
#include "includes\Folders.au3"
#include "includes\XML.au3"
#include "includes\ConfigureMagicLauncher.au3"
;#include "ForumAuth.au3"

Opt('MustDeclareVars', 1)
;#RequireAdmin


; Init
Local $sPackURL = "http://127.0.0.1/SAMUpdater/packs.xml"
Local $sMusicURL = "http://127.0.0.1/SAMUpdater/Sounds/Background.mp3"
Local $sUpdateURL = "http://127.0.0.1/SAMUpdater/version.dat"
Dim $sXML[4096]
Local $ver
Const $version = "1.0.0.0"


; SAMUpdater update check
Func checkUpdate()
	ConsoleWrite("[Info]: Checking if an update is available" & @CRLF)

	downloadFile($sUpdateURL, @WorkingDir & "\version.dat")
	_FileReadToArray(@WorkingDir & "\version.dat", $ver)

	If $ver[1] > $version Then
		ConsoleWrite("[Info]: Current Version: " & $version & " - Available Version " & $ver[1] & @CRLF)

		For $i = 1 to 3
			; Download Update
			ConsoleWrite("[Info]: Downloading new update" & @CRLF)
			downloadFile($ver[2], @WorkingDir & "\Update.dat")

			;Check Update hash
			If compareHash(@WorkingDir & "\Update.dat", $ver[3]) Then
				ConsoleWrite("[Info]: File integrity passed - Update.dat" & @CRLF)
				ExitLoop
			ElseIf $i = 3 Then
				ConsoleWrite("[ERROR]: File integrity failed 3 times, please contact your mod pack administrator - Update.dat" & @CRLF)
				Exit
			Else
				ConsoleWrite("[ERROR]: File integrity failed " & $i & " of 3 times, restarting download" & @CRLF)
			EndIf
		Next

		For $i = 1 to 3
			; Download Update_Helper
			ConsoleWrite("[Info]: Downloading Update_Helper" & @CRLF)
			downloadFile($ver[4], @WorkingDir & "\Update_Helper.exe")

			;Check Update hash
			If compareHash(@WorkingDir & "\Update_Helper.exe", $ver[5]) Then
				ConsoleWrite("[Info]: File integrity passed - Update_Helper.exe" & @CRLF)
				ExitLoop
			ElseIf $i = 3 Then
				ConsoleWrite("[ERROR]: File integrity failed 3 times, please contact your mod pack administrator - Update_Helper.exe" & @CRLF)
				Exit
			Else
				ConsoleWrite("[ERROR]: File integrity failed " & $i & " of 3 times, restarting download" & @CRLF)
			EndIf
		Next

		Run("Update_Helper.exe", @WorkingDir)
		Exit
	Else
		ConsoleWrite("[Info]: Current Version: " & $version & " - No new update available" & @CRLF)
	EndIf


EndFunc


; Download pack
Func getPackXML($sPackURL)

	createFolder(@WorkingDir & "\PackData")

	ConsoleWrite("[Info]: Downloading ServerPacks.xml" & @CRLF)
	downloadFile($sPackURL, @WorkingDir & "\PackData\ServerPacks.xml")

EndFunc


Func getBackgroundMusic($sBackgroundMusicURL)

	createFolder(@WorkingDir & "\PackData\Sounds")

	If FileExists(@WorkingDir & "\PackData\Sounds\background.mp3") Then
		ConsoleWrite("[Info]: Using cached background music" & @CRLF)
	Else
		ConsoleWrite("[Info]: Downloading background music" & @CRLF)
		downloadFile($sBackgroundMusicURL, @WorkingDir & "\PackData\Sounds\background.mp3")
	EndIf
EndFunc


Func getModuleInfo($Modpack)
	Local $modules[4096]
	Local $files
	Dim $moduleInfo[9]

	; Get Files of Modpack[X]
	$files = getElement($Modpack, "Files")

	;Get each module contained within Files
	$modules = getElements($files, "Module")

	;Get the info for each module
	For $x = 1 To $modules[0]
		;Get module info of module[X]
		$moduleInfo[0] = $modules[$x]
		;filename
		$moduleInfo[1] = getElement($moduleInfo[0], "Filename")
		;extract
		$moduleInfo[2] = getElement($moduleInfo[0], "Extract")
		;path
		$moduleInfo[3] = getElement($moduleInfo[0], "Path")
		;md5
		$moduleInfo[4] = getElement($moduleInfo[0], "md5")
		;size
		$moduleInfo[5] = getElement($moduleInfo[0], "Size")
		;required
		$moduleInfo[6] = getElement($moduleInfo[0], "Required")
		;remove
		$moduleInfo[7] = getElement($moduleInfo[0], "Remove")
		;NoOverwrite
		$moduleInfo[8] = getElement($moduleInfo[0], "Overwrite")

		For $i = 1 to 9
			ConsoleWrite($moduleInfo[$i] & @CRLF)
		Next

		ConsoleWrite(@CRLF & @CRLF)
	Next
EndFunc


Func getModPacksInfo($BaseModPackURLofModpackNum = 1)
    Dim $Modpack[64]
    Local $info[10]

	ConsoleWrite("[Info]: Loading ServerPack.xml")
	; Get ModPack tag
	$sXML = loadXML(@WorkingDir & "\PackData\ServerPacks.xml")
	$Modpack = getElements($sXML, "ModPack")
	ConsoleWrite(" ...done" & @CRLF)
	ConsoleWrite("[Info]: Found " & $Modpack[0] & " modpacks" & @CRLF)

	; Get info of Modpack[i]
	For $i = 1 to $Modpack[0]
		;$info[0] stores 1 entire modpack info
		$info[0] = getElement($Modpack[$i], "Info")
		;ServerID
		$info[1] = getElement($info[0], "ModPackID")
		;ServerName
		$info[2] = getElement($info[0], "ServerName")
		;ServerVersion
		$info[3] = getElement($info[0], "ServerVersion")
		;NewsURL
		$info[4] = getElement($info[0], "NewsURL")
		;IconURL
		$info[5] = getElement($info[0], "IconURL")
		;Discription
		$info[6] = getElement($info[0], "Discription")
		;ServerConnection
		$info[7] = getElement($info[0], "ServerConnection")
		;Forge Profile ID
		$info[8] = getElement($info[0], "ForgeID")
		;Base Modpack URL
		$info[9] = getElement($info[0], "URL")
		ConsoleWrite("[Info]" & $i & ": Modpack ID " & $info[1] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Name " & $info[2] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Version " & $info[3] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": News URL " & $info[4] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Icon URL " & $info[5] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Discription " & $info[6] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Connection " & $info[7] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Forge Profile ID " & $info[8] & @CRLF & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Base Modpack URL " & $info[9] & @CRLF & @CRLF)
		; Create Mod pack cache folder
		createFolder(@WorkingDir & "\PackData\" & $info[1])

		; Save base modpack URL to return
		If $i = $BaseModPackURLofModpackNum Then
			$BaseModPackURLofModpackNum = $info[9]
		EndIf
	Next

	Return $BaseModPackURLofModpackNum
EndFunc


Func getModPack($iModPackNum)
	Dim $Modpack[64]

	ConsoleWrite("[Info]: Getting Modpack " & $iModPackNum & " data")
	; Get ModPack tag
	$sXML = loadXML(@WorkingDir & "\PackData\ServerPacks.xml")
	$Modpack = getElements($sXML, "ModPack")
	ConsoleWrite(" ...done" & @CRLF)

    Return	$Modpack[$iModPackNum]

EndFunc


Func getModPackModules($Modpack, $sModPackID = "")
	Local $modules[4096]
	Local $files

	;Get Files of Modpack[X]
	$files = getElement($Modpack, "Files")

	;Get each module contained within Files
	$modules = getElements($files, "Module")

	Return $modules
EndFunc


; Remove a file
Func rmFile($sPath)
	If FileExists($sPath) Then
		If FileRecycle($sPath) Then
			ConsoleWrite("[Info]: File removed - " & $sPath & @CRLF)
		Else
			ConsoleWrite("[ERROR]: Could not remove file, please make sure the file is not in use - " & $sPath & @CRLF)
			Exit
		EndIf
	Else
		ConsoleWrite("[Info]: File already removed - " & $sPath & @CRLF)
	EndIf
EndFunc


Func cacheModules(ByRef $modules, $sModPackID, $sBaseModpackURL)
	Local $moduleInfo[9]

	; To optimize performance start the crypt library.
	_Crypt_Startup()

	;Get the info for each module
	For $x = 1 To $modules[0]
		;Get module info of module[X]
		$moduleInfo[0] = $modules[$x]
		;filename
		$moduleInfo[1] = getElement($moduleInfo[0], "Filename")
		;extract
		$moduleInfo[2] = getElement($moduleInfo[0], "Extract")
		;path
		$moduleInfo[3] = getElement($moduleInfo[0], "Path")
		;md5
		$moduleInfo[4] = getElement($moduleInfo[0], "md5")
		;size
		$moduleInfo[5] = getElement($moduleInfo[0], "Size")
		;required
		$moduleInfo[6] = getElement($moduleInfo[0], "Required")
		;remove
		$moduleInfo[7] = getElement($moduleInfo[0], "Remove")
		;NoOverwrite
		$moduleInfo[8] = getElement($moduleInfo[0], "Overwrite")


		; Should we install or remove file?
		If $moduleInfo[7] = "TRUE" Then
			; Remove file from cache
			rmFile(@WorkingDir & "\PackData\" & $sModPackID & "\" & $moduleInfo[4])

			; Remove file from installation
			rmFile(@AppDataDir & "\" & $moduleInfo[3] & "\" & $moduleInfo[1])
		Else
			; Install file
			cacheFiles($sBaseModpackURL & "/" & $sModPackID & "/" & $moduleInfo[4], $moduleInfo[4], $sModPackID)
		EndIf
	Next

	; Shutdown the crypt library.
	_Crypt_Shutdown()

EndFunc


Func cacheFiles($sURL, $bHash, $sModPackID)
	; Retry to download file 3 times if file integrity failed
	For $i = 1 To 3
		; Check if file already exist in the cache
		If FileExists(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash) Then
			ConsoleWrite("[Info]: File already cached - " & $bHash & @CRLF)
		Else
			; Download uncached file
			ConsoleWrite("[Info]: Downloading file into cache - " & $bHash & @CRLF)
			downloadFile($sURL, @WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash)
		EndIf


		; Verify file
		If compareHash(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash, $bHash) Then
			ConsoleWrite("[Info]: File integrity passed" & @CRLF)
			ExitLoop
		Else
			ConsoleWrite("[Error]: File integrity failed." & " Retry " & $i & " of 3" & @CRLF)
			; Removed corupted file
			If FileDelete(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash) Then
				ConsoleWrite("[Info]: Removed corrupt file" & @CRLF)
			Else
				ConsoleWrite("[ERROR]: Failed to remove corrupt file " & $bHash & @CRLF)
				Exit
			EndIf
			; Failed 3 times, something must be worng!
			If $i = 3 Then
				ConsoleWrite("[ERROR]: File integrity check failed 3 times - Giving up, please contact administrator of the mod pack" & @CRLF)
				Exit
			EndIf
		EndIf

	Next
EndFunc


Func compareHash($sPath, $bCacheHash)
	; Create a md5 hash of the file.
	Local $bHash = _Crypt_HashFile($sPath, $CALG_MD5)

	; Compare hash
	If $bHash = $bCacheHash Then
		Return True
	Else
		Return False
	EndIf

EndFunc


Func downloadFile($sURL, $sPath)
	; Retry 5 times
	For $i = 1 To 5
		InetGet($sURL, $sPath, 9)
		if (@error <>  0) Then
			; All retries failed
			If $i = 5 Then
				ConsoleWrite("[ERROR]: Failed to download file retry 5 of 5 - Giving up, please check your internet connection." & @CRLF)
				Exit
			Else
				; Wait 10 seconds then retry
				ConsoleWrite("[Error]: Failed to download file retry " & $i & " of 5" & @CRLF)
				ConsoleWrite("[Info]: Retrying download in 10 seconds")
				For $x = 1 To 10
					Sleep(1000)
					ConsoleWrite(".")
				Next
				ConsoleWrite(@CRLF)
			EndIf
		Else
			; Download was successful
			ExitLoop
		EndIf
	Next

EndFunc


Func installFromCache(ByRef $modules, $sModPackID)
	Local $moduleInfo[9]
	Local $sPath
    Local $sResult

	;Get the info for each module
	For $x = 1 To $modules[0]
		;Get module info of module[X]
		$moduleInfo[0] = $modules[$x]
		;filename
		$moduleInfo[1] = getElement($moduleInfo[0], "Filename")
		;extract
		$moduleInfo[2] = getElement($moduleInfo[0], "Extract")
		;path
		$moduleInfo[3] = getElement($moduleInfo[0], "Path")
		;md5
		$moduleInfo[4] = getElement($moduleInfo[0], "md5")
		;size
		$moduleInfo[5] = getElement($moduleInfo[0], "Size")
		;required
		$moduleInfo[6] = getElement($moduleInfo[0], "Required")
		;remove
		$moduleInfo[7] = getElement($moduleInfo[0], "Remove")
		;NoOverwrite
		$moduleInfo[8] = getElement($moduleInfo[0], "Overwrite")

		; Skip install of current module if its marked for removal
		If $moduleInfo[7] = "TRUE" Then
			ContinueLoop
		EndIf


		If $sPath <> $moduleInfo[3] Then
			$sPath = $moduleInfo[3]
			; Create the path
			createFolder(@AppDataDir & "\" & $moduleInfo[3])
		EndIf

		; Check if module should be overwritten
		If $moduleInfo[8] = "TRUE" Then
			; Overwrite file
			$sResult = FileCopy(@WorkingDir & "\PackData\" & $sModPackID & "\" & $moduleInfo[4],  @AppDataDir & "\" & $moduleInfo[3] & "\" & $moduleInfo[1], 1)

			; Check if copy function was successful
			If  $sResult = True Then
				ConsoleWrite("[Info]: Successfully installed - " & $moduleInfo[1] & @CRLF)
			Else
				ConsoleWrite("[ERROR] 1: Failed to install - " & $moduleInfo[1] & @CRLF)
				Exit
			EndIf
		ElseIf FileExists( @AppDataDir & "\" & $moduleInfo[3] & "\" & $moduleInfo[1]) Then
			; File already in target location, not overwriting
			ConsoleWrite("[Info]: File already exists skipping - " & $moduleInfo[1] & @CRLF)
		Else
			; File not in target, proceding to install it
			$sResult = FileCopy(@WorkingDir & "\PackData\" & $sModPackID & "\" & $moduleInfo[4],  @AppDataDir & "\" & $moduleInfo[3] & "\" & $moduleInfo[1], 0)

			; Check if copy function was successful
			If  $sResult = True Then
				ConsoleWrite("[Info]: Successfully installed - " & $moduleInfo[1] & @CRLF)
			Else
				ConsoleWrite("[ERROR] 2: Failed to install - " & $moduleInfo[1] & @CRLF)
				Exit
			EndIf
		EndIf

	Next

EndFunc


Func checkForValidMCLauncher()
	Local $sBackupDir

	If FileExists(@AppDataDir & "\.minecraft\launcher_profiles.json") Then
		ConsoleWrite("[Info]: Found valid Vanilla Launcher fingerprint" & @CRLF)
		Return True
	Else
		$sBackupDir = @AppDataDir & "\SAMUpdater\Backup\" & @MDAY & @MON & @YEAR & @HOUR & @MIN & @SEC & "\.minecraft"
		ConsoleWrite("[Warning]: Could not find a vaild Vanilla Launcher" & @CRLF)
		ConsoleWrite("[Warning]: Making a backup of your .minecraft folder and saving it in " & $sBackupDir & @CRLF)

		; Try to backup existing .minecraft folder
		If FileExists(@AppDataDir & "\.minecraft") Then
			If DirMove(@AppDataDir & "\.minecraft", $sBackupDir) Then
				ConsoleWrite("[Info]: Backup successful" & @CRLF)
			Else
				; Move failed
				ConsoleWrite("[ERROR]: Unable to move " & @AppDataDir & "\.minecraft to " & $sBackupDir & @CRLF)
				ConsoleWrite("[ERROR]: Make sure no file is in use in " & @AppDataDir & "\.minecraft" & @CRLF)
				Exit
			EndIf
		Else
			ConsoleWrite("[Info]: Folder does not exist, nothing to backup - " & @AppDataDir & "\.minecraft" & @CRLF)
			Return
		EndIf
	EndIf

EndFunc


; **** Main ****

;Check for program update
checkUpdate()

; Download music
getBackgroundMusic($sMusicURL)
; Play background music
If FileExists(@WorkingDir & "\PackData\Sounds\Background.mp3") Then
	SoundPlay(@WorkingDir & "\PackData\Sounds\Background.mp3")
EndIf

; Download and store ServerPacks.xml
getPackXML($sPackURL)

; List all available modpacks + create each mod pack cache folder and
; return base modpack url of specified modpack

; Fix this mess of returning values
Local $sBaseURL
$sBaseURL = getModPacksInfo(1)

Local $modules[4096]
; Get all the modules for a single mod pack by ServerID

; Fix this mess of returning values
$modules = getModPackModules(getModPack(1), "TestServer")

; Cache all modules of ServerID
cacheModules($modules, "TestServer", $sBaseURL)

; Check for new MC launcher, If exist(launcher_profiles.json)
checkForValidMCLauncher()

; Install the selected ModPack from cache
installFromCache($modules, "TestServer")

; Configure Magic Launcher profile
ConfigureMagicLauncher("TestServer", "1.6.4-Forge9.11.1.952")


; Create shortcuts to desktop for Vanilla + Magic Launchers


ConsoleWrite("[Info]: Done" & @CRLF)
SoundPlay("")
Sleep(5000)
