; app_shortcuts.ahk
;
; Hold Right Alt and press a letter to jump to an app:
;
;   Right Alt + O   Obsidian
;   Right Alt + C   Claude
;   Right Alt + G   ChatGPT
;   Right Alt + P   SumatraPDF
;   Right Alt + Y   YouTube in the default browser
;
; - If the app already has a window open, that window is brought to the front
;   (and restored if it was minimized). Otherwise the app is started.
; - To add an app, copy one of the hotkey lines below. The exe name is shown in
;   Task Manager's Details tab. The second value is either the app ID from
;   running Get-StartApps in PowerShell, or the full path to the exe.
; - The first time it runs, it adds a shortcut to the Startup folder so it starts
;   automatically at sign-in. Delete that shortcut (Win+R, shell:startup) to stop it.
;
; How to run: install AutoHotkey v2, then double-click this file.

#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce    ; use the forceful method to bring windows to the front

KeyHistory(0)
ListLines(0)

; Run automatically at sign-in: create a shortcut in the Startup folder (once)
SplitPath(A_ScriptName, , , , &scriptBaseName)
startupLink := A_Startup "\" scriptBaseName ".lnk"
if !FileExist(startupLink)
    FileCreateShortcut(A_ScriptFullPath, startupLink, A_ScriptDir)

;           exe name         app ID (from Get-StartApps) or full path to the exe
>!o:: OpenApp("Obsidian.exe", "md.obsidian")
>!c:: OpenApp("claude.exe",   "Claude_pzs8sxrjxfjjc!Claude")
>!g:: OpenApp("ChatGPT.exe",  "OpenAI.Codex_2p2nqsd0c76g0!App")
>!p:: OpenApp("SumatraPDF.exe", EnvGet("LOCALAPPDATA") "\SumatraPDF\SumatraPDF.exe")
>!y:: Run("https://www.youtube.com")

; Brings the app's window to the front, or starts the app if it has no window.
OpenApp(exe, appId) {
    hwnd := FindAppWindow(exe)
    if hwnd {
        if (WinGetMinMax(hwnd) = -1)
            WinRestore(hwnd)
        WinActivate(hwnd)
        return
    }
    try Run(FileExist(appId) ? '"' appId '"' : "shell:AppsFolder\" appId)
    catch
        Notify("Couldn't start " exe)
}

; Returns the app's main window (topmost in stacking order), skipping helper
; windows such as always-on-top popups. Returns 0 if none.
FindAppWindow(exe) {
    for hwnd in WinGetList("ahk_exe " exe) {
        try {
            ; 0x80 = tool window, 0x8 = always-on-top
            if (WinGetTitle(hwnd) != "") && !(WinGetExStyle(hwnd) & 0x88)
                return hwnd
        }
    }
    return 0
}

; Shows a short message near the mouse cursor for 3 seconds.
Notify(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}
