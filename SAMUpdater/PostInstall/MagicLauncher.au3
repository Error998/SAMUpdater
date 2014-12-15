#include <File.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)


Func configureMagicLauncher($modID, $forgeVersion)
	Local $aConfig
	Local $profileStartIndex

	Local $sAppData
	Local $bConfigChanged = False
	Local $bProfileFound = False


	ConsoleWrite("[Info]: Auto configuration of MagicLauncher started..." & @CRLF)

	; If a config was made from scratch exit function
	If createNewMagicLauncherConfig($modID, $forgeVersion) Then Return


	; Read MagicLauncher.cfg
	_FileReadToArray(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg", $aConfig)


	; Get the profile start index
	$profileStartIndex = findProfileIndex($modID, $aConfig)


	; Profile not found, create it
	If $profileStartIndex = 0 Then
		insertProfile($modID, $forgeVersion, $aConfig)

		; New configured profile was inserted and saved
		Return
	EndIf


	ConsoleWrite("[Info]: Profile found..." & @CRLF)


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

	$path = StringReplace($path, "\", "*")
	$path = StringReplace($path, "*", "\\")

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
Func createNewMagicLauncherConfig($modID, $forgeVersion)
	Local $hFile
	Local $appfolder

	; Config already exists, exit function
	If FileExists(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg") Then Return False


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
		FileWriteLine($hFile, '  <InactiveExternalMods=>'
		FileWriteLine($hFile, '  <InactiveCoreMods=>')
		FileWriteLine($hFile, '>')
		FileWriteLine($hFile, '<ActiveProfileIndex="0">')
		FileWriteLine($hFile, '<LastModDir=>')
		FileWriteLine($hFile, '<LoadNews="false">')
		FileWriteLine($hFile, '<CloseAfterLogin="true">')
		FileWriteLine($hFile, '<RememberPassword="true">')


	FileClose($hFile)


	ConsoleWrite("[Info]: Auto configuration complete - New MagicLauncher.cfg created" & @CRLF & @CRLF)


	; New config was created
	Return True
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: findProfileIndex
; Description ...: Find the index of the profile with name $modID
; Syntax ........: findProfileIndex($modID, $aConfig)
; Parameters ....: $modID               - The modID.
;                  $aConfig             - An array containing the MagicLauncher config.
; Return values .: 0					- Profile index not found
;				 : > 0					- Index of the <Name="$modID"> entry
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func findProfileIndex($modID, $aConfig)

	For $i = 1 To $aConfig[0]

		If $aConfig[$i] = '  <Name="' & $modID & '">' Then Return $i

	Next

	Return 0
EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: insertProfile
; Description ...: Insert a new configured profile into MagicLauncher.cfg and save it.
; Syntax ........: insertProfile($modID, $forgeVersion, $aConfig)
; Parameters ....: $modID               - The modID.
;                  $forgeVersion        - The forge version for this modpack.
;                  $aConfig             - An array containing the MagicLauncher config.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func insertProfile($modID, $forgeVersion, $aConfig)
	Local $path

	ConsoleWrite("[Info]: No existing modpack profile was found - Adding new profile '" & $modID & "'" & @CRLF)

	$path = convertPath(@AppDataDir)

	_ArrayInsert($aConfig, 1, '<Profile')
	_ArrayInsert($aConfig, 2, '  <Name="' & $modID & '">')
	_ArrayInsert($aConfig, 3, '  <Environment="' & $forgeVersion & '">')
	_ArrayInsert($aConfig, 4, '  <MinecraftJar="' & $path & '\\.minecraft\\versions\\' & $forgeVersion & '\\' & $forgeVersion & '.jar">')
	_ArrayInsert($aConfig, 5, '  <ShowLog="true">')
	_ArrayInsert($aConfig, 6, '  <JavaParameters="-XX:MaxPermSize=192m -Dforge.forceNoStencil=true -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=2 -XX:+AggressiveOpts">')
	_ArrayInsert($aConfig, 7, '  <MaxMemory="1536">')
	_ArrayInsert($aConfig, 8, '  <BaseDir="' & $path & '\\.minecraft\\Modpacks\\' & $modID & '\\.minecraft">')
	_ArrayInsert($aConfig, 9, '  <InactiveExternalMods=>')
	_ArrayInsert($aConfig, 10, '  <InactiveCoreMods=>')
	_ArrayInsert($aConfig, 11, '>')


	;Update total items in array
	$aConfig[0] = $aConfig[0] + 11

	; Set active profile
	setConfigTag($aConfig, "ActiveProfileIndex", 0)


	; Disable the News
	setConfigTag($aConfig, "LoadNews", "false")


	; Remember login password
	setConfigTag($aConfig, "RememberPassword", "true")


	; Close MagicLauncher after login
	setConfigTag($aConfig, "CloseAfterLogin", "true")


	; Save the config
	saveMagicLauncherConfig($aConfig)

EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: setConfigTag
; Description ...: Sets the tag's value, if not found adds the tag at the end of the config
; Syntax ........: setActiveProfile(Byref $aConfig, $tag, $value)
; Parameters ....: $aConfig             - [in/out] An array containing the MagicLauncher config.
;                  $tag                 - The tag to set (Just the tag name, no '<'
;				   $value				- The value that should be set
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Supported tags are ActiveProfileIndex, LastModDir, LoadNews, CloseAfterLogin and RememberPassword
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setConfigTag(ByRef $aConfig, $tag, $value)

	; Search tag
	For $i = 1 To $aConfig[0]
		; If the tag is found set it
		If StringInStr($aConfig[$i], $tag) <> 0 Then
			$aConfig[$i] = '<' & $tag & '="' & $value & '">'

			; Index was set
			Return

		EndIf

	Next


	; Tag was not found, adding it to the end of the config
	_ArrayAdd($aConfig, '<' & $tag & '="' & $value & '">')


EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: saveMagicLauncherConfig
; Description ...: Save the MagicLauncher config from an array
; Syntax ........: saveMagicLauncherConfig($aConfig)
; Parameters ....: $aConfig             - An array containing the MagicLauncher config.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func saveMagicLauncherConfig($aConfig)

	; Save config
	If _FileWriteFromArray(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg", $aConfig, 1) Then
		ConsoleWrite("[Info]: MagicLauncher auto configuration complete" & @CRLF & @CRLF)
	Else
		ConsoleWrite("[Error]: Could not save auto generated profile, manual profile setup required!" & @CRLF)
	EndIf


EndFunc


