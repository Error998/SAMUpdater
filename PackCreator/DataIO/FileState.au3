#include-once
#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>

Opt('MustDeclareVars', 1)


Func GetDiff(ByRef $aArray1, ByRef $aArray2, ByRef $aUnchangedFiles)
	Dim $aTemp[1]

	;No items in array
	$aTemp[0] = 0

	;For each item to search
	For $i = 1 to $aArray2[0]

		Dim $iKeyIndex = _ArrayBinarySearch($aArray1, $aArray2[$i], 1, $aArray1[0])
		If Not @error Then
			;These files are still the same
			_ArrayAdd($aUnchangedFiles, $aArray2[$i])
			$aUnchangedFiles[0] = $aUnchangedFiles[0] + 1
		Else
			;MsgBox(0, 'Entry Not found - Error: ' & @error, $i & ": " & $aArray2[$i])
			;ConsoleWrite($aArray2[$i] & @CRLF)
			_ArrayAdd($aTemp, $aArray2[$i])
			$aTemp[0] = $aTemp[0] + 1
		EndIf
	Next

	Return $aTemp
EndFunc



Func SplitChangedUnchangedFiles($sPath, $sPathNew, ByRef $aUnchangedFiles, ByRef $aChangedFiles)
	Dim $aTempUnchangedFiles[1]
	Dim $aTempChangedFiles[1]

	$aTempChangedFiles[0] = 0
	$aTempUnchangedFiles[0] = 0

	For $i = 1 To $aUnchangedFiles[0]
		; Create a md5 hash of the file.
		If _Crypt_HashFile($sPath & "\" & $aUnchangedFiles[$i], $CALG_MD5) = _Crypt_HashFile($sPathNew & "\" & $aUnchangedFiles[$i], $CALG_MD5) Then
			;ConsoleWrite("[OK] - " & $aFiles[$i] & @CRLF)
			_ArrayAdd($aTempUnchangedFiles, $aUnchangedFiles[$i])
			$aTempUnchangedFiles[0] = $aTempUnchangedFiles[0] + 1

		Else
			;ConsoleWrite("[FAILED] - " & $aFiles[$i] & @CRLF)
			_ArrayAdd($aTempChangedFiles, $aUnchangedFiles[$i])
			$aTempChangedFiles[0] = $aTempChangedFiles[0] + 1
		EndIf
	Next

	$aUnchangedFiles = $aTempUnchangedFiles
	$aChangedFiles = $aTempChangedFiles
EndFunc