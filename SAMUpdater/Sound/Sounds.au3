#include-once
#include <Timers.au3>
#include "..\DataIO\Download.au3"
#include "..\DataIO\Assets.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: playBackgroundMusic
; Description ...: Play background music callback function
; Syntax ........: playBackgroundMusic($hWnd, $Msg, $iIDTimer, $dwTime)
; Parameters ....: $hWnd                - Window handle to the Hidden AutoIt window
;                  $Msg                 - An unknown value.
;                  $iIDTimer            - An integer value.
;                  $dwTime              - An unknown value.
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
		writeLogEchoToConsole("[Info]: Playing background music..." & @CRLF)
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
Func playBackgroundMusic($dataFolder, $playLenght)
	Local $hWndTimer

	; Download background music if it does not exist in data folder
	writeLogEchoToConsole("[Info]: Initializing Sound data" & @CRLF)
	initSoundAssets($baseURL, $dataFolder)
	writeLogEchoToConsole("[Info]: Initialized" & @CRLF & @CRLF)

	; Start playing background music
	callbackPlayBackgroundMusic("","","","")


	; Create a hidden AutoIt window to get a window handle for a timer
	AutoItWinSetTitle("Music Timer")
	$hWndTimer = WinGetHandle(AutoItWinGetTitle())


	; Create a timer to restart the music track when it reached the specified playLenght
	_Timer_SetTimer($hWndTimer, $playLenght * 1000, "callbackPlayBackgroundMusic")

EndFunc
