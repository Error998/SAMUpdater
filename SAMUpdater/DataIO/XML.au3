#include-once
Opt('MustDeclareVars', 1)


; #FUNCTION# ===================================================================
; Name...........: loadXML($_XMLFilename)
; Description ...: Load local copy of Modpack xml file
; Syntax.........: loadXML($_XMLFilename)
; Parameters ....: Path to xml file
; Return values .: Success - Returns stripped XML doc
;                          - Sets @error to 0
;                  Failure - Returns False and sets @error:
;                  |1 - Could not open xml file
;                  |2 - Could not read xml file
; Author ........: Error_998
; Modified ......:
; Remarks .......:
Func loadXML($_XMLFilename)
	Local $hfile = FileOpen($_XMLFilename, 0)
	Local $xml

	; Check if file opened for reading OK
	If $hfile = -1 Then
		ConsoleWrite("[Error] Unable to open xml document" & @CRLF)
		SetError(1)
		Return False
	EndIf

	$xml = FileRead($hfile)
	If @error = 1 Then
		ConsoleWrite("[Error] Unable to read xml document" & @CRLF)
		SetError(2)
		Return False
	EndIf

	FileClose($hfile)

	;Remove all formatting and return xml document
	Return StringReplace($xml, @TAB, "")
EndFunc


; #FUNCTION# ===================================================================
; Name...........: getElements($_doc, $_tag)
; Description ...: Returns a array of all the specified node data
; Syntax.........: getElements($_doc, $_tag)
; Parameters ....: XML document, tag
; Return values .: Success - Returns an array
;						   - Index 0 = Integer of nodes returned
;                          - Index 1 to Nth = 1 node per index
;						   - Sets @error to 0
;                  Failure - Returns array with idex[0] = 0 and sets @error:
;                  |1 - No tag found
; Author ........: Error_998
; Modified ......:
; Remarks .......: Failure or success will return an array, check index[0] or
;                  |@error
;				   |$_tag should be stripped of "<" and "/>"
Func getElements($_doc, $_tag)
	Local $start = 1
	Local $tagStart = "<" & $_tag & ">"
	Local $tagEnd = "</" & $_tag & ">"
	Local $tagStartLoc
	Local $tagEndLoc
	Local $tagData
	Local $elementNum = 1

	; Simulated run to determine size of array needed
	While True
		$tagStartLoc = StringInStr($_doc, $tagStart, 2, 1, $start)
		$tagEndLoc = StringInStr($_doc, $tagEnd, 2, 1, $start)
		If $tagStartLoc = 0 or $tagEndLoc = 0 Then ExitLoop

		;All data within specified Tag
		$tagData = (StringMid($_doc, $tagStartLoc + StringLen($tagStart), ($tagEndLoc - $tagStartLoc - StringLen($tagStart))))
		;Strip CRLF on first line
		$tagData = StringReplace($tagData, @CRLF, "", 1)

		;Start searching from end of last tag
		$start = $tagEndLoc + StringLen($tagEnd)
		$elementNum = $elementNum + 1
	WEnd

	; Create array big enough to hold the data
	Dim $element[$elementNum]

	; Re-initialize varibles for real run
	$start = 1
	$elementNum = 1

	While True
		$tagStartLoc = StringInStr($_doc, $tagStart, 2, 1, $start)
		$tagEndLoc = StringInStr($_doc, $tagEnd, 2, 1, $start)
		If $tagStartLoc = 0 or $tagEndLoc = 0 Then ExitLoop

		;All data within specified Tag
		$tagData = (StringMid($_doc, $tagStartLoc + StringLen($tagStart), ($tagEndLoc - $tagStartLoc - StringLen($tagStart))))
		;Strip CRLF on first line
		$tagData = StringReplace($tagData, @CRLF, "", 1)

		$element[$elementNum] = $tagData

		;Start searching from end of last tag
		$start = $tagEndLoc + StringLen($tagEnd)
		$elementNum = $elementNum + 1
	WEnd

	;Index[0] stores number of elements returned
	$element[0] = $elementNum - 1

	;If no elements found set @error 1
	If $element[0] = 0 Then SetError(1)

	Return $element

EndFunc


; #FUNCTION# ===================================================================
; Name...........: getElement($_doc, $_tag)
; Description ...: Returns a single node
; Syntax.........: getElement($_doc, $_tag)
; Parameters ....: XML document, tag
; Return values .: Success - Returns a single node
;						   - Sets @error to 0
;                  Failure - Returns "" and sets @error:
;                  |1 - No tag found
; Author ........: Error_998
; Modified ......:
; Remarks .......: $_tag should be stripped of "<" and "/>"
;				   |Should only be called if node has no child nodes, will only
;				   |return first node
Func getElement($_doc, $_tag)
	Dim $element

	$element = getElements($_doc, $_tag)
	;If no elements found set @error 1
	If @error = 1 Then
		SetError(1)

		Return ""
	EndIf

	; Return a single node
	Return $element[1]
EndFunc
