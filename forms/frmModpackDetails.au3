; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>

Opt("GUIOnEventMode", 1)
Local $frmModpackDetails
Local $cmdForgeVersion
Local $txtBaseURL
Local $txtDiscription
Local $txtForgeVersion
Local $txtLogo
Local $txtModID
Local $txtNews
Local $txtServerConnection
Local $txtServerName
Local $txtServerVersion

#region Form

$frmModpackDetails = GUICreate("Modpack Details",574,571,-1,-1,-1,-1)
GUICtrlCreateLabel("Modpack ID",50,30,68,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Server Name",50,90,67,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Server Version",50,150,83,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("News Page",50,210,89,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Logo",50,270,55,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Description",50,330,88,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Server Connection",270,90,91,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Forge Version",270,30,70,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateGroup("Modpack Details",140,490,60,60,-1,-1)
GUICtrlSetBkColor(-1,"0xF0F0F0")
$txtModID = GUICtrlCreateInput("",50,50,150,20,-1,512)
$txtServerName = GUICtrlCreateInput("",50,110,150,20,-1,512)
$txtServerVersion = GUICtrlCreateInput("",50,170,150,20,-1,512)
$txtNews = GUICtrlCreateInput("",50,230,150,20,-1,512)
GUICtrlSetState(-1,144)
$txtLogo = GUICtrlCreateInput("",50,290,150,20,-1,512)
GUICtrlSetState(-1,144)
$txtDiscription = GUICtrlCreateInput("",52,347,448,75,4,512)
$txtForgeVersion = GUICtrlCreateInput("",270,50,154,20,-1,512)
$txtServerConnection = GUICtrlCreateInput("",270,110,150,20,-1,512)
$cmdForgeVersion = GUICtrlCreateButton("...",430,49,28,21,-1,-1)
;GUICtrlSetOnEvent(-1,"SelectForgeVersion")
GUICtrlCreateLabel("Modpack Base URL",270,150,102,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")
$txtBaseURL = GUICtrlCreateInput("",270,170,150,20,-1,512)

#
