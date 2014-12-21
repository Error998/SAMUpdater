#include <Crypt.au3>
#include <File.au3>

Opt('MustDeclareVars', 1)

Local $sPath = FileOpenDialog("Select file", "C:\wamp\www\samupdater", "All Files (*.*)", 1 + 2)

Local $bHash = _Crypt_HashFile($sPath, $CALG_MD5)
ConsoleWrite(@CRLF & $bHash & @CRLF & @CRLF)
