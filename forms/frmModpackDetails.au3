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
GUICtrlSetOnEvent($cmdInclude, "eventInclude")
GUICtrlSetOnEvent($cmdSelectBaseSourceFolder, "eventSelectBaseSourceFolder")
#

Func eventSelectBaseSourceFolder()
	Local $sPath
	; Select a folder from the MC versions dir
	$sPath = FileSelectFolder("Select base source folder for modpack", "")

	If $sPath <> "" Then
		; Base folder must contain the .minecraft folder
		If FileExists($sPath & "\.minecraft") Then
			; Clear treeview
			_GUICtrlTreeView_DeleteAll(GUICtrlGetHandle($treeModpack))
			GUICtrlSetData($txtBaseSourceFolder, $sPath)
			eventLoadModpackFiles()
		Else
			MsgBox(64, "Invalid folder", "The base source folder must contain the .minecraft folder!")
		EndIf
	EndIf

EndFunc


Func eventInclude()
	Local $hItem, $hFound
	Local $sSearch
	Local $iChildCount

	; Sanity check - something must be selected
	$hItem = _GUICtrlTreeView_GetSelection($treeExclude)
	If $hItem = 0 Then
		Return
	EndIf

	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeExclude, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent, lets remove all items that match the selection
		$sSearch = _GUICtrlTreeView_GetText($treeExclude, $hItem)
		Do
			; Search of existing parent in treeview
			$hFound = _GUICtrlTreeView_FindItem($treeExclude, $sSearch, True)

			if $hFound <> 0 Then
				ConsoleWrite("Parent Handle: " & $hFound & @CRLF)
				ConsoleWrite("Parent Text: " & _GUICtrlTreeView_GetText($treeExclude, $hFound) & @CRLF)

				IncludeItem($hFound)
			EndIf

		Until $hFound = 0

	Else
		; Child item selected, remove single item
		IncludeItem($hItem)
	EndIf
	_GUICtrlTreeView_Sort($treeModpack)
EndFunc


Func eventExclude()
	Local $hItem, $hFound
	Local $sSearch
	Local $iChildCount

	; Sanity check - something must be selected
	$hItem = _GUICtrlTreeView_GetSelection($treeModpack)
	If $hItem = 0 Then
		Return
	EndIf

	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeModpack, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent, lets remove all items that match the selection
		$sSearch = _GUICtrlTreeView_GetText($treeModpack, $hItem)
		Do
			; Search of existing parent in treeview
			$hFound = _GUICtrlTreeView_FindItem($treeModpack, $sSearch, True)

			if $hFound <> 0 Then
				ConsoleWrite("Parent Handle: " & $hFound & @CRLF)
				ConsoleWrite("Parent Text: " & _GUICtrlTreeView_GetText($treeModpack, $hFound) & @CRLF)

				ExcludeItem($hFound)
			EndIf

		Until $hFound = 0

	Else
		; Child item selected, remove single item
		ExcludeItem($hItem)
	EndIf
	_GUICtrlTreeView_Sort($treeExclude)
EndFunc


Func IncludeItem($hItem)
	Local $itemID, $hChild, $hParent, $hFound
	Local $iChildCount
	Local $sSearch

	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeExclude, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent

		; Get first child
		$hChild = _GUICtrlTreeView_GetFirstChild($treeExclude, $hItem)
		AddToInclude(_GUICtrlTreeView_GetText($treeExclude, $hItem), _GUICtrlTreeView_GetText($treeExclude, $hChild))

		; Get rest of the children
		For $i = 1 To $iChildCount - 1
			$hChild = _GUICtrlTreeView_GetNextChild($treeExclude, $hChild)
			AddToInclude(_GUICtrlTreeView_GetText($treeExclude, $hItem), _GUICtrlTreeView_GetText($treeExclude, $hChild))
		Next

		; Remove item from tree view
		_GUICtrlTreeView_Delete($treeExclude, $hItem)

	Else
		; Selected Item is a child
		AddToInclude(_GUICtrlTreeView_GetText($treeExclude, _GUICtrlTreeView_GetParentHandle($treeExclude, $hItem)), _GUICtrlTreeView_GetText($treeExclude, $hItem))

		; Check if its the last child, if so remove parent too
		$hParent = _GUICtrlTreeView_GetParentHandle($treeExclude, $hItem)
		$iChildCount = _GUICtrlTreeView_GetChildCount($treeExclude, $hParent)
		If $iChildCount = 1 Then
			; Remove parent since it only has 1 child
			_GUICtrlTreeView_Delete($treeExclude, $hParent)
		Else
			; Remove item from tree view
			_GUICtrlTreeView_Delete($treeExclude, $hItem)
		EndIf
	EndIf

