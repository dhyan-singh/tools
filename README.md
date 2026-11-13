# tools

A personal collection of the scripts, tools and ways of working I use on my computer. Right now it holds AutoHotkey scripts for Windows. Setup notes, workflows and small projects will be added as they come up.

## Scripts

All scripts sit in the repo root.

| Script | Shortcut | What it does |
|---|---|---|
| [app_shortcuts.ahk](app_shortcuts.ahk) | Right Alt + letter | Jumps to an app: brings its window to the front, or starts it if it isn't open. |
| [google_search_selected_words.ahk](google_search_selected_words.ahk) | Copilot key | Searches Google for the selected text in the default browser. |
| [new_markdown_file.ahk](new_markdown_file.ahk) | Ctrl + Alt + N | Creates an empty `.md` file in the open File Explorer folder (or on the desktop) and starts renaming it. |

### App shortcuts

| Shortcut | Opens |
|---|---|
| Right Alt + O | Obsidian |
| Right Alt + C | Claude |
| Right Alt + G | ChatGPT |
| Right Alt + P | SumatraPDF |
| Right Alt + T | Terminal |
| Right Alt + V | Visual Studio Code |
| Right Alt + M | MarkText |
| Right Alt + E | File Explorer |
| Right Alt + B | Default browser |
| Right Alt + Y | YouTube in the default browser |

## Using the scripts

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Double-click a script to start it.

The first time a script runs, it adds a shortcut to the Windows Startup folder so it starts automatically at sign-in. To stop that, press Win+R, enter `shell:startup` and delete the shortcut.

## Notes on my setup

- The app shortcuts fire whenever Right Alt is held, whatever other modifier keys are down. This is needed because my keyboard layout is English (India), where Right Alt is AltGr, and because PowerToys Keyboard Manager swaps my Left Ctrl and Left Alt keys.
- The app IDs and paths in `app_shortcuts.ahk` are for the apps installed on my PC. On another machine, get the IDs by running `Get-StartApps` in PowerShell.

## Conventions

- Every script starts with a comment that says what it does and how to run it.
- No secrets in the repo. Keys and tokens go in `.env` files, which git ignores.
