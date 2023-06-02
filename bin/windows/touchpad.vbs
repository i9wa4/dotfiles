set WshShell = WScript.CreateObject("WScript.Shell")

WshShell.Run "cmd /c start ms-settings:devices-touchpad",0,false

WScript.Sleep(2000)
WshShell.SendKeys " "
WScript.Sleep(200)
WshShell.SendKeys "%{F4}"