#include-once

; #FUNCTION# ====================================================================================================================
; Name...........: _CmdGetWindow
; Description ...: Locates the window handle for a given Command Prompt process.
; Syntax.........: _CmdGetWindow($pCmd)
; Parameters ....: $pCmd  - Process id of the Command Prommpt application
; Return values .: Success - Window handle
;                  Failure - -1, sets @error
;                  |1 - Process $pCmd not found
; Author ........: Phil Hibbs (phil at hibbs dot me dot uk)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/112372-command-prompt-automation/
; Example .......:
; ===============================================================================================================================
Func _CmdGetWindow( $pCmd )
    Local $WinList, $i
    $WinList = WinList()
    For $i = 1 to $WinList[0][0]
        If $WinList[$i][0] <> "" And WinGetProcess( $WinList[$i][1] ) = $pCmd Then
            Return $WinList[$i][1]
        EndIf
    Next
    Return SetError(1, 0, -1)
EndFunc   ;==>_CmdGetWindow
