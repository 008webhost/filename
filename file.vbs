Set WshShell = CreateObject("WScript.Shell")
tempPath = WshShell.ExpandEnvironmentStrings("%TEMP%")
WshShell.Run tempPath & "\file.bat", 0, False
