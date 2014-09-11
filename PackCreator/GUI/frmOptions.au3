; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>

Opt("GUIOnEventMode", 1)
Local $frmOptions
Local $lblExportPath
Local $txtExportPath
Local $cmdSelectExportPath, $cmdCancel, $cmdOK
Local $chkExport, $chkClearExportFolder

#region Form
$frmOptions = GUICreate("Options",476,220,-1,-1,-1,-1,$frmModpackDetails)
$lblExportPath = GUICtrlCreateLabel("Export Path",40,100,85,15,-1,-1)
GUICtrlSetState(-1,144)
GUICtrlSetBkColor(-1,"-2")
$txtExportPath = GUICtrlCreateInput("",40,120,371,20,-1,512)
GUICtrlSetState(-1,144)
$cmdSelectExportPath = GUICtrlCreateButton("...",420,120,27,20,-1,-1)
GUICtrlSetState(-1,144)
$chkExport = GUICtrlCreateCheckbox("Export Modpack Files",30,40,150,20,-1,-1)
$chkClearExportFolder = GUICtrlCreateCheckbox("Clear Export Folder before starting export",40,70,212,20,-1,-1)
GUICtrlSetState(-1,145)
GUICtrlCreateGroup("Export Settings",10,10,457,152,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$cmdOK = GUICtrlCreateButton("OK",130,180,100,30,-1,-1)
$cmdCancel = GUICtrlCreateButton("Cancel",250,180,100,30,-1,-1)

#endregion Form

#region Events
GUISetOnEvent($GUI_EVENT_CLOSE, "eventOptionsClose", $frmOptions)
GUICtrlSetOnEvent($cmdCancel, "eventOptionsClose")
GUICtrlSetOnEvent($cmdOK, "eventOptionsOK")
GUICtrlSetOnEvent($chkExport, "eventOptionsExportModpack")
GUICtrlSetOnEvent($cmdSelectExportPath, "eventOptionsSelectExportFolder")
#endregion Events


Func eventOptionsSelectExportFolder()
	GUICtrlSetData($txtExportPath, FileSelectFolder("Select Export Folder", "", 1))

EndFunc


Func eventOptionsExportModpack()
	If GUICtrlRead($chkExport) = $GUI_CHECKED Then
		; Enable all Export controls
		GUICtrlSetState($chkClearExportFolder, $GUI_ENABLE)
		GUICtrlSetState($lblExportPath, $GUI_ENABLE)
		GUICtrlSetState($txtExportPath, $GUI_ENABLE)
		GUICtrlSetState($cmdSelectExportPath, $GUI_ENABLE)
	Else
		; Disable all Export controls
		GUICtrlSetState($chkClearExportFolder, $GUI_DISABLE)
		GUICtrlSetState($lblExportPath, $GUI_DISABLE)
		GUICtrlSetState($txtExportPath, $GUI_DISABLE)
		GUICtrlSetState($cmdSelectExportPath, $GUI_DISABLE)
	EndIf

EndFunc


Func eventOptionsOK()
	;Check Export
	If GUICtrlRead($chkExport) = $GUI_CHECKED Then
		; Path must be set
		;ConsoleWrite("Path : " & GUICtrlRead($txtExportPath) & @CRLF)
		If GUICtrlRead($txtExportPath) = "" Then
			MsgBox(48, "Export Folder not set", "Please specify an export folder")
			Return
		EndIf

		; Path does not exist
		If Not FileExists(GUICtrlRead($txtExportPath)) Then
			MsgBox(48, "Export Folder does not exist", "The specified export folder does not exist")
			Return
		EndIf
	EndIf

	;Save Form
	SaveFormOptions()

	;Close Form
	GUISetState(@SW_HIDE, $frmOptions)
EndFunc


Func LoadFormOptions()
	Local $aFormData[4]

	; Load form state
	If  FileExists(@ScriptDir & "\Options.dat") Then
		_FileReadToArray(@ScriptDir & "\Options.dat", $aFormData)

		; Set form state
		GUICtrlSetState($chkExport, $aFormData[1])
		GUICtrlSetState($chkClearExportFolder, $aFormData[2])
		GUICtrlSetData($txtExportPath, $aFormData[3])
		; Enable/Disable Export controls
		eventOptionsExportModpack()
	EndIf

	;Display Form
	GUISetState(@SW_SHOW, $frmOptions)
EndFunc


Func SaveFormOptions()
	Local $aFormData[4]

	; Get form data
	$aFormData[1] = GUICtrlRead($chkExport)
	$aFormData[2] = GUICtrlRead($chkClearExportFolder)
	$aFormData[3] = GUICtrlRead($txtExportPath)

	; Save form
	_FileWriteFromArray(@ScriptDir & "\Options.dat", $aFormData, 1)
EndFunc


Func eventOptionsClose()
	GUISetState(@SW_HIDE, $frmOptions)
EndFunc
