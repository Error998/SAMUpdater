#include <Array.au3>
#include <Crypt.au3>
#include <File.au3>
#include "includes\Folders.au3"
#include "includes\RecFileListToArray.au3"
#include "forms\frmModpackDetails.au3"
#include "forms\frmOptions.au3"

Opt('MustDeclareVars', 1)




; A file can be in 1 of 4 states:
; 1) Added - done
; 2) Removed - done
; 3) Unchanged - done
; 4) Changed - done


Func recurseFolders($sPath, $sExcludeFile = "", $sExcludeEntireFolder = "")
    ; A sorted list of all files and folders with optional exclusions
	local $aFiles = _RecFileListToArray($sPath, "*|" & $sExcludeFile & "|" & $sExcludeEntireFolder, 1, 1, 1)
	if @error = 1 Then
		ConsoleWrite("[ERROR]: Unable to recurse folders " & @error & " - " & " Extended: " &  @extended & @CRLF)
		Exit
	EndIf

;------------------------------------------------------------------
;Errrhm wtf? Remove, then again I did something with the path...
;------------------------------------------------------------------
;~ 	; Fix derpiness of sorting returned by _RecFileListToArray
;~ 	Local $aTemp[$aFiles[0] + 1][2]
;~     ; Split path and filename
;~ 	For $i = 1 To $aFiles[0]
;~ 		$aTemp[$i][0] = getPath($aFiles[$i])
;~ 		$aTemp[$i][1] = getFilename($aFiles[$i])
;~ 	Next
;~ 	; Sort path
;~ 	_ArraySort($aTemp, 0, 1)
;~ 	; Restore fixed sorted array back
;~ 	For $i = 1 To $aFiles[0]
;~ 		$aFiles[$i] = $aTemp[$i][0] & "\" & $aTemp[$i][1]
;~ 	Next

	Return $aFiles
EndFunc


