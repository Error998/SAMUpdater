#include <INet.au3>
#include <String.au3>
#include <Crypt.au3>
#include "Folders.au3"
#include "XML.au3"

;#include "ForumAuth.au3"

Opt('MustDeclareVars', 1)


; Init
Local $sPackURL = "http://127.0.0.1/SAMUpdater/packs.xml"

Dim $sXML[4096]


; Todo AutoUpdate
; SAMUpdater update check
; will be added some day...

; Download pack
Func getPackXML($sPackURL)

	createFolder(@WorkingDir & "\PackData")

	ConsoleWrite("[Info]: Downloading ServerPacks.xml ")
	InetGet($sPackURL, @WorkingDir & "\PackData\ServerPacks.xml", 1)
	if (@error <>  0) Then
		ConsoleWrite(@CRLF & "[ERROR]: Failed to download ServerPacks.xml" & @CRLF)
		Exit
	Else
		ConsoleWrite("...done" & @CRLF)
	EndIf

EndFunc

Func getModuleInfo($Modpack)
	Local $modules[4096]
	Local $files
	Dim $moduleInfo[12]

	; Get Files of Modpack[X]
	$files = getElement($Modpack, "Files")

	;Get each module contained within Files
	$modules = getElements($files, "Module")

	;Get the info for each module
	For $x = 1 To $modules[0]
		;Get module info of module[X]
		$moduleInfo[0] = $modules[$x]
		;Name
		$moduleInfo[1] = getElement($moduleInfo[0], "name")
		;version
		$moduleInfo[2] = getElement($moduleInfo[0], "version")
		;filename
		$moduleInfo[3] = getElement($moduleInfo[0], "filename")
		;url
		$moduleInfo[4] = getElement($moduleInfo[0], "url")
		;extract
		$moduleInfo[5] = getElement($moduleInfo[0], "extract")
		;path
		$moduleInfo[6] = getElement($moduleInfo[0], "path")
		;md5
		$moduleInfo[7] = getElement($moduleInfo[0], "md5")
		;size
		$moduleInfo[8] = getElement($moduleInfo[0], "size")
		;required
		$moduleInfo[9] = getElement($moduleInfo[0], "required")
		;remove
		$moduleInfo[10] = getElement($moduleInfo[0], "remove")
		;NoOverwrite
		$moduleInfo[11] = getElement($moduleInfo[0], "NoOverwrite")

		For $i = 1 to 11
			ConsoleWrite($moduleInfo[$i] & @CRLF)
		Next

		ConsoleWrite(@CRLF & @CRLF)
	Next
EndFunc

