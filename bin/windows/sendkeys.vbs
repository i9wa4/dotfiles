strSendKey = "{NUMLOCK}"

intSleepTime = 234567

strQuery = "Select * FROM Win32_Process WHERE (Caption = 'wscript.exe' OR Caption = 'cscript.exe') AND " _
         & " CommandLine LIKE '%" & WScript.ScriptName & "%'"
Set Locator = CreateObject("WbemScripting.SWbemLocator")
Set Service = Locator.ConnectServer
Set Res = Service.ExecQuery(strQuery)

Dim cnt
cnt = 0
If Res.Count > 1 Then
    strMsg = "送信処理を停止します。"
    If MsgBox(strMsg , vbYesNo + vbQuestion) = vbYes Then
        For Each proc In Res
            cnt = cnt + 1
            If cnt <> Res.Count then
                proc.Terminate
            End If
        Next
    End If
    WScript.Quit 0
Else
    ' strSleepTime = CStr(intSleepTime/1000)
    ' strMsg = strSleepTime & "秒毎に" & strSendKey &"を送信します。"
    ' If MsgBox(strMsg , vbYesNo + vbQuestion) = vbYes Then
        Call StopScript(strSendKey, intSleepTime)
    ' End If
End If

WScript.Quit 0

Sub StopScript(key, sleepTime)
    Set WsShell = CreateObject("Wscript.Shell")
    Do
        WsShell.SendKeys(key)
        WScript.Sleep sleepTime
    Loop
End Sub
