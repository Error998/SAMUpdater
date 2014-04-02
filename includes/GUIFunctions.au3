Func AppendStatus($controlID, $sText)
	Local $i
	; Store last item index
	$i = _GUICtrlListBox_GetCount($controlID) - 1

	_GUICtrlListBox_ReplaceString($controlID, $i, _GUICtrlListBox_GetText($controlID, $i) & $sText)
EndFunc


Func SetStatus($controlID, $sText)
	Local $i

	; Adds text to the status listbox, if its full clear the listbox and add item aggain
	$i = _GUICtrlListBox_InsertString($controlID, $sText)
	If $i = -1 Then
		_GUICtrlListBox_ResetContent($controlID)
		_GUICtrlListBox_InsertString($controlID, $sText)
	EndIf
	_GUICtrlListBox_SetCurSel($controlID, $i)
EndFunc