Func getModPacksInfo()
    Dim $Modpack[64]
    Local $info[8]


	ConsoleWrite("[Info]: Loading ServerPack.xml")
	; Get ModPack tag
	$sXML = loadXML(@WorkingDir & "\PackData\ServerPacks.xml")
	$Modpack = getElements($sXML, "ModPack")
	ConsoleWrite(" ...done" & @CRLF)
	ConsoleWrite("[Info]: Found " & $Modpack[0] & " mod packs" & @CRLF)

	; Get info of Modpack[i]
	For $i = 1 to $Modpack[0]
		;$info[0] stores 1 entire modpack info
		$info[0] = getElement($Modpack[$i], "Info")
		;ServerID
		$info[1] = getElement($info[0], "ServerID")
		;ServerName
		$info[2] = getElement($info[0], "ServerName")
		;ServerVersion
		$info[3] = getElement($info[0], "ServerVersion")
		;NewsURL
		$info[4] = getElement($info[0], "NewsURL")
		;IconURL
		$info[5] = getElement($info[0], "IconURL")
		;Discription
		$info[6] = getElement($info[0], "Discription")
		;ServerConnection
		$info[7] = getElement($info[0], "ServerConnection")

		ConsoleWrite("[Info]" & $i & ": Server ID " & $info[1] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Name " & $info[2] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Version " & $info[3] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": News URL " & $info[4] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Icon URL " & $info[5] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Discription " & $info[6] & @CRLF)
		ConsoleWrite("[Info]" & $i & ": Server Connection " & $info[7] & @CRLF & @CRLF)

		; Create Mod pack cache folder
		createFolder(@WorkingDir & "\PackData\" & $info[1])
	Next

EndFunc


Func getModPack($iModPackNum)
	Dim $Modpack[64]
    Local $info[8]

	ConsoleWrite("[Info]: Getting Modpack " & $iModPackNum & " data")
	; Get ModPack tag
	$sXML = loadXML(@WorkingDir & "\PackData\ServerPacks.xml")
	$Modpack = getElements($sXML, "ModPack")
	ConsoleWrite(" ...done" & @CRLF)

    Return	$Modpack[$iModPackNum]

EndFunc


Func getModPackModules($Modpack, $sModPackID = "")
	Local $modules[4096]
	Local $files
	Dim $moduleInfo[12]

	; To optimize performance start the crypt library.
	_Crypt_Startup()

	;~ ;Get Files of Modpack[X]
	$files = getElement($Modpack, "Files")

	;Get each module contained within Files
	$modules = getElements($files, "Module")

	;Get the info for each module
	For $x = 1 To $modules[0]
		;Get module info of module[X]
		$moduleInfo[0] = $modules[$x]
		;Name
		$moduleInfo[1] = getElement($moduleInfo[0], "name")
		;version
		$moduleInfo[2] = getElement($moduleInfo[0], "version")
		;filename
		$moduleInfo[3] = getElement($moduleInfo[0], "filename")
		;url
		$moduleInfo[4] = getElement($moduleInfo[0], "url")
		;extract
		$moduleInfo[5] = getElement($moduleInfo[0], "extract")
		;path
		$moduleInfo[6] = getElement($moduleInfo[0], "path")
		;md5
		$moduleInfo[7] = getElement($moduleInfo[0], "md5")
		;size
		$moduleInfo[8] = getElement($moduleInfo[0], "size")
		;required
		$moduleInfo[9] = getElement($moduleInfo[0], "required")
		;remove
		$moduleInfo[10] = getElement($moduleInfo[0], "remove")
		;NoOverwrite
		$moduleInfo[11] = getElement($moduleInfo[0], "Overwrite")

;~ 		ConsoleWrite("[Info] Module Name " & $moduleInfo[1] & @CRLF)
;~ 		ConsoleWrite("[Info] Module Version " & $moduleInfo[2] & @CRLF)
;~ 		ConsoleWrite("[Info] Module filename " & $moduleInfo[3] & @CRLF)
;~ 		ConsoleWrite("[Info] Module URL " & $moduleInfo[4] & @CRLF)
;~ 		ConsoleWrite("[Info] Extract Module " & $moduleInfo[5] & @CRLF)
;~ 		ConsoleWrite("[Info] Module Path " & $moduleInfo[6] & @CRLF)
;~ 		ConsoleWrite("[Info] Module MD5 " & $moduleInfo[7] & @CRLF)
;~ 		ConsoleWrite("[Info] Module Size " & $moduleInfo[8] & @CRLF)
;~ 		ConsoleWrite("[Info] Required Module " & $moduleInfo[9] & @CRLF)
;~ 		ConsoleWrite("[Info] Remove Module " & $moduleInfo[10] & @CRLF)
;~ 		ConsoleWrite("[Info] Overwrite Module " & $moduleInfo[11] & @CRLF & @CRLF)

		cacheFiles($moduleInfo[4], $moduleInfo[7], $sModPackID)
	Next

	; Shutdown the crypt library.
	_Crypt_Shutdown()

EndFunc

; Add retry "x" times code
Func cacheFiles($sURL, $bHash, $sModPackID)
	; Check if file already exist in the cache
	If FileExists(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash) Then
		ConsoleWrite("[Info]: File already cached - " & $bHash)
	Else
		; Download uncached file
		ConsoleWrite("[Info]: Downloading file into cache - " & $bHash)
		InetGet($sURL, @WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash, 8)
		if (@error <>  0) Then
			ConsoleWrite(@CRLF & "[ERROR]: Failed to download file" & @CRLF)
			Exit
		EndIf
	EndIf

	; Verify file
	If compareHash(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash, $bHash) Then
		ConsoleWrite("...file integrity passed" & @CRLF)
	Else
		ConsoleWrite("...file integrity FAILED" & @CRLF)
		; Removed corupted file
		If FileDelete(@WorkingDir & "\PackData\" & $sModPackID & "\" & $bHash) Then
			ConsoleWrite("[Info]: Removed corrupt file" & @CRLF)
		Else
			ConsoleWrite("[ERROR]: Failed to remove corrupt file " & $bHash & @CRLF)
			Exit
		EndIf

	EndIf
EndFunc

Func compareHash($sPath, $bCacheHash)
	; Create a md5 hash of the file.
	Local $bHash = _Crypt_HashFile($sPath, $CALG_MD5)

	; Compare hash
	If $bHash = $bCacheHash Then
		Return True
	Else
		Return False
	EndIf

EndFunc

; **** Main ****
getPackXML($sPackURL)

getModPacksInfo()

getModPackModules(getModPack(1), "TESTSERVER")

