#include-once
#include <MsgBoxConstants.au3>

Opt('MustDeclareVars', 1)







; #FUNCTION# ====================================================================================================================
; Name ..........: initColors
; Description ...: Set color constants and load Kernel32.dll
; Syntax ........: initColors()
; Parameters ....:
; Return values .: Return handle to Kernel32.dll
; Author ........: Unknown
; Modified ......: Error_998
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func initColors()
	Global Const    $FOREGROUND_Black       		= 0x0000
	Global Const    $FOREGROUND_Blue        		= 0x0001
	Global Const    $FOREGROUND_Green       		= 0x0002
	Global Const    $FOREGROUND_Cyan        		= 0x0003
	Global Const    $FOREGROUND_Red         		= 0x0004
	Global Const    $FOREGROUND_Magenta     		= 0x0005
	Global Const    $FOREGROUND_Yellow      		= 0x0006
	Global Const    $FOREGROUND_Grey        		= 0x0007
	Global Const    $FOREGROUND_Light_Blue  		= 0x0009
	Global Const    $FOREGROUND_Light_Green 		= 0x000A
	Global Const    $FOREGROUND_Light_Aqua          = 0x000B
	Global Const    $FOREGROUND_Light_Red           = 0x000C
	Global Const    $FOREGROUND_Light_Purple        = 0x000D
	Global Const    $FOREGROUND_Light_Yellow        = 0x000E
	Global Const    $FOREGROUND_Bright_White        = 0x000E

	Global Const    $BACKGROUND_Black       		= 0x0000
	Global Const    $BACKGROUND_Blue        		= 0x0010
	Global Const    $BACKGROUND_Green       		= 0x0020
	Global Const    $BACKGROUND_Cyan        		= 0x0030
	Global Const    $BACKGROUND_Red         		= 0x0040
	Global Const    $BACKGROUND_Magenta     		= 0x0050
	Global Const    $BACKGROUND_Yellow      		= 0x0060
	Global Const    $BACKGROUND_Grey        		= 0x0070
	Global Const    $BACKGROUND_White       		= 0x0080
	; Load Kernel32.dll
	Local $hdllKernel32 = DllOpen("kernel32.dll")
	IF @error Then
        writeLogEchoToConsole("[Error]: Color initialization failed - could not open Kernel32.dll" & @CRLF)
		MsgBox($MB_ICONERROR, "Error loading dll", "Color initialization failed!" & @CRLF & "Could not open Kernel32.dll")
        Exit
    EndIf

	; Return handle to Kernel32.dll
	Return $hdllKernel32

EndFunc






; #FUNCTION# ====================================================================================================================
; Name ..........: setConsoleColor
; Description ...: Set the console color
; Syntax ........: setConsoleColor($iColor)
; Parameters ....: $iColor              - Color to set.
; Return values .: None
; Author ........: Unknown
; Modified ......: Error_998
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func setConsoleColor($iColor)
    Local $aRet, $aRet2

	; Get Standard output handle
	$aRet = DllCall($hdllKernel32,"hwnd","GetStdHandle","int",-11);$STD_INPUT_HANDLE = -10,$STD_OUTPUT_HANDLE = -11,$STD_ERROR_HANDLE = -12

	If Not UBound($aRet) > 0 Then
        writeLogEchoToConsole("[WARNING]: Get standard output handle failed - setConsoleColor" & @CRLF)
        Return 0
    EndIf


	; Set console color
    $aRet2 = DllCall($hdllKernel32,"int","SetConsoleTextAttribute","hwnd",$aRet[0],"ushort",$iColor)
    If Not UBound($aRet2) > 0 Then
        writeLogEchoToConsole("[Warning]: SetConsoleTextAttribute failed - setConsoleColor" & @CRLF)
        Return 0
    EndIf


    ;Note: The StdHandle doesn't need to be closed because the handle wasn't opened.  It was gotten.
    If $aRet2 <> 0 Then
        Return 1
    Else
        Return 0
    EndIf

EndFunc