EndFunc


Func ExcludeItem($hItem)
	Local $itemID, $hChild, $hParent, $hFound
	Local $iChildCount
	Local $sSearch

	; Get the handle of the selected control
	;$hItem = _GUICtrlTreeView_GetSelection($treeModpack)

	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeModpack, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent

		; Get first child
		$hChild = _GUICtrlTreeView_GetFirstChild($treeModpack, $hItem)
		AddToExclude(_GUICtrlTreeView_GetText($treeModpack, $hItem), _GUICtrlTreeView_GetText($treeModpack, $hChild))

		; Get rest of the children
		For $i = 1 To $iChildCount - 1
			$hChild = _GUICtrlTreeView_GetNextChild($treeModpack, $hChild)
			AddToExclude(_GUICtrlTreeView_GetText($treeModpack, $hItem), _GUICtrlTreeView_GetText($treeModpack, $hChild))
		Next

		; Remove item from tree view
		_GUICtrlTreeView_Delete($treeModpack, $hItem)

	Else
		; Selected Item is a child
		AddToExclude(_GUICtrlTreeView_GetText($treeModpack, _GUICtrlTreeView_GetParentHandle($treeModpack, $hItem)), _GUICtrlTreeView_GetText($treeModpack, $hItem))

		; Check if its the last child, if so remove parent too
		$hParent = _GUICtrlTreeView_GetParentHandle($treeModpack, $hItem)
		$iChildCount = _GUICtrlTreeView_GetChildCount($treeModpack, $hParent)
		If $iChildCount = 1 Then
			; Remove parent since it only has 1 child
			_GUICtrlTreeView_Delete($treeModpack, $hParent)
		Else
			; Remove item from tree view
			_GUICtrlTreeView_Delete($treeModpack, $hItem)
		EndIf
	EndIf
EndFunc


Func eventTest()
	_GUICtrlTreeView_BeginUpdate($treeExclude)
	AddToExclude("Parent", "Child 1")
	AddToExclude("Parent\with more stuff", "Child 2")
	_GUICtrlTreeView_EndUpdate($treeExclude)
EndFunc


Func AddToExclude($sParent, $sChild)
	Local $hParent

	; Search of existing parent in treeview
	$hParent = _GUICtrlTreeView_FindItemEx($treeExclude, $sParent)

	If $hParent = 0 Then
		; Parent not found, create it
		$hParent = _GUICtrlTreeView_Add($treeExclude, 0, $sParent)
	EndIf

	_GUICtrlTreeView_AddChild($treeExclude, $hParent, $sChild)

EndFunc


Func AddToInclude($sParent, $sChild)
	Local $hParent

	; Search of existing parent in treeview
	$hParent = _GUICtrlTreeView_FindItemEx($treeModpack, $sParent)

	If $hParent = 0 Then
		; Parent not found, create it
		$hParent = _GUICtrlTreeView_Add($treeModpack, 0, $sParent)
	EndIf

	_GUICtrlTreeView_AddChild($treeModpack, $hParent, $sChild)

EndFunc


Func eventClose()
	GUIDelete($frmModpackDetails)
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

	; ******************************* Temp DATA ******************************************************
	GUICtrlSetData($txtBaseSourceFolder, "C:\Users\Jock\Desktop\Roaming\1.6.4 Modded Update 3")
	; ************************************************************************************************
	$sPath = GUICtrlRead($txtBaseSourceFolder)
	If Not FileExists($sPath) Then
		Return
	EndIf

	Local $aFiles = recurseFolders($sPath)
	; Clear Exclude treeview
	_GUICtrlTreeView_DeleteAll($treeExclude)

	_GUICtrlTreeView_BeginUpdate($treeModpack)
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
	_GUICtrlTreeView_EndUpdate($treeModpack)
EndFunc