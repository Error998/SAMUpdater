; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <GuiTreeview.au3>
#include <GuiListbox.au3>
#include<File.au3>

Opt("GUIOnEventMode", 1)
Local $frmModpackDetails
Local $treeModpack, $treeExclude
Local $cmdForgeVersion, $cmdTest, $cmdLoadFiles, $cmdExclude, $cmdInclude, $cmdSelectBaseSourceFolder, $cmdSelectLogo
Local $cmdSelectNews
Local $txtBaseURL, $txtDiscription, $txtForgeVersion, $txtLogo, $txtModID, $txtNews, $txtServerConnection, $txtServerName
Local $txtServerVersion, $txtBaseSourceFolder, $txtAppendPath
Local $lstStatus
Local $mnuExit, $mnuFile, $mnuOptions

#region Form

$frmModpackDetails = GUICreate("Modpack Creator",1401,831,-1,-1,-1,-1)
GUICtrlCreateLabel("Modpack ID*",40,40,68,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtModID = GUICtrlCreateInput("",40,60,150,20,-1,512)
GUICtrlCreateLabel("Forge Version*",260,40,70,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtForgeVersion = GUICtrlCreateInput("",260,60,151,20,-1,512)
$cmdForgeVersion = GUICtrlCreateButton("...",420,60,28,21,-1,-1)
GUICtrlCreateLabel("Modpack Base URL*",41,100,102,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtBaseURL = GUICtrlCreateInput("",41,120,370,20,-1,512)
GUICtrlCreateLabel("Server Name",40,160,67,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerName = GUICtrlCreateInput("",40,180,150,20,-1,512)
GUICtrlCreateLabel("Server Version",260,160,83,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerVersion = GUICtrlCreateInput("",260,180,150,20,-1,512)
GUICtrlCreateLabel("Server Connection",40,220,91,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtServerConnection = GUICtrlCreateInput("",40,240,372,20,-1,512)
GUICtrlCreateLabel("News Page",40,280,89,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtNews = GUICtrlCreateInput("",40,300,370,20,-1,512)
GUICtrlSetState(-1,16)
GUICtrlCreateLabel("Logo",40,340,55,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtLogo = GUICtrlCreateInput("",40,360,370,20,-1,512)
GUICtrlSetState(-1,16)
GUICtrlCreateLabel("Description",40,400,88,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtDiscription = GUICtrlCreateInput("",40,420,405,100,4,512)
GUICtrlCreateGroup("Modpack Details",10,10,467,582,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$treeModpack = GUICtrlCreateTreeView(509,100,424,419,-1,512)
$cmdLoadFiles = GUICtrlCreateButton("Reload Files",531,540,101,30,-1,-1)
$cmdTest = GUICtrlCreateButton("Test",641,540,100,30,-1,-1)
$cmdExclude = GUICtrlCreateButton("Exclude",751,540,100,30,-1,-1)
GUICtrlCreateLabel("Base Source Folder",510,41,96,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtBaseSourceFolder = GUICtrlCreateInput("",510,61,371,20,-1,512)
$cmdSelectBaseSourceFolder = GUICtrlCreateButton("...",890,61,27,20,-1,-1)
$cmdSelectNews = GUICtrlCreateButton("...",420,300,27,20,-1,-1)
$cmdSelectLogo = GUICtrlCreateButton("...",420,360,27,20,-1,-1)
GUICtrlCreateGroup("Modpack Files",489,10,904,581,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$treeExclude = GUICtrlCreateTreeView(949,100,424,419,-1,512)
$cmdInclude = GUICtrlCreateButton("Include",1109,540,100,30,-1,-1)
GUICtrlCreateLabel("Files Excluded from Modpack",949,70,143,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Additional Folder - %APPDATA%\<Enter Data>\.minecraft\..",40,540,303,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtAppendPath = GUICtrlCreateInput("",40,560,373,20,-1,512)
$lstStatus = GUICtrlCreatelist("",40,630,1330,149,-1,512)
GUICtrlCreateGroup("Status Window",9,605,1381,198,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")


; Menu
$mnuFile = GUICtrlCreateMenu("File")
$mnuOptions = GUICtrlCreateMenuItem("Options", $mnuFile)
$mnuExit = GUICtrlCreateMenuItem("Exit", $mnuFile)
#endregion Form

#region Events
GUISetOnEvent($GUI_EVENT_CLOSE, "eventClose", $frmModpackDetails)
GUICtrlSetOnEvent($cmdForgeVersion, "eventSetForgeVersion")
GUICtrlSetOnEvent($cmdLoadFiles, "eventLoadModpackFiles")
GUICtrlSetOnEvent($cmdTest, "eventTest")
GUICtrlSetOnEvent($cmdExclude, "eventExclude")
GUICtrlSetOnEvent($cmdInclude, "eventInclude")
GUICtrlSetOnEvent($cmdSelectBaseSourceFolder, "eventSelectBaseSourceFolder")
GUICtrlSetOnEvent($cmdSelectLogo, "eventSelectLogo")
GUICtrlSetOnEvent($cmdSelectNews, "eventSelectNews")
GUICtrlSetOnEvent($mnuExit, "eventClose")
GUICtrlSetOnEvent($mnuOptions, "eventOptions")
#endregion Events

Func eventOptions()
	ConsoleWrite("Opening Options" & @CRLF)
	LoadFormOptions()
EndFunc

Func eventSelectLogo()
	Local $sPath

	$sPath = FileOpenDialog("Select Picture", @ScriptDir & "\", "Images (*.jpg;*.bmp)", 3)
	If $sPath = "" Then
		Return
	EndIf

	GUICtrlSetData($txtLogo, $sPath)

EndFunc


Func eventSelectNews()
	Local $sPath

	$sPath = FileOpenDialog("Select News Data file", @ScriptDir & "\", "All Files (*.*)", 3)
	If $sPath = "" Then
		Return
	EndIf

	GUICtrlSetData($txtNews, $sPath)

EndFunc


Func SaveFormData()
	Local $aFormData[12]

	; Modpack Info
	$aFormData[1] = GUICtrlRead($txtModID)
	$aFormData[2] = GUICtrlRead($txtServerName)
	$aFormData[3] = GUICtrlRead($txtServerVersion)
	$aFormData[4] = GUICtrlRead($txtNews)
	$aFormData[5] = GUICtrlRead($txtLogo)
	$aFormData[6] = GUICtrlRead($txtDiscription)
	$aFormData[7] = GUICtrlRead($txtServerConnection)
	$aFormData[8] = GUICtrlRead($txtForgeVersion)
	$aFormData[9] = GUICtrlRead($txtBaseURL)

	; Extra form data
	$aFormData[10] = GUICtrlRead($txtBaseSourceFolder)
	$aFormData[11] = GUICtrlRead($txtAppendPath)

	_FileWriteFromArray(@ScriptDir & "\Modpack.dat", $aFormData, 1)

	; Get Exclude Treeview items
	Local $aFiles = ReturnTreeContent($treeExclude)

	; If nothing to save, remove file
	If $aFiles = 0 And FileExists(@ScriptDir & "\Exclude.dat") Then
		FileDelete(@ScriptDir & "\Exclude.dat")
	Else
		; Save Exclude Treeview
		_FileWriteFromArray(@ScriptDir & "\Exclude.dat", $aFiles, 1)
	EndIf
EndFunc


Func LoadFormModpackDetails()
	Local $aFormData[12]

	If Not FileExists(@ScriptDir & "\Modpack.dat") Then
		Return
	EndIf

	_FileReadToArray(@ScriptDir & "\Modpack.dat", $aFormData)

	; Modpack Info
	GUICtrlSetData($txtModID, $aFormData[1])
	GUICtrlSetData($txtServerName, $aFormData[2])
	GUICtrlSetData($txtServerVersion, $aFormData[3])
	GUICtrlSetData($txtNews, $aFormData[4])
	GUICtrlSetData($txtLogo, $aFormData[5])
	GUICtrlSetData($txtDiscription, $aFormData[6])
	GUICtrlSetData($txtServerConnection, $aFormData[7])
	GUICtrlSetData($txtForgeVersion, $aFormData[8])
	GUICtrlSetData($txtBaseURL, $aFormData[9])

	; Extra form data
	GUICtrlSetData($txtBaseSourceFolder, $aFormData[10])
	GUICtrlSetData($txtAppendPath, $aFormData[11])

	; Load Modpack Treeview
	eventLoadModpackFiles()

	GUISetState(@SW_SHOW,$frmModpackDetails)

	SetStatus("[Info]: Loading previously excluded files...")
	SplashTextOn("Loading previously excluded files...", "Please wait", 300, 45)
	LoadExcludeTreeviewFromFile()
	SplashOff()
	AppendStatus("done")
	GUICtrlSetState($treeModpack, $GUI_FOCUS )
EndFunc


Func AppendStatus($sText)
	Local $i
	; Store last item index
	$i = _GUICtrlListBox_GetCount($lstStatus) - 1

	_GUICtrlListBox_ReplaceString($lstStatus, $i, _GUICtrlListBox_GetText($lstStatus, $i) & $sText)
EndFunc


Func SetStatus($sText)
	Local $i

	; Adds text to the status listbox, if its full clear the listbox and add item aggain
	$i = _GUICtrlListBox_InsertString($lstStatus, $sText)
	If $i = -1 Then
		_GUICtrlListBox_ResetContent($lstStatus)
		_GUICtrlListBox_InsertString($lstStatus, $sText)
	EndIf
	_GUICtrlListBox_SetCurSel($lstStatus, $i)
EndFunc


Func LoadExcludeTreeviewFromFile()
	Local $aFiles
	Local $sParent, $sChild
	Local $iChildCount
	Local $hFound, $hChild
	Local $bFound = False

	; File must exist
	If Not FileExists(@ScriptDir & "\Exclude.dat") Then
		Return
	EndIf

	_FileReadToArray(@ScriptDir & "\Exclude.dat", $aFiles)

	For $i = 1 to $aFiles[0]
		$bFound = False
		$sParent = getPath($aFiles[$i])
		$sChild = getFilename($aFiles[$i])

		; Check if parent still exists in Modpack tree
		$hFound = _GUICtrlTreeView_FindItem($treeModpack, $sParent)
		if $hFound = 0 Then
			SetStatus("[Warning]: Folder no longer exists in modpack, removing file from exclude list - " & $sParent & "\" & $sChild)
			ContinueLoop
		EndIf

		; Parent found, lets check its children
		$iChildCount = _GUICtrlTreeView_GetChildCount($treeModpack, $hFound)

		; Get first child
		$hChild = _GUICtrlTreeView_GetFirstChild($treeModpack, $hFound)
		; Check if hChild = sChild then remove the child from Modpack treeview
		If _GUICtrlTreeView_GetText($treeModpack, $hChild) = $sChild Then
			_GUICtrlTreeView_Delete($treeModpack, $hChild)

			; If it was the last child remove the parent too
			If $iChildCount = 1 Then
				_GUICtrlTreeView_Delete($treeModpack, $hFound)
			EndIf

			; Add to exclude treeview
			AddToExclude($sParent, $sChild)
			$bFound = True
		Else
			; Check the rest of the children
			For $x = 1 To $iChildCount - 1
				$hChild = _GUICtrlTreeView_GetNextChild($treeModpack, $hChild)
				; Check if hChild = sChild then remove the child from Modpack treeview
				If _GUICtrlTreeView_GetText($treeModpack, $hChild) = $sChild Then
					_GUICtrlTreeView_Delete($treeModpack, $hChild)

					; If it was the last child remove the parent too
					If $iChildCount = 1 Then
						_GUICtrlTreeView_Delete($treeModpack, $hFound)
					EndIf

					; Add to exclude treeview
					AddToExclude($sParent, $sChild)
					$bFound = True
				EndIf
			Next
		EndIf

		; Check if file was found at all
		If Not $bFound Then
			SetStatus("[Warning]: File no longer exists in modpack, removing file from exclude list - " & $sParent & "\" & $sChild)
		EndIf

	Next

EndFunc


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

	SetStatus("[Info]: Including files...")
	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeExclude, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent, lets remove all items that match the selection
		$sSearch = _GUICtrlTreeView_GetText($treeExclude, $hItem)
		Do
			; Search of existing parent in treeview
			$hFound = _GUICtrlTreeView_FindItem($treeExclude, $sSearch)

			if $hFound <> 0 Then
				IncludeItem($hFound)
			EndIf

		Until $hFound = 0

	Else
		; Child item selected, remove single item
		IncludeItem($hItem)
	EndIf
	_GUICtrlTreeView_Sort($treeModpack)
	AppendStatus("done")
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

	SetStatus("[Info]: Excluding files...")
	; Check if selected item is a parent
	$iChildCount = _GUICtrlTreeView_GetChildCount($treeModpack, $hItem)
	If $iChildCount >= 1 Then
		; Selected Item is a parent, lets remove all items that match the selection
		$sSearch = _GUICtrlTreeView_GetText($treeModpack, $hItem)
		Do
			; Search of existing parent in treeview
			$hFound = _GUICtrlTreeView_FindItem($treeModpack, $sSearch)

			if $hFound <> 0 Then
				ExcludeItem($hFound)
			EndIf

		Until $hFound = 0

	Else
		; Child item selected, remove single item
		ExcludeItem($hItem)
	EndIf
	_GUICtrlTreeView_Sort($treeExclude)
	AppendStatus("done")
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
	Local $aModPackData[12]

	SetStatus("[Info]: Creating Modpack...")
	GUISetState(@SW_DISABLE, $frmModpackDetails)

	; Modpack Info
	$aModPackData[1] = GUICtrlRead($txtModID)
	$aModPackData[2] = GUICtrlRead($txtServerName)
	$aModPackData[3] = GUICtrlRead($txtServerVersion)
	$aModPackData[4] = GUICtrlRead($txtNews)
	$aModPackData[5] = GUICtrlRead($txtLogo)
	$aModPackData[6] = GUICtrlRead($txtDiscription)
	$aModPackData[7] = GUICtrlRead($txtServerConnection)
	$aModPackData[8] = GUICtrlRead($txtForgeVersion)
	$aModPackData[9] = GUICtrlRead($txtBaseURL)

	; Extra form data
	$aModPackData[10] = GUICtrlRead($txtBaseSourceFolder)
	$aModPackData[11] = GUICtrlRead($txtAppendPath)

	Local $aFiles = ReturnTreeContent($treeModpack)

	WriteModpack($aModPackData, $aFiles)
	GUISetState(@SW_ENABLE, $frmModpackDetails)
	AppendStatus("done")
EndFunc


Func ReturnTreeContent($tree)
	Local $hItem
	Local $sParent, $sPath
	Local $i

	;Get child count of entire tree
	; First item will always be the parent
	$hItem = _GUICtrlTreeView_GetFirstItem($tree)

	; Sanity check does the tree contain anything?
	If $hItem = 0 Then
		Return 0
	EndIf

	$sParent = _GUICtrlTreeView_GetText($tree, $hItem)

	While $hItem <> 0
		; Get next item
		$hItem = _GUICtrlTreeView_GetNext($tree, $hItem)
		If $hItem <> 0 Then
			; Check if the item is a parent
			If _GUICtrlTreeView_GetChildCount($tree, $hItem) > 0 Then
				; New Parent
				$sParent = _GUICtrlTreeView_GetText($tree, $hItem)
				ContinueLoop
			EndIf

			; Child
			$sPath = $sParent & "\" & _GUICtrlTreeView_GetText($tree, $hItem)
			$i = $i + 1
		EndIf
	WEnd

	; Store full path of all files
	Local $aFiles[$i + 1]
	$aFiles[0] = $i

	; First item will always be the parent
	$hItem = _GUICtrlTreeView_GetFirstItem($tree)
	$sParent = _GUICtrlTreeView_GetText($tree, $hItem)

	$i = 1
	While $hItem <> 0
		; Get next item
		$hItem = _GUICtrlTreeView_GetNext($tree, $hItem)
		If $hItem <> 0 Then
			; Check if the item is a parent
			If _GUICtrlTreeView_GetChildCount($tree, $hItem) > 0 Then
				; New Parent
				$sParent = _GUICtrlTreeView_GetText($tree, $hItem)
				ContinueLoop
			EndIf

			; Child
			$sPath = $sParent & "\" & _GUICtrlTreeView_GetText($tree, $hItem)
			$aFiles[$i] = $sPath
			$i = $i + 1
		EndIf
	WEnd

	Return $aFiles
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
	SaveFormData()
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

	$sPath = GUICtrlRead($txtBaseSourceFolder)
	If Not FileExists($sPath) Then
		Return
	EndIf

	SetStatus("[Info]: Loading modpack files...")
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
	AppendStatus("done")
EndFunc