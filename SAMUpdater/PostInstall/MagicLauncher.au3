#include <File.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)


Func configureMagicLauncher($modpacks[$modpackNum][0], $dataFolder, $forgeVersion)
	Local $sMagicLauncher
	Local $sAppData
	Local $bConfigChanged = False
	Local $bProfileFound = False

	; Check that the magic launcher config exists if not create it
	If Not FileExists(@AppDataDir & "\.minecraft\magic\magiclauncher.cfg") Then
		ConsoleWrite("[Info]: Creating new Magic Launcher config" & @CRLF)
		createMagicLauncherConfig($modID, $forgeVersion)

		; All ready created a correctly configured config
		Return
	EndIf




	_FileReadToArray(@AppDataDir & "\.minecraft\magic\magiclauncher.cfg", $sMagicLauncher)

	; Check if a profile exists for this mod pack.
	For $i = 1 To $sMagicLauncher[0]
		; Search for the Mod Pack Profile
		If $sMagicLauncher[$i] = '  <Name="' & $sModID & '">' Then
			$bProfileFound = True
			ConsoleWrite("[Info]: Found mod pack profile information on line " & $i & @CRLF)

			; Sanity check for Profile enviroment
			If StringInStr($sMagicLauncher[$i + 1], "  <Environment=", 1) = 0 Then
				ConsoleWrite("[Error]: Could not find profile enviroment setting, manual profile setup required!" & @CRLF)
				Return
			Else

				; Enviroment found, let check if its set correctly
				If $sMagicLauncher[$i + 1] = '  <Environment="' & $forgeVersion & '">' Then
					ConsoleWrite("[Info]: Correct enviroment selected" & @CRLF)
				Else
					; Set the enviroment to the correct setting
					$sMagicLauncher[$i + 1] = '  <Environment="' & $forgeVersion & '">'
					$bConfigChanged = True
					ConsoleWrite("[Info]: Set profile enviroment to - " & $forgeVersion & @CRLF)
				EndIf

				; Convert %appdata% path to "\\" instead of "\"
				$sAppData = @AppDataDir
				$sAppData = StringReplace($sAppData, "\", "*")
				$sAppData = StringReplace($sAppData, "*", "\\")

				; Lets also check if minecraft jar is set correctly
				If $sMagicLauncher[$i + 2] = '  <MinecraftJar="' & $sAppData & '\\.minecraft\\versions\\' & $sForgeID & '\\' & $sForgeID & '.jar">' Then
					ConsoleWrite("[Info]: Profile is pointing to the correct minecraft jar file" & @CRLF)
				Else
					; Set the enviroment to the correct setting
					$sMagicLauncher[$i + 2] = '  <MinecraftJar="' & $sAppData & '\\.minecraft\\versions\\' & $sForgeID & '\\' & $sForgeID & '.jar">'
					ConsoleWrite("[Info]: Fixed the profile to point to the correct minecraft jar location" & @CRLF)
					$bConfigChanged = True
				EndIf
			EndIf
			ExitLoop
		EndIf
	Next

	; If no profile was found add a new one to the top of the config
	If Not $bProfileFound  Then
		ConsoleWrite("[Info]: No existing mod pack profile was found - Adding new profile '" & $sModID & "'" & @CRLF)

		$sAppData = convertPath(@AppDataDir)

		_ArrayInsert($sMagicLauncher, 1, '<Profile')
		_ArrayInsert($sMagicLauncher, 2, '  <Name="' & $sModID & '">')
		_ArrayInsert($sMagicLauncher, 3, '  <Environment="' & $sForgeID & '">')
		_ArrayInsert($sMagicLauncher, 4, '  <MinecraftJar="' & $sAppData & '\\.minecraft\\versions\\' & $sForgeID & '\\' & $sForgeID & '.jar">')
		_ArrayInsert($sMagicLauncher, 5, '  <ShowLog="true">')
		_ArrayInsert($sMagicLauncher, 6, '  <MaxMemory="512">')
		_ArrayInsert($sMagicLauncher, 7, '>')
		;Update array total items
		$sMagicLauncher[0] = $sMagicLauncher[0] + 7

		$bConfigChanged = True
	EndIf

	If $bConfigChanged Then
		Local $iProfileCount = -1

		; Find the profile number for our modpack
		For $i = 1 to $sMagicLauncher[0]
			If StringInStr($sMagicLauncher[$i], "<Profile") <> 0 Then
				$iProfileCount = $iProfileCount + 1
				If $sMagicLauncher[$i + 1] = '  <Name="' & $sModID & '">' Then
					; We found our mod pack profile num, exit loop
					ExitLoop
				EndIf
			EndIf
		Next

		; Set the active profile to our mod pack profile
		For $i = 1 to $sMagicLauncher[0]
			If StringInStr($sMagicLauncher[$i], "<ActiveProfileIndex=") <> 0 Then
				$sMagicLauncher[$i] = '<ActiveProfileIndex="' & $iProfileCount & '">'
				ConsoleWrite("[Info]: Setting active profile to " & $iProfileCount & " - " & $sModID & @CRLF)
				ExitLoop
			EndIf
		Next

		; Save new config
		If _FileWriteFromArray(@AppDataDir & "\.minecraft\magic\magiclauncher.cfg", $sMagicLauncher, 1) Then
			ConsoleWrite("[Info]: Magic Launcher auto configuration complete" & @CRLF)
		Else
			ConsoleWrite("[Error]: Could not save auto generated profile, manual profile setup required!" & @CRLF)
		EndIf

	Else
		ConsoleWrite("[Info]: Magic Launcher already configured - Skipping auto config" & @CRLF)
	EndIf
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: convertPath
; Description ...: Convert a path string to a compatible MagicLauncher path string
; Syntax ........: convertPath($path)
; Parameters ....: $path                - Path to be converted
; Return values .: Converted path
; Author ........: Error_998
; Modified ......:
; Remarks .......: Replaces all '\' with '\\'
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func convertPath($path)
	; Convert %appdata% path to "\\" instead of "\"
	$path = StringReplace($sAppData, "\", "*")
	$path = StringReplace($sAppData, "*", "\\")

	Return $path

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: createMagicLauncherConfig
; Description ...: Create a valid MagicLauncher.cfg file from scratch
; Syntax ........: createMagicLauncherConfig($modID, $forgeVersion)
; Parameters ....: $modID               - The modID.
;                  $forgeVersion        - The forge version the mod pack is using.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createMagicLauncherConfig($modID, $forgeVersion)
	Local $hFile
	Local $appfolder

	; Create folder
	createFolder(@AppDataDir & "\.minecraft\magic")


	; Open a new xml document for writing
	$hFile = FileOpen(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg", 10) ; erase + create dir
		If $hFile = -1 Then
			ConsoleWrite("[ERROR]: Unable to create - " & @AppDataDir & "\.minecraft\magic\MagicLauncher.cfg" & @CRLF)
			MsgBox(48, "Error creating file", "Unable to create MagicLauncher config file - " & @AppDataDir & "\.minecraft\magic\MagicLauncher.cfg")
			Exit
		EndIf

		$appfolder = convertPath(@AppDataDir)

		FileWriteLine($hFile, '<Profile')
		FileWriteLine($hFile, '  <Name="' & $modID & '">')
		FileWriteLine($hFile, '  <Environment="' & $forgeVersion & '">')
		FileWriteLine($hFile, '  <MinecraftJar="' & $appfolder & '\\.minecraft\\versions\\' & $forgeVersion & '\\' & $forgeVersion & '.jar">')
		FileWriteLine($hFile, '  <ShowLog="true">')
		FileWriteLine($hFile, '  <JavaParameters="-XX:MaxPermSize=192m -Dforge.forceNoStencil=true -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=2 -XX:+AggressiveOpts">')
		FileWriteLine($hFile, '  <MaxMemory="1536">')
		FileWriteLine($hFile, '  <BaseDir="' & $appfolder & '\\.minecraft\\Modpacks\\' & $modID & '\\.minecraft">')
		FileWriteLine($hFile, '>')
		FileWriteLine($hFile, '<ActiveProfileIndex="0">')
		FileWriteLine($hFile, '<LastModDir=>')
		FileWriteLine($hFile, '<LoadNews="false">')
		FileWriteLine($hFile, '<CloseAfterLogin="true">')
		FileWriteLine($hFile, '<RememberPassword="true">')


	FileClose($hFile)

EndFunc