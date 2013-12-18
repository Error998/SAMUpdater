#include <Array.au3>
#include <Crypt.au3>
#include "includes\Folders.au3"
#include "includes\RecFileListToArray.au3"
#include "forms\frmModpackDetails.au3"
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


Func writePack()
	Local $hFile
	Local $iFileSize, $iTotalFileSize
	Local $sPath = @DesktopDir & "\Roaming\1.6.4 Modded Update 3\"
	Local $bHash

	$hFile = FileOpen(@WorkingDir & "\PackData\packs.xml", 10) ;erase + create dir)
	If $hFile = -1 Then
		ConsoleWrite("[ERROR]: Unable to open - " & @WorkingDir & "\PackData\packs.xml" & @CRLF)
		Exit
	EndIf

	FileWriteLine($hFile,'<ServerPacks version="1.0">')
	FileWriteLine($hFile,"	<ModPack>")
	FileWriteLine($hFile,"		<Info>")
	FileWriteLine($hFile,"			<ModPackID>TestServer</ModPackID>")
	FileWriteLine($hFile,"			<ServerName>SA Minecraft Test Server</ServerName>")
	FileWriteLine($hFile,"			<ServerVersion>1.6.4 Update 2</ServerVersion>")
	FileWriteLine($hFile,"			<NewsPage>news.php</NewsPage>")
	FileWriteLine($hFile,"			<ModPackIcon>icon.jpg</ModPackIcon>")
	FileWriteLine($hFile,"			<Discription>SAM Test Server Pack used for testing the newest mods and migration platform.</Discription>")
	FileWriteLine($hFile,"			<ServerConnection>test.saminecraft.co.za:25567</ServerConnection>")
	FileWriteLine($hFile,"			<ForgeID>1.6.4-Forge9.11.1.952</ForgeID>")
	FileWriteLine($hFile,"			<URL>http://localhost/SAMUpdater</URL>")
	FileWriteLine($hFile,"		</Info>")
	FileWriteLine($hFile,"		<Files>")

	Local $aFiles = recurseFolders($sPath)

	; To optimize performance start the crypt library.
	_Crypt_Startup()

	ProgressOn("Creating modpack","")

	for $i = 1 to $aFiles[0]
		FileWriteLine($hFile,"			<Module>")
		FileWriteLine($hFile,"				<name></name>")
		FileWriteLine($hFile,"				<version></version>")
		FileWriteLine($hFile,"				<filename>" & getFilename($aFiles[$i]) & "</filename>")
		FileWriteLine($hFile,"				<extract>false</extract>")
		FileWriteLine($hFile,"				<path>" & getPath($aFiles[$i]) & "</path>")

		; Create a md5 hash of the file.
		$bHash = _Crypt_HashFile($sPath & $aFiles[$i], $CALG_MD5)
		FileWriteLine($hFile,"				<md5>" & $bHash & "</md5>")

		$iFileSize = getFileSize($sPath & $aFiles[$i])
		$iTotalFileSize += $iFileSize
		FileWriteLine($hFile,"				<size>" & $iFileSize &  "</size>")


		FileWriteLine($hFile,"				<required>true</required>")
		FileWriteLine($hFile,"				<remove>false</remove>")
		FileWriteLine($hFile,"				<Overwrite>false</Overwrite>")
		FileWriteLine($hFile,"			</Module>")

		ProgressSet(Floor($i / $aFiles[0] * 100))
	Next

	; Shutdown the crypt library.
	_Crypt_Shutdown()

	FileWriteLine($hFile,"		</Files>")
	FileWriteLine($hFile,"	</ModPack>")
	FileWriteLine($hFile,"</ServerPacks>")

	FileClose($hFile)

	ConsoleWrite("[Info]: Total Pack size - " & Round($iTotalFileSize / 1048576,2) & "MB" & @CRLF)


EndFunc

Func getFilename($sPath)
	Local $i
	$i = StringInStr($sPath,"\", 0, -1)

	Return StringRight($sPath, (StringLen($sPath) - $i))
EndFunc


Func getPath($sPath)
	Local $i
	Local $sLen

	$i = StringInStr($sPath,"\", 0, -1)

	Return StringLeft($sPath, $i - 1)
EndFunc


;writePack()

GUISetState(@SW_SHOW,$frmModpackDetails)

While True
	Sleep(2000)
WEnd

