#include <Array.au3>
#include <Crypt.au3>
#include "includes\Folders.au3"
#include "includes\RecFileListToArray.au3"
#include "forms\frmModpackDetails.au3"
#include "forms\frmOptions.au3"

Opt('MustDeclareVars', 1)

Func recurseFolders($sPath)
; A sorted list of all files and folders in the AutoIt installation
	local $aFiles = _RecFileListToArray($sPath, "*", 1, 1, 1)
	if @error = 1 Then
		ConsoleWrite("[ERROR]: Unable to recurse folders " & @error & " - " & " Extended: " &  @extended & @CRLF)
		Exit
	EndIf

	; Fix derpiness of sorting returned by _RecFileListToArray
	Local $aTemp[$aFiles[0] + 1][2]
    ; Split path and filename
	For $i = 1 To $aFiles[0]
		$aTemp[$i][0] = getPath($aFiles[$i])
		$aTemp[$i][1] = getFilename($aFiles[$i])
	Next
	; Sort path
	_ArraySort($aTemp, 0, 1)
	; Restore fixed sorted array back
	For $i = 1 To $aFiles[0]
		$aFiles[$i] = $aTemp[$i][0] & "\" & $aTemp[$i][1]
	Next

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



LoadFormModpackDetails()


While True
	Sleep(2000)
WEnd

