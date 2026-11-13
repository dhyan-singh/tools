; app_shortcuts.ahk
;
; Hold Right Alt (AltGr) and press a letter to jump to an app:
;
;   Right Alt + O   Obsidian
;   Right Alt + C   Claude
;   Right Alt + G   ChatGPT
;   Right Alt + P   SumatraPDF
;   Right Alt + T   Terminal
;   Right Alt + V   Visual Studio Code
;   Right Alt + M   MarkText
;   Right Alt + E   File Explorer
;   Right Alt + B   default browser
;   Right Alt + Y   YouTube in the default browser
;
; - If the app already has a window open, that window is brought to the front
;   (and restored if it was minimized). Otherwise the app is started.
; - To add an app, copy one of the hotkey lines below. The first value says how
;   to recognise the app's window: "ahk_exe" plus the exe name shown in Task
;   Manager's Details tab. The second value is what to start: the app ID from
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

; ">!" means Right Alt. The "*" makes the shortcut fire no matter which other
; modifier keys are down. That matters because Right Alt rarely arrives alone:
; on the English (India) layout it is AltGr (Left Ctrl + Right Alt), and the
; PowerToys Ctrl/Alt swap can turn that into Left Alt + Right Alt.
;
;            window to look for           what to start if there is none
*>!o:: OpenApp("ahk_exe Obsidian.exe",        "md.obsidian")
*>!c:: OpenApp("ahk_exe claude.exe",          "Claude_pzs8sxrjxfjjc!Claude")
*>!g:: OpenApp("ahk_exe ChatGPT.exe",         "OpenAI.Codex_2p2nqsd0c76g0!App")
*>!p:: OpenApp("ahk_exe SumatraPDF.exe",      EnvGet("LOCALAPPDATA") "\SumatraPDF\SumatraPDF.exe")
*>!t:: OpenApp("ahk_exe WindowsTerminal.exe", "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App")
*>!v:: OpenApp("ahk_exe Code.exe",            "Microsoft.VisualStudioCode")
*>!m:: OpenApp("ahk_exe MarkText.exe",        "com.github.marktext.marktext")
*>!e:: OpenApp("ahk_class CabinetWClass",     "Microsoft.Windows.Explorer")
*>!b:: OpenBrowser()
*>!y:: OpenUrl("https://www.youtube.com")

; Brings the app's window to the front, or starts the app if it has no window.
OpenApp(window, target) {
    hwnd := FindAppWindow(window)
    if hwnd {
        Focus(hwnd)
        return
    }
    try Run(FileExist(target) ? '"' target '"' : "shell:AppsFolder\" target)
    catch
        Notify("Couldn't start " target)
}

; Brings the default browser's window to the front, or starts the browser.
OpenBrowser() {
    path := GetDefaultBrowserPath()
    if (path = "") {
        Notify("The default browser could not be detected")
        return
    }
    SplitPath(path, &exe)
    OpenApp("ahk_exe " exe, path)
}

; Opens a web page in the default browser and brings the browser to the front.
OpenUrl(url) {
    ; A browser that starts while Alt, Ctrl or Shift is held can open in a
    ; special mode or ignore the page, so wait for the keys to be let go.
    for key in ["RAlt", "LAlt", "LCtrl", "RCtrl", "LShift", "RShift"]
        KeyWait(key, "T2")

    try Run(url)
    catch {
        Notify("Couldn't open " url)
        return
    }

    ; The page opens in the background if the browser was already running,
    ; so keep trying for up to 5 seconds to bring its window to the front.
    path := GetDefaultBrowserPath()
    if (path = "")
        return
    SplitPath(path, &exe)
    Loop 50 {
        Sleep(100)
        hwnd := FindAppWindow("ahk_exe " exe)
        if hwnd {
            if WinActive(hwnd)
                return
            Focus(hwnd)
        }
    }
}

; Brings a window to the front, restoring it first if it is minimized.
Focus(hwnd) {
    try {
        if (WinGetMinMax(hwnd) = -1)
            WinRestore(hwnd)
        WinActivate(hwnd)
    }
}

; Returns the app's main window (topmost in stacking order), skipping helper
; windows such as always-on-top popups. Returns 0 if none.
FindAppWindow(window) {
    for hwnd in WinGetList(window) {
        try {
            ; 0x80 = tool window, 0x8 = always-on-top
            if (WinGetTitle(hwnd) != "") && !(WinGetExStyle(hwnd) & 0x88)
                return hwnd
        }
    }
    return 0
}

; Returns the full path of the default browser's exe, or "" if it can't be
; determined.
GetDefaultBrowserPath() {
    progId := RegRead("HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice", "ProgId", "")
    if (progId = "")
        return ""

    cmd := RegRead("HKCR\" progId "\shell\open\command", "", "")
    if RegExMatch(cmd, '^\s*"([^"]+)"', &m) || RegExMatch(cmd, '^\s*(\S+)', &m)
        return m[1]
    return ""
}

; Shows a short message near the mouse cursor for 3 seconds.
Notify(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}
