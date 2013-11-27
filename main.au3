#include <INet.au3>
#include <String.au3>
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


Func getModPackInfo()
    Dim $Modpack[64]
    Local $xyz
	Local $info[8]
	Local $modules[4096]
	Local $files
	Dim $moduleInfo[12]

	ConsoleWrite("[Info]: Loading ServerPack.xml")
	; Get ModPack tag
	$sXML = loadXML(@WorkingDir & "\PackData\ServerPacks.xml")
	$Modpack = getElements($sXML, "ModPack")
	ConsoleWrite(" ...done" & @CRLF)
	ConsoleWrite("[Info]: Found " & $Modpack[0] & " mod packs" & @CRLF)

	; Get info of Modpack[i]
	For $i = 1 to 2
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



	Next

EndFunc

getPackXML($sPackURL)
getModPackInfo()
