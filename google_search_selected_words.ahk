; google_search_selected_words.ahk
;
; Select some text in any app and press the Copilot key (Left Shift + Win + F23)
; to search Google for it in your default browser.
;
; - Copies the selection, turns it into one line (max 200 characters) and puts
;   your clipboard back the way it was.
; - Opens the search, then brings the browser window to the front. If the browser
;   can't be found or focused, a tooltip near the mouse says so.
; - Set SearchPrefix below to "define " to get Google's dictionary box instead.
; - The first time it runs, it adds a shortcut to the Startup folder so it starts
;   automatically at sign-in. Delete that shortcut (Win+R, shell:startup) to stop it.
;
; How to run: install AutoHotkey v2, then double-click this file.

#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce    ; use the forceful method to bring windows to the front

SetWinDelay(-1)      ; remove AutoHotkey's built-in 100 ms pause after window commands
KeyHistory(0)
ListLines(0)

; Put "define " here if you want Google's dictionary box, or leave "" for a plain search
SearchPrefix := ""

; Run automatically at sign-in: create a shortcut in the Startup folder (once)
SplitPath(A_ScriptName, , , , &scriptBaseName)
startupLink := A_Startup "\" scriptBaseName ".lnk"
if !FileExist(startupLink)
    FileCreateShortcut(A_ScriptFullPath, startupLink, A_ScriptDir)

<+#F23:: {
    query := GetSelectedText()
    if (query = "")
        return

    exe := GetDefaultBrowserExe()

    ; Only when the browser is closed: wait for Shift/Win to be released,
    ; otherwise it can cold-start into troubleshoot mode.
    if (exe = "") || !ProcessExist(exe) {
        KeyWait("LShift")
        KeyWait("LWin")
        KeyWait("RWin")
    }

    try Run("https://www.google.com/search?q=" UriEncode(SearchPrefix query))
    catch
        return

    if (exe = "") {
        Notify("Search opened, but the default browser could not be detected")
        return
    }

    if !FocusBrowser(exe)
        Notify("Search opened, but " exe " could not be focused")
}

; Brings the browser window to the front and keeps trying until it has
; held keyboard focus for 0.4 seconds. Returns true on success.
FocusBrowser(exe) {
    deadline := A_TickCount + 10000
    activeSince := 0

    while (A_TickCount < deadline) {
        hwnd := FindBrowserWindow(exe)
        if hwnd {
            if WinActive(hwnd) {
                if !activeSince
                    activeSince := A_TickCount
                else if (A_TickCount - activeSince >= 400)
                    return true
            } else {
                activeSince := 0
                try WinActivate(hwnd)
            }
        }
        Sleep(20)
    }
    return false
}

; Returns the browser's main window (topmost in stacking order), skipping
; helper windows such as picture-in-picture players. Returns 0 if none.
FindBrowserWindow(exe) {
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

; Copies the current selection and returns it as a clean one-line string.
; The clipboard is restored afterwards. Returns "" if nothing is selected.
GetSelectedText() {
    saved := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    text := ClipWait(0.5) ? A_Clipboard : ""
    A_Clipboard := saved

    text := Trim(RegExReplace(text, "\s+", " "))
    return SubStr(text, 1, 200)
}

; Returns the exe name of the default browser (e.g. "firefox.exe"),
; or "" if it can't be determined.
GetDefaultBrowserExe() {
    progId := RegRead("HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice", "ProgId", "")
    if (progId = "")
        return ""

    cmd := RegRead("HKCR\" progId "\shell\open\command", "", "")
    if (cmd = "")
        return ""

    if RegExMatch(cmd, '^\s*"([^"]+)"', &m) || RegExMatch(cmd, '^\s*(\S+)', &m) {
        SplitPath(m[1], &exeName)
        return exeName
    }
    return ""
}

; Percent-encodes a string as UTF-8.
UriEncode(str) {
    buf := Buffer(StrPut(str, "UTF-8"))
    StrPut(str, buf, "UTF-8")

    encoded := ""
    Loop buf.Size - 1 {
        byte := NumGet(buf, A_Index - 1, "UChar")
        if (byte < 128) && (Chr(byte) ~= "[A-Za-z0-9\-._~]")
            encoded .= Chr(byte)
        else
            encoded .= Format("%{:02X}", byte)
    }
    return encoded
}