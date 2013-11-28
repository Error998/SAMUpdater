#include <Array.au3>
#include <Crypt.au3>
#include "Folders.au3"
#include "RecFileListToArray.au3"


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
	FileWriteLine($hFile,"			<ServerID>TESTSERVER</ServerID>")
	FileWriteLine($hFile,"			<ServerName>SA Minecraft Test Server</ServerName>")
	FileWriteLine($hFile,"			<ServerVersion>1.6.4 Update 2</ServerVersion>")
	FileWriteLine($hFile,"			<NewsUrl>http://www.saminecraft.co.za/news.php</NewsUrl>")
	FileWriteLine($hFile,"			<IconUrl>http://www.saminecraft.co.za/icon.jpg</IconUrl>")
	FileWriteLine($hFile,"			<Discription>SAM Test Server Pack used for testing the newest mods and migration platform.</Discription>")
	FileWriteLine($hFile,"			<ServerConnection>test.saminecraft.co.za:25567</ServerConnection>")
	FileWriteLine($hFile,"		</Info>")
	FileWriteLine($hFile,"		<Files>")

	; A sorted list of all files and folders in the AutoIt installation
	local $aFiles = _RecFileListToArray($sPath, "*", 1, 1, 1)
	if @error = 1 Then
		ConsoleWrite("[ERROR]: Unable to recuirse folders " & @error & " - " & " Extended: " &  @extended & @CRLF)
		Exit
	EndIf

	; To optimize performance start the crypt library.
	_Crypt_Startup()

	for $i = 1 to $aFiles[0]
		FileWriteLine($hFile,"			<Module>")
		FileWriteLine($hFile,"				<name></name>")
		FileWriteLine($hFile,"				<version></version>")
		FileWriteLine($hFile,"				<filename>" & getFilename($aFiles[$i]) & "</filename>")
		FileWriteLine($hFile,"				<url>http://localhost/SAMUpdater/</url>")
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


writePack()


