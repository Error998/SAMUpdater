#include-once
#include <Timers.au3>
#include "..\DataIO\Download.au3"
#include "..\Console\ConsoleUtils.au3"

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
	Dim $dataFolder

	; Sanity cehck that background.mp3 does exists then plays the sound
	If FileExists($dataFolder & "\PackData\Sounds\Background.mp3") Then
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



Func playBackgroundMusic($musicURL, $dataFolder, $playLenght)
	; Download background music if it does not exist in data folder
	getBackgroundMusic($musicURL, $dataFolder)



	; Start playing background music
	callbackPlayBackgroundMusic("","","","")

	; Create a timer to restart the music track when it reached the specified playLenght
	_Timer_SetTimer(_CmdGetWindow(@AutoItPID),$playLenght * 1000,"callbackPlayBackgroundMusic")

EndFunc