Func WriteModpack(ByRef $aModpackHeader, ByRef $aFiles)
	; ********** TODO: Still need to implement Module attributes - (Remove/Overwrite) ***************
	Local $bRemove = False

	Local $aExportOptions[4]
	Local $sPath
	Local $hFile
	Local $iFileSize, $iTotalFileSize
	Local $bHash

	$hFile = FileOpen(@ScriptDir & "\PackData\packs.xml", 10) ;erase + create dir)
	If $hFile = -1 Then
		ConsoleWrite("[ERROR]: Unable to open - " & @ScriptDir & "\PackData\packs.xml" & @CRLF)
		Exit
	EndIf
	; Packs Header
	FileWriteLine($hFile,'<ServerPacks version="1.0">')

	; Modpack Header
	FileWriteLine($hFile,"	<ModPack>")
	FileWriteLine($hFile,"		<Info>")
	FileWriteLine($hFile,"			<ModPackID>" & $aModpackHeader[1] & "</ModPackID>")
	FileWriteLine($hFile,"			<ServerName>" & $aModpackHeader[2] & "</ServerName>")
	FileWriteLine($hFile,"			<ServerVersion>" & $aModpackHeader[3] & "</ServerVersion>")
	FileWriteLine($hFile,"			<NewsPage>" & getFilename($aModpackHeader[4]) & "</NewsPage>")
	FileWriteLine($hFile,"			<ModPackIcon>" & getFilename($aModpackHeader[5]) & "</ModPackIcon>")
	FileWriteLine($hFile,"			<Description>" & $aModpackHeader[6] & "</Description>")
	FileWriteLine($hFile,"			<ServerConnection>" & $aModpackHeader[7] & "</ServerConnection>")
	FileWriteLine($hFile,"			<ForgeID>" & $aModpackHeader[8] & "</ForgeID>")
	FileWriteLine($hFile,"			<URL>" & $aModpackHeader[9] & "</URL>")
	FileWriteLine($hFile,"		</Info>")
	FileWriteLine($hFile,"		<Files>")

	; Modules Section

	; To optimize performance start the crypt library.
	_Crypt_Startup()

	; Check Export Settings - Options.dat
	If  FileExists(@ScriptDir & "\Options.dat") Then
		_FileReadToArray(@ScriptDir & "\Options.dat", $aExportOptions)
	Else
		; File does not exist - Load default settings
		$aExportOptions[1] = 0
		$aExportOptions[2] = 0
		ConsoleWrite("[Info]: Loading defualt options" & @CRLF)
	EndIf

	; Initialize Export Folders if we are exporting
	If $aExportOptions[1] = 1 Then
		; Make sure Export folder exists - (..\Export_Folder\ModpackID)
		createFolder($aExportOptions[3] & "\" & $aModpackHeader[1])
		;Create sub dir "Data" for ModpackIcon and News files
		createFolder($aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data")

		;Should we clear the export folder?
		If $aExportOptions[2] = 1 Then
			FileDelete($aExportOptions[3] & "\" & $aModpackHeader[1] & "\*.*")
			FileDelete($aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data\*.*")
		EndIf
	EndIf

	; Export News and Icon files
	If $aExportOptions[1] = 1 Then
		; News
		If Not $aModpackHeader[4] = "" Then
			If FileCopy($aModpackHeader[4], $aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data\" & getFilename($aModpackHeader[4]), 1) Then
				ConsoleWrite("[Info]: Copied News - " & getFilename($aModpackHeader[4]) & @CRLF)
			Else
				ConsoleWrite("[ERROR]: Failed to copy News - " & $aModpackHeader[4] & " to " & $aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data\" & getFilename($aModpackHeader[4]) & @CRLF)
			EndIf
		EndIf

		; Modpack Icon
		If Not $aModpackHeader[5] = "" Then
			If FileCopy($aModpackHeader[5], $aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data\" & getFilename($aModpackHeader[5]), 1) Then
				ConsoleWrite("[Info]: Copied Modpack Icon - " & getFilename($aModpackHeader[5]) & @CRLF)
			Else
				ConsoleWrite("[ERROR]: Failed to copy Modpack Icon - " & $aModpackHeader[5] & " to " & $aExportOptions[3] & "\" & $aModpackHeader[1] & "\Data\" & getFilename($aModpackHeader[5]) & @CRLF)
			EndIf
		EndIf
	EndIf

	ProgressOn("Creating Modpack Data File","")

	for $i = 1 to $aFiles[0]
		; Full path - (Base Source Folder + modpack treeview)
		$sPath = $aModpackHeader[10] & "\" & $aFiles[$i]

		FileWriteLine($hFile,"			<Module>")
		FileWriteLine($hFile,"				<Filename>" & getFilename($sPath) & "</Filename>")
		FileWriteLine($hFile,"				<Extract>FALSE</Extract>")
		; Prefix extra path if present
		If $aModpackHeader[11] = "" Then
			FileWriteLine($hFile,"				<Path>" & getPath($aFiles[$i]) & "</Path>")
		Else
			FileWriteLine($hFile,"				<Path>" & $aModpackHeader[11] & "\" & getPath($aFiles[$i]) & "</Path>")
		EndIf

		; Create a md5 hash of the file.
		$bHash = _Crypt_HashFile($sPath, $CALG_MD5)
		FileWriteLine($hFile,"				<md5>" & $bHash & "</md5>")

		$iFileSize = getFileSize($sPath)
		; ********** TODO: Only add filesize to total if it not marked for removal! *************************
		$iTotalFileSize += $iFileSize
		FileWriteLine($hFile,"				<Size>" & $iFileSize &  "</Size>")


		FileWriteLine($hFile,"				<Required>TRUE</Required>")
		FileWriteLine($hFile,"				<Remove>FALSE</Remove>")
		FileWriteLine($hFile,"				<Overwrite>FALSE</Overwrite>")
		FileWriteLine($hFile,"			</Module>")

		#region Export Modules
			; Export file
			If $aExportOptions[1] = 1 Then
				; File marked for removal
				If $bRemove Then
					; Remove file in Export destination if it exists
					If FileExists($aExportOptions[3] & "\" & $aModpackHeader[1] & "\" & $bHash) Then
						FileRecycle($aExportOptions[3] & "\" & $aModpackHeader[1] & "\" & $bHash)
						ConsoleWrite("[Info]: Removed - " & $bHash & @CRLF)
					Else
						ConsoleWrite("[Info]: Destination file does not exist, nothing to remove - " & $bHash & @CRLF)
					EndIf

				Else
					; File marked for copy -  Check if file does not already exists
					If Not FileExists($aExportOptions[3] & "\" & $aModpackHeader[1] & "\" & $bHash) Then
						; Copy the file
						If FileCopy($sPath, $aExportOptions[3] & "\" & $aModpackHeader[1] & "\" & $bHash) Then
							ConsoleWrite("[Info]: Copied - " & $bHash & @CRLF)
						Else
							ConsoleWrite("[ERROR]: Failed to copy - " & $sPath & " to " & $aExportOptions[3] & "\" & $aModpackHeader[1] & "\" & $bHash & @CRLF)
						EndIf
					Else
						; Destination file already exists
						ConsoleWrite("[Info]: File already exists - " & $bHash & @CRLF)
					EndIf
				EndIf
			EndIf
		#endregion Eport Modules

		ProgressSet(Floor($i / $aFiles[0] * 100))
	Next

	ProgressOff()

	; Shutdown the crypt library.
	_Crypt_Shutdown()

	; Footer - Close Header tags
	FileWriteLine($hFile,"		</Files>")
	FileWriteLine($hFile,"	</ModPack>")
	FileWriteLine($hFile,"</ServerPacks>")

	FileClose($hFile)

	ConsoleWrite("[Info]: Total Pack size - " & Round($iTotalFileSize / 1048576,2) & "MB" & @CRLF)


EndFunc


Func getFilename($sPath)
	Local $i

	If $sPath = "" Then
		Return ""
	EndIf

	$i = StringInStr($sPath,"\", 0, -1)
	Return StringRight($sPath, (StringLen($sPath) - $i))

EndFunc


Func getPath($sPath)
	Local $i
	Local $sLen

	$i = StringInStr($sPath,"\", 0, -1)

	Return StringLeft($sPath, $i - 1)
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

Dim $aFilesOrignal
Dim $aFilesNew
Dim $aAddedFiles
Dim $aRemovedFiles
Dim $aUnchangedFiles[1]
Dim $aChangedFiles[1]

$aUnchangedFiles[0] = 0
$aChangedFiles[0] = 0

;Get old files and sort it in an array
Dim $sPath = "C:\Data\Games - ISO\Minecraft\SA Minecraft\Client\MC 1.6.4 Core\.minecraft"
$aFilesOrignal = recurseFolders($sPath,"cauldron.*","world;dynmap")
_ArraySort($aFilesOrignal, 0, 1)
ConsoleWrite("Original File Count: " & UBound($aFilesOrignal) - 1 & @CRLF)

;Get current files and sort it in an array
Dim $sPathNew = "C:\Users\Jock\AppData\Roaming\.minecraft"
$aFilesNew = recurseFolders($sPathNew,"cauldron.*","world;dynmap;modpacks")
_ArraySort($aFilesNew, 0, 1)
ConsoleWrite("Current File Count: " & UBound($aFilesNew) - 1 & @CRLF)


;Store all new files
$aAddedFiles = GetDiff($aFilesOrignal, $aFilesNew, $aUnchangedFiles)
ConsoleWrite("New files added: " & UBound($aAddedFiles) - 1 & @CRLF)
_ArrayDisplay($aAddedFiles, "Added Files")

ReDim $aUnchangedFiles[1]
$aUnchangedFiles[0] = 0

;Store all removed files
$aRemovedFiles = GetDiff($aFilesNew, $aFilesOrignal, $aUnchangedFiles)
ConsoleWrite("Files removed: " & UBound($aRemovedFiles) - 1 & @CRLF)
_ArrayDisplay($aRemovedFiles, "Removed Files")

; Above function also returns all the unchanged files
_ArraySort($aUnchangedFiles,0,1)
;_ArrayDisplay($aUnchangedFiles)


; Check if any of the unchanged files had any internal changes made and mark them as changed

SplitChangedUnchangedFiles($sPath, $sPathNew, $aUnchangedFiles, $aChangedFiles)
ConsoleWrite("Unchanged files: " & UBound($aUnchangedFiles) - 1 & @CRLF)
_ArrayDisplay($aUnchangedFiles, "Unchanged Files")
ConsoleWrite("Changed files: " & UBound($aChangedFiles) - 1 & @CRLF)
_ArrayDisplay($aChangedFiles, "Changed Files")



;~ $aAddedFiles
;~ $aRemovedFiles
;~ $aChangedFiles
;~ $aUnchangedFiles


