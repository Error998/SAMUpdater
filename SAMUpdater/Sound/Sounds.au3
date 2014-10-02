#include-once
#include <Timers.au3>
#include "..\DataIO\Download.au3"

; Play background music callback function
; #FUNCTION# ====================================================================================================================
; Name ..........: playBackgroundMusic
; Description ...:
; Syntax ........: playBackgroundMusic($hWnd, $Msg, $iIDTimer, $dwTime)
; Parameters ....: $hWnd                - A handle value.
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
	If FileExists($dataFolder & "\PackData\Sounds\Background.mp3") Then
		; Stop playing sound just in case its still playing
		SoundPlay("")

		; Start music
		ConsoleWrite("[Info]: Playing background music..." & @CRLF)
		SoundPlay($dataFolder & "\PackData\Sounds\Background.mp3")
	EndIf
EndFunc



; #FUNCTION# ====================================================================================================================
; Name ..........: getBackgroundMusic
; Description ...: Use cached music, if a hash is supplied verify music, if hash fails or music does not exist download it.
; Syntax ........: getBackgroundMusic($musicURL, $dataFolder, [$hash = ""])
; Parameters ....: $musicURL 				- URL of remote background.mp3
;				   $dataFolder				- Application data folder
;				   $hash					- (Optional) MD5 hash of background.mp3
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......: Added hash parameter as optional until its fully implemented in the calling function
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getBackgroundMusic($musicURL, $dataFolder, $hash = "")
	If FileExists($dataFolder & "\PackData\Sounds\background.mp3") Then
		If (Not $hash = "" And compareHash($dataFolder & "\PackData\Sounds\background.mp3", $hash)) Or $hash = "" Then
			ConsoleWrite("[Info]: Using cached background music" & @CRLF)
			Return
		EndIf
	EndIf

	ConsoleWrite("[Info]: Downloading background music" & @CRLF)
	downloadAndVerify($musicURL, "PackData\Sounds\background.mp3", $dataFolder)
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
Func playBackgroundMusic($musicURL, $dataFolder, $playLenght)
	Local $hWndTimer

	; Download background music if it does not exist in data folder
	getBackgroundMusic($musicURL, $dataFolder)


	; Start playing background music
	callbackPlayBackgroundMusic("","","","")


	; Create a hidden AutoIt window to get a window handle for a timer
	AutoItWinSetTitle("Music Timer")
	$hWndTimer = WinGetHandle(AutoItWinGetTitle())


	; Create a timer to restart the music track when it reached the specified playLenght
	_Timer_SetTimer($hWndTimer, $playLenght * 1000, "callbackPlayBackgroundMusic")

EndFunc
