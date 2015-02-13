Func createVersionFile()
	IniWrite(@ScriptDir & "\version.ini","SAMUpdater","Version","0.1.1.1")
	IniWrite(@ScriptDir & "\version.ini","SAMUpdater","URL","http://local.saminecraft.co.za/sam/samupdater/samupdater.exe")
	IniWrite(@ScriptDir & "\version.ini","SAMUpdater","SHA1","0x27C6B7EFA3BD74E5911654A269844A5E4632A138")
	IniWrite(@ScriptDir & "\version.ini","Update_Helper","Version","0.0.0.7")
	IniWrite(@ScriptDir & "\version.ini","Update_Helper","URL","http://local.saminecraft.co.za/sam/samupdater/update_helper.exe")
	IniWrite(@ScriptDir & "\version.ini","Update_Helper","SHA1","0xEA302D8CF92FE7586941A6D8F01924FD87788A40")
EndFunc



createVersionFile()

IniWrite(@ScriptDir & "\version.ini","SAMUpdater","LaunchingAppFullPath",@ScriptFullPath)

