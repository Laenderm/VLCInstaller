#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=4.ico
#AutoIt3Wrapper_Outfile_x64=VLC_Installer(x64)_x.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Updates to the most Recent VLCplayer Version
#AutoIt3Wrapper_Res_Fileversion=1.0.3.0
#AutoIt3Wrapper_Res_ProductVersion=1.0.3.0
#AutoIt3Wrapper_Res_LegalCopyright=Carm0
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <InetConstants.au3>
#include <File.au3>
#include <Inet.au3>
#include <EventLog.au3>
If UBound(ProcessList(@ScriptName)) > 2 Then Exit
Local $sTxt, $ecode, $CVersion, $sFileName, $dih1, $CVersion1, $scheck = 0

If $CmdLine[0] >= 1 Then
	Call("line")
EndIf

getinfo()
If $scheck = 1 Then
	versioncheck()
EndIf
kill()
install()


Func kill()
	If ProcessExists('vlc.exe') Then
		ProcessClose('vlc.exe')
	EndIf

	If FileExists('C:\Program Files\VideoLAN\VLC\uninstall.exe') Then
		ShellExecuteWait('uninstall.exe', ' /S', 'C:\Program Files\VideoLAN\VLC\', "", @SW_HIDE)
		Sleep(2000)
		DirRemove('C:\Program Files\VideoLAN', 1)
		;DirRemove('C:\Users\whatever\AppData\Roaming\vlc', 1)
	EndIf
EndFunc   ;==>kill


Func getinfo()

	$dih = "https://www.videolan.org/vlc/"
	$source = _INetGetSource($dih)
	$sTxt = StringSplit($source, @CRLF)

	$sSearch = "Windows 64bit"
	$sSearch1 = "//"
	For $i = 1 To UBound($sTxt) - 1
		$aArray = StringInStr($sTxt[$i], $sSearch)
		$aaray1 = StringInStr($sTxt[$i], $sSearch1)
		If $aaray1 > 1 And $aArray > 1 Then
			$link = StringSplit($sTxt[$i], '//', 1)
			;_ArrayDisplay($link)
			$link1 = StringSplit($sTxt[$i], '"', 1)
			;_ArrayDisplay($link1)
			$link2 = StringSplit($link1[4], '//', 1)
			;_ArrayDisplay($link2)
			$link3 = StringSplit($link2[2], 'get.videolan.org', 1)
			;_ArrayDisplay($link3)
			If @error Then
				$ecode = '404'
				EventLog()
				Exit
			EndIf
			$dih1 = 'https://ftp.osuosl.org/pub/videolan' & $link3[2]
			$sFileName = StringSplit($link3[2], '/')
			;https://ftp.osuosl.org/pub/videolan/vlc/3.0.1/win64/vlc-3.0.1-win64.exe <--  example DL link
			$CVersion1 = $sFileName[3]
			$sFileName = $sFileName[5]
			If StringInStr($sFileName, '.exe') = 0 Then
				MsgBox(16, "", 'No "exe" found. The webpage and/or download link might have changed.', 20)
				$ecode = '404'
				EventLog()
				Exit
			EndIf
		EndIf
	Next

EndFunc   ;==>getinfo

Func install()

	;$dih1 = $sFileName
	$xjs1 = 'C:\windows\temp\' & $sFileName
	;FileWrite('testt.txt', $xjs1 & '_' & $dih1)
	;MsgBox(0, "download link", $dih1)
	$hDownload = InetGet($dih1, $xjs1, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	Do
		Sleep(250)
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
	Sleep(250)

	ShellExecuteWait($sFileName, ' /L=1033 /S –no-qt-privacy-ask', 'C:\windows\temp\', "", @SW_HIDE)
	$CVersion = FileGetVersion('C:\Program Files\VideoLAN\VLC\vlc.exe', $FV_FILEVERSION)
	$ecode = '411'
	EventLog()
	FileDelete($xjs1)
	FileDelete('C:\Users\Public\Desktop\VLC media player.lnk')
	Exit
EndFunc   ;==>install


Func EventLog()

	If $ecode = '404' Then
		Local $hEventLog, $aData[4] = [0, 4, 0, 4]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 1, 0, 404, @UserName, @UserName & ' No "exe" found for VLC player. The webpage and/or download link might have changed. ' & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '411' Then
		Local $hEventLog, $aData[4] = [0, 4, 1, 1]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 0, 0, 411, @UserName, @UserName & " VLC player " & "version " & $CVersion & " successfully installed." & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '444' Then
		Local $hEventLog, $aData[4] = [0, 4, 4, 4]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 0, 0, 444, @UserName, @UserName & " The current version of VLC is already installed " & $CVersion & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf
EndFunc   ;==>EventLog

Func versioncheck()

	$CVersion = FileGetVersion('C:\Program Files\VideoLAN\VLC\vlc.exe', $FV_FILEVERSION)

	If $CVersion1 = $CVersion Then
		$ecode = '444'
		EventLog()
		MsgBox(0, "GrassHopper Says:", "You have the most current version of VLC player", 5)
		Exit
	EndIf
EndFunc   ;==>versioncheck


Func line()

	For $z = 1 To UBound($CmdLine) - 1

		If StringInStr($CmdLine[$z], "-") <> 1 Then
			MsgBox(0, "Grasshopper Says:", 'Wrong switch please use a "-"')
			Exit
		EndIf
		; the -i command cannot be used alone but with one of the following a,n,s o install the selected players
		If StringInStr($CmdLine[$z], "c") = 2 Then
			$scheck = 1
		EndIf

		If StringInStr($CmdLine[$z], "c") <> 2 Then
			MsgBox(0, "Invalad parameter", "Valid parameters are currently:" & @CRLF & " -c (check and only reinstall if out of date)", 5)
			Exit
		EndIf
	Next
EndFunc   ;==>line
