#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "..\SAMUpdater\DataIO\Folders.au3"


Opt('MustDeclareVars', 1)

Local $modPackID = "Test"



; A file can be in 1 of 4 states:
; 1) Added - done
; 2) Removed - done
; 3) Unchanged - done
; 4) Changed - done





; #FUNCTION# ====================================================================================================================
; Name ..........: WriteSection
; Description ...: Writes a file info section from a 2d array
; Syntax ........: WriteSection($hFile, $section, $aSectionFileInfo)
; Parameters ....: $hFile               - File handle
;                  $section             - String section name
;                  $aSectionFileInfo    - An 2d array containing the file info
; Return values .: None
; Author ........: Error_998
; Modified ......:
; Remarks .......:
; Related .......: Used internally by writeModpack() function
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func WriteSection($hFile, $section, $aSectionFileInfo)
	; Section header
	FileWriteLine($hFile, @TAB & '<' & $section & '>')

	; Write file info
	For i = 1 To $aSectionFileInfo[0]
		FileWriteLine($hFile, @TAB & @TAB & '<File>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Filename>' & $aSectionFileInfo[i][0] & '</Filename>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Extract>' & $aSectionFileInfo[i][1] & '</Extract>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Path>' & $aSectionFileInfo[i][2] & '</Path>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<md5>' & $aSectionFileInfo[i][3] & '</md5>')
		FileWriteLine($hFile, @TAB & @TAB & @TAB & '<Size>' & $aSectionFileInfo[i][4] & '</Size>')
		FileWriteLine($hFile, @TAB & @TAB & '</File>')
	Next

	; End of Section
	FileWriteLine($hFile, @TAB & '</' & $section & '>')

EndFunc



Func GetFileInfos($aFiles)
	Dim $aFileInfo[ $aFiles[0] ][5]

	For i =  1 To $aAddedFiles[0]
		$aFileInfo[i][0] =	getFilename($aFiles[i])
		$aFileInfo[i][1] = "FALSE"
		$aFileInfo[i][2] = getPath($aFiles[i])
		$aFileInfo[i][3] = _Crypt_HashFile($aFiles[i], $CALG_MD5)
		$aFileInfo[i][4] = getFileSize($aFiles[i])
	Next

	Return $aFileInfo
EndFunc




Func WriteModpack($modPackID, ByRef $aRemovedFiles, ByRef $aAddedFiles, ByRef $aChangedFiles, ByRef $aUnchangedFiles)
	Local $hFile
	Local $aFilesWithFileInfo

	; Open a new xml document for writing
	$hFile = FileOpen(@ScriptDir & "\PackData\modpacks\" & $modPackID & "\" & $modPackID & ".xml", 10) ; erase + create dir
	If $hFile = -1 Then
		ConsoleWrite("[ERROR]: Unable to create - " & @ScriptDir & "\PackData\modpacks\" & $modPackID & "\" & $modPackID & ".xml" & @CRLF)
		MsgBox(48, "Error creating xml document", "Unable to create xml document:" & @CRLF & @ScriptDir & "\PackData\modpacks\" & $modPackID & "\" & $modPackID & ".xml")
		Exit
	EndIf


		; XML Header
		ConsoleWrite("[Info]: Writing modpack xml document" & @CRLF)
		FileWriteLine($hFile,'<ModPack version="1.0">')


		; Get removed files info
		$aFilesWithFileInfo = GetFileInfos($aRemovedFiles)

		; Write Removed section
		ConsoleWrite("[Info]: Writing removed section" & @CRLF)
		WriteSection($hFile, "Removed", $aFilesWithFileInfo)



		; Get added files info
		$aFilesWithFileInfo = GetFileInfos($aAddedFiles)

		; Write Added section
		ConsoleWrite("[Info]: Writing added section" & @CRLF)
		WriteSection($hFile, "Added", $aFilesWithFileInfo)



		; Get changed files info
		$aFilesWithFileInfo = GetFileInfos($aChangedFiles)

		; Write Changed section
		ConsoleWrite("[Info]: Writing changed section" & @CRLF)
		WriteSection($hFile, "Changed", $aFilesWithFileInfo)



		; Get unchanged files info
		$aFilesWithFileInfo = GetFileInfos($aUnchangedFiles)

		; Write Unchanged section
		ConsoleWrite("[Info]: Writing unchanged section" & @CRLF)
		WriteSection($hFile, "Unchanged", $aFilesWithFileInfo)


		; Close XML Header
		FileWriteLine($hFile,'</ModPack>')

	; Close xml document
	FileClose($hFile)

	ConsoleWrite("[Info]: Writing of modpack xml document finnished" & @CRLF)


EndFunc





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

;~ Dim $aFilesOrignal
;~ Dim $aFilesNew
;~ Dim $aAddedFiles
;~ Dim $aRemovedFiles
;~ Dim $aUnchangedFiles[1]
;~ Dim $aChangedFiles[1]

;~ $aUnchangedFiles[0] = 0
;~ $aChangedFiles[0] = 0

;~ ;Get old files and sort it in an array
;~ Dim $sPath = @DesktopDir & "\Folder A\"
;~ $aFilesOrignal = recurseFolders($sPath,"cauldron.*","world;dynmap")
;~ _ArraySort($aFilesOrignal, 0, 1)
;~ ConsoleWrite("Original File Count: " & UBound($aFilesOrignal) - 1 & @CRLF)

;~ ;Get current files and sort it in an array
;~ Dim $sPathNew = @DesktopDir & "\Folder B\"
;~ $aFilesNew = recurseFolders($sPathNew,"cauldron.*","world;dynmap;modpacks")
;~ _ArraySort($aFilesNew, 0, 1)
;~ ConsoleWrite("Current File Count: " & UBound($aFilesNew) - 1 & @CRLF)


;~ ;Store all new files
;~ $aAddedFiles = GetDiff($aFilesOrignal, $aFilesNew, $aUnchangedFiles)
;~ ConsoleWrite("New files added: " & UBound($aAddedFiles) - 1 & @CRLF)
;~ _ArrayDisplay($aAddedFiles, "Added Files")

;~ ReDim $aUnchangedFiles[1]
;~ $aUnchangedFiles[0] = 0

;~ ;Store all removed files
;~ $aRemovedFiles = GetDiff($aFilesNew, $aFilesOrignal, $aUnchangedFiles)
;~ ConsoleWrite("Files removed: " & UBound($aRemovedFiles) - 1 & @CRLF)
;~ _ArrayDisplay($aRemovedFiles, "Removed Files")

;~ ; Above function also returns all the unchanged files
;~ _ArraySort($aUnchangedFiles,0,1)
;~ ;_ArrayDisplay($aUnchangedFiles)


;~ ; Check if any of the unchanged files had any internal changes made and mark them as changed

;~ SplitChangedUnchangedFiles($sPath, $sPathNew, $aUnchangedFiles, $aChangedFiles)
;~ ConsoleWrite("Unchanged files: " & UBound($aUnchangedFiles) - 1 & @CRLF)
;~ _ArrayDisplay($aUnchangedFiles, "Unchanged Files")
;~ ConsoleWrite("Changed files: " & UBound($aChangedFiles) - 1 & @CRLF)
;~ _ArrayDisplay($aChangedFiles, "Changed Files")



;~ $aAddedFiles
;~ $aRemovedFiles
;~ $aChangedFiles
;~ $aUnchangedFiles



