#include-once
#include "..\DataIO\XML.au3"
#include "..\DataIO\Download.au3"
Opt('MustDeclareVars', 1)



Func loadPackList($packsURL, $dataFolder)
	Dim $xml

	; Download Packs.xml
	ConsoleWrite("[Info]: Downloading mod pack list" & @CRLF)
	downloadFile($packsURL, $dataFolder & "\PackData\Packs.xml")

	$xml = loadXML($dataFolder& "\PackData\Packs.xml")

	ConsoleWrite($xml & @CRLF)
EndFunc