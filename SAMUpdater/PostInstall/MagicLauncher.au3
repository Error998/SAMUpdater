#include <File.au3>
#include <Array.au3>

Opt('MustDeclareVars', 1)


; #FUNCTION# ====================================================================================================================
; Name ..........: configureMagicLauncher
; Description ...: Auto configures MagicLauncher to add or update a profile with name $modID
; Syntax ........: configureMagicLauncher($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory)
; Parameters ....: $modID               - The modID.
;				   $profileName			- The Magic Launcher Profile name
;				   $enviroment			- The Magic Launcher enviroment to use
;				   $minecraftJar		- The path to the minecraft jar
;				   $showLog				- Display the Magic Launcher log window
;				   $javaParameters		- Java VM parameters to use
;                  $maxMemory	        - Max memory allocation
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func configureMagicLauncher($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory)
	Local $aConfig
	Local $profileStartIndex


	writeLogEchoToConsole("[Info]: Auto configuration of MagicLauncher started..." & @CRLF)

	; If a config was made from scratch exit function
	If createNewMagicLauncherConfig($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory) Then Return


	; Read MagicLauncher.cfg
	_FileReadToArray(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg", $aConfig)


	; Get the profile start index
	$profileStartIndex = findProfileStartIndex($profileName, $aConfig)


	; Profile not found, create it
	If $profileStartIndex = 0 Then
		insertProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig)

		; New configured profile was inserted and saved
		Return
	EndIf


	; Profile found - update it
	updateProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig, $profileStartIndex)


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
; Syntax ........: createMagicLauncherConfig($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory)
; Parameters ....: $modID               - The modID.
;				   $profileName			- The Magic Launcher Profile name
;				   $enviroment			- The Magic Launcher enviroment to use
;				   $minecraftJar		- The path to the minecraft jar
;				   $showLog				- Display the Magic Launcher log window
;				   $javaParameters		- Java VM parameters to use
;                  $maxMemory	        - Max memory allocation
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func createNewMagicLauncherConfig($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory)
	Local $hFile
    Local $appfolder

	; Config already exists, exit function
	If FileExists(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg") Then Return False


	; Open a new xml document for writing
	$hFile = FileOpen(@AppDataDir & "\.minecraft\magic\MagicLauncher.cfg", 10) ; erase + create dir
		If $hFile = -1 Then
			writeLogEchoToConsole("[ERROR]: Unable to create - " & @AppDataDir & "\.minecraft\magic\MagicLauncher.cfg" & @CRLF)
			MsgBox(48, "Error creating file", "Unable to create MagicLauncher config file - " & @AppDataDir & "\.minecraft\magic\MagicLauncher.cfg")
			Exit
		EndIf
		$appfolder = convertPath(@AppDataDir)

		FileWriteLine($hFile, '<Profile')
		FileWriteLine($hFile, '  <Name="' & $profileName & '">')
		FileWriteLine($hFile, '  <Environment="' & $enviroment & '">')
		FileWriteLine($hFile, '  <MinecraftJar="' & $minecraftJar & '">')
		FileWriteLine($hFile, '  <ShowLog="' & $showLog & '">')
		FileWriteLine($hFile, '  <JavaParameters="' & $javaParameters & '">')
		FileWriteLine($hFile, '  <MaxMemory="' & $maxMemory & '">')
		FileWriteLine($hFile, '  <BaseDir="' & $appfolder & '\\.minecraft\\Modpacks\\' & $modID & '\\.minecraft">')
		FileWriteLine($hFile, '  <InactiveExternalMods=>')
		FileWriteLine($hFile, '  <InactiveCoreMods=>')
		FileWriteLine($hFile, '>')
		FileWriteLine($hFile, '<ActiveProfileIndex="0">')
		FileWriteLine($hFile, '<LastModDir=>')
		FileWriteLine($hFile, '<LoadNews="false">')
		FileWriteLine($hFile, '<CloseAfterLogin="true">')
		FileWriteLine($hFile, '<RememberPassword="true">')


	FileClose($hFile)


	writeLogEchoToConsole("[Info]: Auto configuration complete - New MagicLauncher.cfg created" & @CRLF & @CRLF)


	; New config was created
	Return True
EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: findProfileIndex
; Description ...: Find the index of the profile with name $profileName
; Syntax ........: findProfileIndex($profileName, $aConfig)
; Parameters ....: $profileName         - The profile name to find.
;                  $aConfig             - An array containing the MagicLauncher config.
; Return values .: 0					- Profile index not found
;				 : > 0					- Index of the <Name="$profileName"> entry
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func findProfileStartIndex($profileName, $aConfig)

	For $i = 1 To $aConfig[0]

		If $aConfig[$i] = '  <Name="' & $profileName & '">' Then Return $i

	Next

	Return 0
EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: insertProfile
; Description ...: Insert a new configured profile into MagicLauncher.cfg and save it.
; Syntax ........: insertProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig)
; Parameters ....: $modID               - The modID.
;				   $profileName			- The Magic Launcher Profile name
;				   $enviroment			- The Magic Launcher enviroment to use
;				   $minecraftJar		- The path to the minecraft jar
;				   $showLog				- Display the Magic Launcher log window
;				   $javaParameters		- Java VM parameters to use
;                  $maxMemory	        - Max memory allocation
;                  $aConfig             - An array containing the MagicLauncher config.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func insertProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig)
	local $path

	writeLogEchoToConsole("[Info]: No existing modpack profile was found - Adding new profile '" & $profileName & "'" & @CRLF)

    $path = convertPath(@AppDataDir)

	_ArrayInsert($aConfig, 1, '<Profile')
	_ArrayInsert($aConfig, 2, '  <Name="' & $profileName & '">')
	_ArrayInsert($aConfig, 3, '  <Environment="' & $enviroment & '">')
	_ArrayInsert($aConfig, 4, '  <MinecraftJar="' & $minecraftJar & '">')
	_ArrayInsert($aConfig, 5, '  <ShowLog="' & $showLog & '">')
	_ArrayInsert($aConfig, 6, '  <JavaParameters="' & $javaParameters & '">')
	_ArrayInsert($aConfig, 7, '  <MaxMemory="' & $maxMemory & '">')
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
		writeLogEchoToConsole("[Info]: MagicLauncher auto configuration complete" & @CRLF & @CRLF)
	Else
		writeLogEchoToConsole("[Error]: Could not save auto generated profile, manual profile setup required!" & @CRLF)
	EndIf


EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: updateProfile
; Description ...: Update an existing profile that is named $modID
; Syntax ........: updateProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig, $profileStartIndex)
; Parameters ....: $modID               - The modID.
;				   $profileName			- The Magic Launcher Profile name
;				   $enviroment			- The Magic Launcher enviroment to use
;				   $minecraftJar		- The path to the minecraft jar
;				   $showLog				- Display the Magic Launcher log window
;				   $javaParameters		- Java VM parameters to use
;                  $maxMemory	        - Max memory allocation
;                  $aConfig             - An array containing the MagicLauncher config.
;                  $profileStartIndex   - Profile start index.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateProfile($modID, $profileName, $enviroment, $minecraftJar, $showLog, $javaParameters, $maxMemory, $aConfig, $profileStartIndex)
	Local $profileEndIndex
	Local $path


	$profileEndIndex = findProfileEndIndex($profileStartIndex, $aConfig)
    $path = convertPath(@AppDataDir)


	; Keep clients maxMemory setting if it is larger than the default
	$maxMemory = getMaxMem($profileStartIndex, $profileEndIndex, $aConfig, $maxMemory)

	; Update Environment
	updateProfileTag($profileStartIndex, $profileEndIndex, "Environment", $enviroment, $aConfig)


	; Update MinecraftJar
	updateProfileTag($profileStartIndex, $profileEndIndex, "MinecraftJar", $minecraftJar, $aConfig)


	; Update ShowLog
	updateProfileTag($profileStartIndex, $profileEndIndex, "ShowLog", $showLog, $aConfig)


	; Update JavaParameters
	updateProfileTag($profileStartIndex, $profileEndIndex, "JavaParameters", $javaParameters, $aConfig)


	; Update MaxMemory
	updateProfileTag($profileStartIndex, $profileEndIndex, "MaxMemory", $maxMemory, $aConfig)


	; Update BaseDir
	updateProfileTag($profileStartIndex, $profileEndIndex, "BaseDir", $path & "\\.minecraft\\Modpacks\\" & $modID & "\\.minecraft", $aConfig)


	; Update InactiveExternalMods
	updateProfileTag($profileStartIndex, $profileEndIndex, "InactiveExternalMods", "", $aConfig)


	; Update InactiveCoreMods
	updateProfileTag($profileStartIndex, $profileEndIndex, "InactiveCoreMods", "", $aConfig)


	; Save config
	saveMagicLauncherConfig($aConfig)


EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: findProfileEndIndex
; Description ...: Finds the end of profile index
; Syntax ........: findProfileEndIndex($profileStartIndex, $aConfig)
; Parameters ....: $profileStartIndex   - The start index of the profile.
;                  $aConfig             - An array containing the MagicLauncher config.
; Return values .: The index of the end of profile section
;				   Returns 0 if the end of the profile can not be determined - corrupt config
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func findProfileEndIndex($profileStartIndex, $aConfig)

	For $i = $profileStartIndex To $aConfig[0]

		If $aConfig[$i] = ">" Then Return $i

	Next

	; Could not determine the end of the current profile, config is corrupt
	writeLogEchoToConsole(@CRLF & "[Warning]: This is odd, unable to determine the end of the profile section in MagicLauncher.cfg!" & @CRLF)
	writeLogEchoToConsole("[Warning]: Recommend to delete .\minecraft\magic\MagicLauncher.cfg and run the updater again" & @CRLF & @CRLF)
	Return 0

EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: updateProfileTag
; Description ...: Update profile tag, if tag does not exist it will be added to the profile
; Syntax ........: updateProfileTag($profileStartIndex, $profileEndIndex, $tag, $value, Byref $aConfig)
; Parameters ....: $profileStartIndex   - The start index of the profile.
;                  $profileEndIndex     - The end index of the profile.
;                  $tag                 - Tag to update.
;                  $value               - Value of the tag to update.
;                  $aConfig             - [in/out] An array containing the MagicLauncher config.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Supported tags: Environment, MinecraftJar, ShowLog, JavaParameters, MaxMemory, BaseDir, InactiveCoreMods and
;				   InactiveExternalMods
;				   If $value is empty the output tag will not include ""
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func updateProfileTag($profileStartIndex, $profileEndIndex, $tag, $value, ByRef $aConfig)

	For $i = $profileStartIndex To $profileEndIndex
		; Tag found, update it
		If StringInStr($aConfig[$i], $tag) <> 0 Then
			; Check if $value is blank then write without quotes
			If $value = "" Then
				$aConfig[$i] = '  <' & $tag & '=>'

			Else
				; Set $value
				$aConfig[$i] = '  <' & $tag & '="' & $value & '">'
			EndIf


			; Tag updated
			Return

		EndIf

	Next

	; Tag not found add it to the profile
	; Check if $value is blank then write without quotes
	If $value = "" Then
		_ArrayInsert($aConfig, $profileEndIndex , '  <' & $tag & '=>')

	Else

		_ArrayInsert($aConfig, $profileEndIndex , '  <' & $tag & '="' & $value & '">')

	EndIf


	; Update array item count
	$aConfig[0] = $aConfig[0] + 1

	Return


EndFunc





; #FUNCTION# ====================================================================================================================
; Name ..........: getMaxMem
; Description ...: Check the existing maxMemory used in the profile and return whatever is bigger between current and default mem
; Syntax ........: getMaxMem($profileStartIndex, $profileEndIndex, $aConfig, $defaultMaxMem)
; Parameters ....: $profileStartIndex   - The start index of the profile.
;                  $profileEndIndex     - The end index of the profile.
;                  $aConfig             - [in/out] An array containing the MagicLauncher config.
;				   $defaultMaxMem		- Default max memory setting
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getMaxMem($profileStartIndex, $profileEndIndex, $aConfig, $defaultMaxMem)
	Local $maxMem

	; Loop all entries in current profile
	For $i = $profileStartIndex To $profileEndIndex

		; Find the MaxMem Tag
		If StringInStr($aConfig[$i], "<MaxMemory=") <> 0 Then
			$maxMem = StringTrimLeft($aConfig[$i], 14)
			$maxMem = StringTrimRight($maxMem, 2)

			; MaxMem is smaller than recommended, exit loop and set it to default
			If $maxMem < $defaultMaxMem Then ExitLoop


			; Return clients custom MaxMem setting
			Return $maxMem
		EndIf


	Next


	; Default MaxMem setting
	Return $defaultMaxMem

EndFunc