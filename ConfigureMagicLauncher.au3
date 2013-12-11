#include <File.au3>
#include <Array.au3>
Opt('MustDeclareVars', 1)


Func ConfigureMagicLauncher($sModID, $sForgeID)
	Local $sMagicLauncher
	Local $sAppData
	Local $bConfigChanged = False
	Local $bProfileFound = False

	; Check that the magic launcher config exists - Sanity check
	If Not FileExists(@AppDataDir & "\.minecraft\magic\magiclauncher.cfg") Then
		ConsoleWrite("[Warning]: Magic Launcher config not found - Unable to auto configure Magic Launcher" & @CRLF)
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
				If $sMagicLauncher[$i + 1] = '  <Environment="1.6.4-Forge9.11.1.952">' Then
					ConsoleWrite("[Info]: Correct enviroment selected" & @CRLF)
				Else
					; Set the enviroment to the correct setting
					$sMagicLauncher[$i + 1] = '  <Environment="' & $sForgeID & '">'
					$bConfigChanged = True
					ConsoleWrite("[Info]: Fixed profile enviroment" & @CRLF)
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

		; Convert %appdata% path to "\\" instead of "\"
		$sAppData = @AppDataDir
		$sAppData = StringReplace($sAppData, "\", "*")
		$sAppData = StringReplace($sAppData, "*", "\\")

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
		; Set the active profile to our mod pack profile
		For $i = 1 to $sMagicLauncher[0]
			If StringInStr($sMagicLauncher[$i], "<ActiveProfileIndex=") <> 0 Then
				$sMagicLauncher[$i] = '<ActiveProfileIndex="0">'
				ConsoleWrite("[Info]: Setting active profile to " & $sModID & @CRLF)
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


;ConfigureMagicLauncher("TESTSERVER", "1.6.4-Forge9.11.1.952")