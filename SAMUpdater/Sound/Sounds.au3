#include-once
#include <Timers.au3>
#include "..\DataIO\Download.au3"
#include "..\DataIO\Assets.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: playBackgroundMusic
; Description ...: Play background music callback function
; Syntax ........: playBackgroundMusic($hWnd, $Msg, $iIDTimer, $dwTime)
; Parameters ....: $hWnd                - Window handle to the Hidden AutoIt window
;                  $Msg                 - Special parameter used by the timer function.
;                  $iIDTimer            - Special parameter used by the timer function.
;                  $dwTime              - Special parameter used by the timer function.
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func callbackPlayBackgroundMusic($hWnd, $Msg, $iIDTimer, $dwTime)
	#forceref $hWnd, $Msg, $iIDTimer, $dwTime
	; Use Global Var
	Dim $dataFolder

	; Sanity cehck that background.mp3 does exists then plays the sound
	If FileExists($dataFolder & "\PackData\Assets\Sounds\Background.mp3") Then
		; Stop playing sound just in case its still playing
		SoundPlay("")

		; Start music
		SoundPlay($dataFolder & "\PackData\Assets\Sounds\Background.mp3")
	EndIf
EndFunc




; #FUNCTION# ====================================================================================================================
; Name ..........: playBackgroundMusic
; Description ...: Plays a background sound that repeats
; Syntax ........: playBackgroundMusic($musicURL, $dataFolder, $playLenght)
; Parameters ....: $musicURL            - Remote location of background.mp3
;                  $dataFolder          - Application data folder
;                  $playLenght          - Repeat interval of song in seconds
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func playBackgroundMusic($dataFolder)
	Local $playLenght

	Global $hWndTimer
	Global $backgroundSoundTimerID = 0



	; Download background music if it does not exist in data folder
	$playLenght = initSoundAssets($baseURL, $dataFolder)



	; Create a hidden AutoIt window to get a window handle for a timer
	AutoItWinSetTitle("Timer")
	$hWndTimer = WinGetHandle(AutoItWinGetTitle())



	; Check music file exists
	If Not FileExists($dataFolder & "\PackData\Assets\Sounds\background.mp3") Then Return



	; Create F7 Hotkey to toggle background music
	HotKeySet("{F7}", "toggleBackgroundMusic")



	; Check user settings if sound should be enabled
	If IniRead($dataFolder & "\Settings\settings.ini", "Sound","BackgroundMusicOn", "True") <> "True" Then Return


	; Get background play lenght
	$playLenght = getBackgroundPlayLenght()

	; Start playing background music
	writeLogEchoToConsole("[Info]: Playing background music..." & @CRLF)
	callbackPlayBackgroundMusic("","","","")





	; Create a timer to restart the music track when it reached the specified playLenght
	$backgroundSoundTimerID = _Timer_SetTimer($hWndTimer, $playLenght * 1000, "callbackPlayBackgroundMusic")

EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: stopBackgroundMusic
; Description ...: Stops the background music + repeat timer
; Syntax ........: stopBackgroundMusic()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Also updates user settings to disable background music in the future
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func stopBackgroundMusic()

		; Stop any current playing sound
		SoundPlay("")

		; Skip if no background music timer exists
		If $backgroundSoundTimerID = 0 Then Return


		; Disable timer
		_Timer_KillTimer($hWndTimer, $backgroundSoundTimerID)


		; Update user settings
		IniWrite($dataFolder & "\Settings\settings.ini", "Sound", "BackgroundMusicOn", "False")

		writeLog("[Info]: Background music disabled" & @CRLF)
EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: enableBackgroundMusic
; Description ...: Enable background music and save user setting
; Syntax ........: enableBackgroundMusic()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func enableBackgroundMusic()
	Local $playLenght

	; Get background play lenght
	$playLenght = getBackgroundPlayLenght()


	; Start playing background music
	callbackPlayBackgroundMusic("","","","")



	; Check if a background music timer already exists
	If $backgroundSoundTimerID = 0 Then

		; Create a timer to restart the music track when it reached the specified playLenght
		$backgroundSoundTimerID = _Timer_SetTimer($hWndTimer, $playLenght * 1000, "callbackPlayBackgroundMusic")

	Else

		; Reuse timer
		$backgroundSoundTimerID = _Timer_SetTimer($hWndTimer, $playLenght * 1000, "callbackPlayBackgroundMusic", $backgroundSoundTimerID)

	EndIf



	; Update user settings
	IniWrite($dataFolder & "\Settings\settings.ini", "Sound", "BackgroundMusicOn", "True")

	writeLog("[Info]: Background music enabled" & @CRLF)
EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: getBackgroundPlayLenght
; Description ...: Retrive the background music play lenght in seconds
; Syntax ........: getBackgroundPlayLenght()
; Parameters ....:
; Return values .: playlenght
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getBackgroundPlayLenght()
	Local $backgroundPlayLenght

	; Get play lenght
	$backgroundPlayLenght = Int(IniRead($dataFolder &  "\PackData\Assets\assets.ini", "Sounds", "BackgroundMusicPlayLenght", "1") )

	Return $backgroundPlayLenght
EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: toggleBackgroundMusic
; Description ...: Press F7 to Enable / Disable background music
; Syntax ........: toggleBackgroundMusic()
; Parameters ....:
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func toggleBackgroundMusic()

	If IniRead($dataFolder & "\Settings\settings.ini", "Sound", "BackgroundMusicOn", "True") = "True" Then

		stopBackgroundMusic()

	Else

		enableBackgroundMusic()

	EndIf


EndFunc


