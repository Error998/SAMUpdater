; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <GuiTreeview.au3>

Opt("GUIOnEventMode", 1)
Local $frmModpackDetails
Local $treeModpack, $treeExclude
Local $cmdForgeVersion, $cmdTest, $cmdLoadFiles, $cmdExclude, $cmdInclude, $cmdSelectBaseSourceFolder, $cmdSelectLogo
Local $cmdSelectNews
Local $txtBaseURL, $txtDiscription, $txtForgeVersion, $txtLogo, $txtModID, $txtNews, $txtServerConnection, $txtServerName
Local $txtServerVersion, $txtBaseSourceFolder


#region Form

$frmModpackDetails = GUICreate("Modpack Creator",1401,589,-1,-1,-1,-1)
GUICtrlCreateLabel("Modpack ID*",40,30,68,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtModID = GUICtrlCreateInput("",40,50,150,20,-1,512)
GUICtrlCreateLabel("Forge Version*",260,30,70,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtForgeVersion = GUICtrlCreateInput("",260,50,151,20,-1,512)
$cmdForgeVersion = GUICtrlCreateButton("...",420,50,28,21,-1,-1)
GUICtrlCreateLabel("Modpack Base URL*",41,90,102,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtBaseURL = GUICtrlCreateInput("",41,110,370,20,-1,512)
GUICtrlCreateLabel("Server Name",40,150,67,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerName = GUICtrlCreateInput("",40,170,150,20,-1,512)
GUICtrlCreateLabel("Server Version",260,150,83,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerVersion = GUICtrlCreateInput("",260,170,150,20,-1,512)
GUICtrlCreateLabel("Server Connection",40,210,91,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerConnection = GUICtrlCreateInput("",40,230,372,20,-1,512)
GUICtrlCreateLabel("News Page",40,270,89,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtNews = GUICtrlCreateInput("",40,290,150,20,-1,512)
GUICtrlSetState(-1,144)
GUICtrlCreateLabel("Logo",260,270,55,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtLogo = GUICtrlCreateInput("",260,290,150,20,-1,512)
GUICtrlSetState(-1,144)
GUICtrlCreateLabel("Description",40,330,88,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtDiscription = GUICtrlCreateInput("",42,347,405,213,4,512)
GUICtrlCreateGroup("Modpack Details",10,0,467,582,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$treeModpack = GUICtrlCreateTreeView(510,90,424,419,-1,512)
$cmdLoadFiles = GUICtrlCreateButton("Reload Files",532,530,101,30,-1,-1)
$cmdTest = GUICtrlCreateButton("Test",642,530,100,30,-1,-1)
$cmdExclude = GUICtrlCreateButton("Exclude",752,530,100,30,-1,-1)
GUICtrlCreateLabel("Base Source Folder",511,31,96,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtBaseSourceFolder = GUICtrlCreateInput("",511,51,371,20,-1,512)
$cmdSelectBaseSourceFolder = GUICtrlCreateButton("...",891,51,27,20,-1,-1)
$cmdSelectNews = GUICtrlCreateButton("...",200,290,27,20,-1,-1)
$cmdSelectLogo = GUICtrlCreateButton("...",420,290,27,20,-1,-1)
GUICtrlCreateGroup("Modpack Files",489,0,904,581,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$treeExclude = GUICtrlCreateTreeView(950,90,424,419,-1,512)
$cmdInclude = GUICtrlCreateButton("Include",1110,530,100,30,-1,-1)
GUICtrlCreateLabel("Files Excluded from Modpack",950,60,143,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
#

#region Events

GUISetOnEvent($GUI_EVENT_CLOSE, "eventClose", $frmModpackDetails)
GUICtrlSetOnEvent($cmdForgeVersion, "eventSetForgeVersion")
GUICtrlSetOnEvent($cmdLoadFiles, "eventLoadModpackFiles")
GUICtrlSetOnEvent($cmdTest, "eventTest")
GUICtrlSetOnEvent($cmdExclude, "eventExclude")
GUICtrlSetOnEvent($cmdSelectBaseSourceFolder, "eventSelectBaseSourceFolder")
#

Func eventSelectBaseSourceFolder()
	Local $sPath
	; Select a folder from the MC versions dir
	$sPath = FileSelectFolder("Select base source folder for modpack", "")

	If $sPath <> "" Then
		; Base folder must contain the .minecraft folder
		If FileExists($sPath & "\.minecraft") Then
			GUICtrlSetData($txtBaseSourceFolder, $sPath)
			eventLoadModpackFiles()
		Else
			MsgBox(64, "Invalid folder", "The base source folder must contain the .minecraft folder!")
		EndIf
	EndIf

EndFunc


Func eventExclude()
	Local $htree
	Local $item

	$htree = GUICtrlGetHandle($treeModpack)
	$item = GUICtrlRead($treeModpack) ; Get the controlID of the current selected treeview item
	If $item = 0 Then
		MsgBox(64, "Warning", "Please select an item to exclude")
	Else
		If Not _GUICtrlTreeView_Delete($htree, $item) Then
			MsgBox(16, "Error", "Unable to exclude item")
		EndIf
	EndIf


EndFunc


Func eventTest()
	Local $item
	Local $text
	Local $htree

	$item = GUICtrlRead($treeModpack) ; Get the controlID of the current selected treeview item
	If $item = 0 Then
		MsgBox(64, "TreeView Demo", "No item currently selected")
	Else
		$text = GUICtrlRead($item, 1) ; Get the text of the treeview item
		If $text == "" Then
			MsgBox(16, "Error", "Error while retrieving infos about item")
		Else
			MsgBox(64, "TreeView Demo", "Current item selected is: " & $text)
		EndIf
	EndIf
	$htree = GUICtrlGetHandle($treeModpack)
	$item = _GUICtrlTreeView_GetParentHandle($htree)
	If $item = 0 Then
		MsgBox(64, "TreeView Demo", "No parent found")
	Else
		$text = _GUICtrlTreeView_GetText($htree, $item) ; Get the text of the treeview item
		If $text == "" Then
			MsgBox(16, "Error", "Error while retrieving infos about parent")
		Else
			MsgBox(64, "TreeView Demo", "Current item's parent is: " & $text)
		EndIf
	EndIf
EndFunc

Func eventClose()
	Exit
EndFunc


Func eventSetForgeVersion()
	Local $sFolder
	; Select a folder from the MC versions dir
	$sFolder = FileSelectFolder("Select forge version", @AppDataDir & "\.minecraft\versions\")

	; A folder was selected, trim it to only return top folder of path
	If StringLen($sFolder) > 0 Then
		$sFolder = StringTrimLeft($sFolder, StringInStr($sFolder,"\", 1, -1))
		;$sFolder = StringInStr($sFolder,"\", 1, -1)
	EndIf
	GUICtrlSetData($txtForgeVersion, $sFolder)
EndFunc


Func eventLoadModpackFiles()
	Local $item
	Local $sTemp
	Local $sFilename
	Local $sPath

	$sPath = GUICtrlRead($txtBaseSourceFolder)
	If Not FileExists($sPath) Then
		Return
	EndIf

	Local $aFiles = recurseFolders($sPath)

	; Clear treeview
	_GUICtrlTreeView_DeleteAll(GUICtrlGetHandle($treeModpack))

	; Populate treeview
	For $i = 1 To $aFiles[0]
		$sPath = getPath($aFiles[$i])
		$sFilename = getFilename($aFiles[$i])

		If $sPath = $sTemp Then
			GUICtrlCreateTreeViewItem($sFilename, $item)
		Else
			$sTemp = $sPath
			$item = GUICtrlCreateTreeViewItem($sPath, $treeModpack)
			GUICtrlCreateTreeViewItem($sFilename, $item)
		EndIf
	Next
EndFunc