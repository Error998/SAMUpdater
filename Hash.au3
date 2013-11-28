#include <Crypt.au3>

_Crypt_Startup() ; To optimize performance start the crypt library.


If StringStripWS($_Filename, 8) <> "" And FileExists($_Filename) Then ; Check there is a file available to find the hash digest
	Local $bHash = _Crypt_HashFile($_Filename, $CALG_MD5) ; Create a hash of the file.

_Crypt_Shutdown() ; Shutdown the crypt library.