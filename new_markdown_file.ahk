; new_markdown_file.ahk
;
; Press Ctrl+Alt+N in a File Explorer window or on the desktop to create an empty
; Markdown file in that folder and start renaming it.
;
; - The file is called "New file.md". If that name is taken, it becomes
;   "New file (2).md", "New file (3).md" and so on.
; - Type a name and press Enter. Explorer keeps the .md ending for you.
; - In places that aren't real folders (This PC, Home, search results), a tooltip
;   near the mouse says the file can't be created there.
; - Change BaseName or the hotkey line below to suit you.
; - The first time it runs, it adds a shortcut to the Startup folder so it starts
;   automatically at sign-in. Delete that shortcut (Win+R, shell:startup) to stop it.
;
; How to run: install AutoHotkey v2, then double-click this file.

#Requires AutoHotkey v2.0
#SingleInstance Force

KeyHistory(0)
ListLines(0)

; Name given to new files, without the .md ending
BaseName := "New file"

; Run automatically at sign-in: create a shortcut in the Startup folder (once)
SplitPath(A_ScriptName, , , , &scriptBaseName)
startupLink := A_Startup "\" scriptBaseName ".lnk"
if !FileExist(startupLink)
    FileCreateShortcut(A_ScriptFullPath, startupLink, A_ScriptDir)

; The hotkey only works in File Explorer windows and on the desktop
GroupAdd("FileViews", "ahk_class CabinetWClass")   ; File Explorer
GroupAdd("FileViews", "ahk_class Progman")         ; desktop
GroupAdd("FileViews", "ahk_class WorkerW")         ; desktop after Win+D

#HotIf WinActive("ahk_group FileViews")
^!n:: NewMarkdownFile()
#HotIf

NewMarkdownFile() {
    view := GetActiveView()
    folder := ""
    try folder := view.Folder.Self.Path
    if (folder = "") || !DirExist(folder) {
        Notify("Can't create a file in this location")
        return
    }

    path := UniquePath(folder, BaseName, ".md")
    try FileAppend("", path)
    catch as err {
        Notify("Couldn't create the file: " err.Message)
        return
    }

    ; Explorer takes a moment to show the new file, so keep trying for up to
    ; 2 seconds: select it, and once it is selected, start renaming it.
    SplitPath(path, &name)
    Loop 40 {
        try {
            item := view.Folder.ParseName(name)
            view.SelectItem(item, 0x1D)        ; select, deselect others, scroll to it, focus
            if (view.FocusedItem.Path = path) {
                view.SelectItem(item, 0x1F)    ; same, plus start renaming
                return
            }
        }
        Sleep(50)
    }
}

; Returns the folder view of the active Explorer tab or of the desktop,
; or "" if it can't be found.
GetActiveView() {
    shellWindows := ComObject("Shell.Application").Windows

    if WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW") {
        try return shellWindows.Item(ComValue(0x13, 8)).Document   ; 8 = the desktop
        return ""
    }

    hwnd := WinActive("ahk_class CabinetWClass")
    activeTab := 0
    try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd)

    for window in shellWindows {
        try {
            if (window.HWND != hwnd)
                continue
            ; All tabs of one Explorer window share its HWND, so also check
            ; that this is the tab currently showing.
            if activeTab {
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                browser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
                ComCall(3, browser, "ptr*", &tabHwnd := 0)   ; IOleWindow::GetWindow
                if (tabHwnd != activeTab)
                    continue
            }
            return window.Document
        }
    }
    return ""
}

; Returns a path in the folder that isn't taken yet:
; "base.ext", then "base (2).ext", "base (3).ext" and so on.
UniquePath(folder, base, ext) {
    folder := RTrim(folder, "\")
    path := folder "\" base ext
    n := 2
    while FileExist(path)
        path := folder "\" base " (" n++ ")" ext
    return path
}

; Shows a short message near the mouse cursor for 3 seconds.
Notify(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}
