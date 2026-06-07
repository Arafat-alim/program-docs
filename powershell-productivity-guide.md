# Your New Terminal — A Field Guide

Everything below was installed and wired up on **2026-06-07**. This doc explains
*what* each thing is, *why* it's worth your disk space, *how to actually use it*
day-to-day on your MERN / React Native + Expo / Android workflow, and — because
no tool is sacred — **exactly how to remove it** if it doesn't click with you.

Nothing here costs a cent. Everything is either MIT/Apache/BSD-licensed open
source or a free official Microsoft tool.

---

## TL;DR — what changed

| Area | Before | Now |
|---|---|---|
| Shell | Windows PowerShell 5.1 | **PowerShell 7.6** (faster, cross-platform engine) |
| Profile path | `D:\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` | `D:\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Default Windows Terminal profile | "Windows PowerShell" (5.1) | "PowerShell" (7.6, acrylic + Nerd Font + dark theme) |
| Welcome banner | Static ASCII block art | **3 switchable live banners** (see below) |
| `Import-Module Terminal-Icons` | Was silently failing — module wasn't installed | Installed, working |
| `touch` | Fake alias to `New-Item` (broke on existing files) | Real function, behaves like Unix `touch` |
| `z` directory jumper | Old PS-native module (slow) | **zoxide** (Rust, faster, learns your habits) |
| Git diffs | Default ugly `+/-` colors | **delta** — side-by-side, syntax-highlighted |
| New tools on PATH | — | rg, fd, fzf, bat, eza, zoxide, lazygit, delta, jq, fastfetch, watchman, bottom, dust, gum, glow |

Your old profile is **untouched** at its original path — nothing was deleted.
If you ever want to go back, see [Full Rollback](#full-rollback) at the bottom.

---

## 1. PowerShell 7 — the engine swap

**What it is:** The modern, actively-developed PowerShell. Version 5.1 (what
you had) is the legacy version frozen inside Windows itself — Microsoft only
ships security patches for it. PowerShell 7 is where all new features,
performance work, and community modules (like the fuzzy-finder integration
below) actually land.

**Why it matters to you:** Faster startup, a much smarter tab-completion/
prediction engine, better Unicode handling (which is *why* your new banners
render those clean box-drawing borders instead of garbage `▒▒` characters),
and it's the version every modern CLI tool assumes you're running.

**Real-world payoff:** Tab-complete a long `npx react-native run-android
--variant=...` command from history with one keypress instead of retyping it.

- **Verify it's active:** open a new Windows Terminal tab — it now defaults to
  PowerShell 7. Run `$PSVersionTable.PSVersion` — should print `7.6.x`.
- **Profile location:** `D:\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
  (PowerShell 7 looks in `Documents\PowerShell\`, *not* `Documents\WindowsPowerShell\`
  — that's why the file moved).
- **Issue hit during setup:** none — clean winget install, took ~30 seconds.
- **Uninstall:**
  ```powershell
  winget uninstall --id Microsoft.PowerShell -e
  ```
  Then in Windows Terminal settings, change `defaultProfile` back to the
  Windows PowerShell GUID (`{61c54bbd-c2c6-5271-96e7-009a87ff44bf}`).

---

## 2. The welcome banner system — pick your personality

Your old static ASCII art is gone. In its place: **three live banners**, each
reading real system data, each responsive (they reshape themselves for narrow
terminal panes instead of wrapping ugly).

**How to switch:** open the profile file and change ONE line near the top:

```powershell
$global:BannerStyle = 'hacker'   # <- change to 'minimal' or 'dynamic'
```

Save, open a new tab. That's it — no reinstall, no restart needed.

### `'hacker'` — Matrix/cyberpunk boot sequence
```
┌─[ SYSTEM ONLINE ]
│  OPERATOR :: spark
│  HOSTNAME :: DESKTOP-4B2HOPJ
│  SHELL    :: PowerShell 7.6.2
│  UPTIME   :: 2h 8m
│  CWD      :: D:\programs-docs
│  TIME     :: 2026-06-07  14:37:16
└─[ READY ]───────────▶
```
A neon-green "system readout" — the vibe from every hacker movie terminal
scene. Shows your operator name, machine, shell version, uptime, current
directory and timestamp. On a narrow pane (<70 cols) it automatically drops
the box-drawing frame and shows a compact list instead.

### `'minimal'` — one-line info strip
```
14:37  ·  programs-docs  ·  git:main  ·  node v22.20.0  ·  pwsh 7.6
```
For when you just want to start typing. Shows time, folder, git branch (only
if you're in a repo), Node version and PowerShell version — the last two
auto-hide on narrow panes so the line never wraps.

### `'dynamic'` — time-aware + project-aware + a quote
```
  Afternoon, spark. Keep the momentum.
  → my-app  —  Expo / React Native
  "Code is read far more often than it is written."
```
This one actually **reads your `package.json`** if you're inside a project
folder and tells you what kind of project it is (Expo/React Native, Next.js,
plain React, MERN/Node backend, etc.) — genuinely useful when you jump between
five different repos a day and forget which is which. Greeting changes by time
of day; the quote is randomly picked from a small built-in list each time
(edit the `$quotes` array in `Show-DynamicBanner` to add your own).

**Want to mix all three?** Easy — replace the body of `Show-Banner` with
random selection:
```powershell
function Show-Banner {
    $w = $Host.UI.RawUI.WindowSize.Width
    $style = @('hacker','minimal','dynamic') | Get-Random
    switch ($style) {
        'hacker'  { Show-HackerBanner  -Width $w }
        'dynamic' { Show-DynamicBanner -Width $w }
        default   { Show-MinimalBanner -Width $w }
    }
}
```
Now every new tab is a surprise.

---

## 3. The tools — what, why, how, and the eject button

Every tool below is already installed and on your PATH. If a command "isn't
found" right after this session, just open a **new** terminal tab — winget
updates the PATH but already-open shells don't see it until they restart.

### ripgrep (`rg`) — search code at the speed of thought

**What:** A `grep` replacement written in Rust. Searches file contents across
entire folder trees, respects `.gitignore` automatically (so it skips
`node_modules`), and is *stupidly* fast.

**Why you need it:** You're a MERN/RN dev — you constantly need to find "where
is this string/function/env-var used across this huge repo." `rg` does this in
milliseconds even in projects with thousands of files.

**Real-world example:**
```powershell
rg "useEffect" --type js -g "*.tsx"      # find every useEffect in .tsx files
rg "API_BASE_URL"                         # find every place an env var is referenced
rg -l "TODO"                               # just list filenames containing TODO
```

**Uninstall:** `winget uninstall --id BurntSushi.ripgrep.MSVC -e`

---

### fd — find files without the find syntax headaches

**What:** A friendlier, faster `find`. Plain-English patterns instead of
cryptic flags, and again — auto-skips `node_modules`/`.git`.

**Real-world example:**
```powershell
fd ".test.js"            # find every test file in the project
fd -e png -e jpg         # find every image file
fd component -t d        # find every directory named "component" (-t d = type:dir)
```

**Uninstall:** `winget uninstall --id sharkdp.fd -e`

---

### fzf — fuzzy-find ANYTHING (the single biggest productivity unlock here)

**What:** An interactive fuzzy finder. Type a few scattered letters of what
you're looking for, see live-filtered results, hit Enter.

**Why it's a big deal:** It's wired into your shell with two keyboard shortcuts:
- **`Ctrl+T`** — fuzzy-find a file/folder and insert its path into your current
  command. Type `code <Ctrl+T>`, type `pkg`, see `package.json` highlighted,
  hit Enter — `code package.json` is now on your command line.
- **`Ctrl+R`** — fuzzy-search your *command history*. Ran a long
  `adb shell pm clear com.yourapp` command three days ago and forgot it? Hit
  `Ctrl+R`, type `pm clear`, there it is.

**Real-world example:** Inside a big monorepo, `cd <Ctrl+T>` lets you fuzzy-jump
into any subfolder without typing the full path.

**Uninstall:** `winget uninstall --id junegunn.fzf -e` then remove the
`Import-Module PSFzf` block from your profile.

---

### bat — `cat`, but it understands code

**What:** A `cat` replacement that adds syntax highlighting, line numbers, and
git-modification markers in the gutter.

**Real-world example:** You've got it as `preview`:
```powershell
preview src\App.tsx        # syntax-highlighted, line-numbered file view
bat package.json           # also works directly — full name still on PATH
```
Way more pleasant than squinting at raw text in the console, especially for
JSON config files (`tsconfig.json`, `app.json`, `eas.json`).

**Uninstall:** `winget uninstall --id sharkdp.bat -e`

---

### eza — `ls`, but actually useful

**What:** A modern replacement for directory listing that shows file icons
(via your Nerd Font), git status per file, and renders trees.

**Real-world example:** Wired up as two functions so they never collide with
PowerShell's built-in `ls`:
```powershell
ll                 # detailed list: permissions, size, git status, icons
lt                 # tree view of the current folder (2 levels deep, ignores .gitignore'd files)
```
`lt` especially is great for getting your bearings in an unfamiliar repo —
instant visual structure without opening VS Code's file explorer.

**Uninstall:** `winget uninstall --id eza-community.eza -e` then remove the
`ll`/`lt` functions from your profile.

---

### zoxide — `cd` that learns where you actually go

**What:** Replaces the old `z` PowerShell module you had. It silently tracks
which directories you `cd` into most often, and lets you jump to any of them
by typing just a fragment of the name — from *anywhere*.

**Real-world example:**
```powershell
cd D:\projects\my-react-native-app\android\app\src\main     # the long way, once
# ...later, from anywhere on your machine:
z main           # jumps straight back to that exact deep folder
z app android    # multiple fragments narrow it down further
```
The more you use it, the smarter it gets. This genuinely eliminates 90% of
`cd ..\..\..\..\` chains.

**Uninstall:** `winget uninstall --id ajeetdsouza.zoxide -e` then remove the
`zoxide init` block from your profile (you can re-enable the old `z` module by
adding back `Import-Module z` if you really want it).

---

### lazygit — a full git UI without leaving the terminal

**What:** A terminal-based visual interface for git — stage hunks, view diffs,
branch, rebase, stash, all with arrow keys and single-letter shortcuts. No
mouse, no separate GUI app, no leaving your keyboard-flow.

**Real-world example:**
```powershell
lg          # opens lazygit in the current repo
```
Then: `space` to stage a file, `c` to commit, `P` to push, `b` to branch. For
messy MERN repos with a lot of moving files, it's dramatically faster than
`git add -p` from raw command line.

**Uninstall:** `winget uninstall --id JesseDuffield.lazygit -e` then remove
the `lg` function.

---

### delta — git diffs that don't hurt your eyes

**What:** A syntax-highlighting pager for git. Already wired into your global
git config — you don't need to do anything differently. Every `git diff`,
`git show`, and `git log -p` now renders with side-by-side colors and proper
code syntax highlighting instead of plain red/green `+`/`-` lines.

**Real-world example:** Just use git like you always have:
```powershell
git diff
git log -p -2
git show HEAD
```
...and notice it suddenly looks like a proper code review tool.

**Uninstall:**
```powershell
winget uninstall --id dandavison.delta -e
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
```

---

### jq — slice and dice JSON like a pro

**What:** A command-line JSON processor. Pipe any JSON into it, query/filter/
reshape it with a tiny query language.

**Why a MERN dev needs this:** APIs return JSON. Logs are often JSON. Config
files (`package.json`, `eas.json`, `app.json`) are JSON. Being able to slice
them from the command line — without writing a throwaway script — is a daily
win.

**Real-world example:**
```powershell
curl https://api.yourbackend.com/users | jq '.[] | {name, email}'   # pretty-print + extract fields
cat package.json | jq '.dependencies | keys'                         # list all dependency names
eas build:list --json | jq '.[0].status'                             # peek at your latest EAS build status
```

**Uninstall:** `winget uninstall --id jqlang.jq -e`

---

### fastfetch — a system info card on demand

**What:** Prints a clean summary of your system (OS, CPU, RAM, uptime,
resolution, shell, terminal) alongside an ASCII logo. The modern, much faster
replacement for the old `neofetch`.

**Why it's here:** It's *the* tool that gives Linux terminals that "hacker
desk setup screenshot" look — and it's genuinely handy for quickly checking
"how much RAM do I have free before I start an Android emulator + Metro
bundler + backend server simultaneously."

**Real-world example:**
```powershell
sysinfo        # wired up as a shortcut — runs fastfetch
```

**Uninstall:** `winget uninstall --id Fastfetch-cli.Fastfetch -e` then remove
the `sysinfo` function.

---

### watchman — the file-watcher React Native actually wants

**What:** Facebook's own file-watching service. It's the **officially
recommended** companion tool for React Native / Metro bundler — Metro uses it
(when present) to detect file changes far more efficiently than its fallback
polling method.

**Why you specifically need this:** You write React Native + Expo. Without
Watchman, Metro falls back to slower file-watching, which on Windows
especially can mean laggy hot-reloads or "changes not detected" weirdness in
large projects. This was a genuine **gap** in your old setup.

**Real-world example:** You don't run it directly — it just needs to be on
PATH. Start your Metro bundler as usual (`npx expo start` / `npm start`) and
it'll automatically pick up Watchman and use it. You can verify it's being
used with:
```powershell
watchman version
```

**Uninstall:** `winget uninstall --id facebook.watchman -e`

---

### bottom (`btm`) — a gorgeous live system monitor

**What:** A terminal-based, graphical system monitor (CPU/RAM/network/disk
graphs that update live) — like Task Manager, but in your terminal, faster,
and much better looking.

**Real-world example:**
```powershell
btm        # launch it, press q to quit
```
Genuinely useful for spotting "why is my laptop fans screaming" — is it the
Android emulator, the Metro bundler, VS Code, or fifty Chrome tabs?

**Uninstall:** `winget uninstall --id Clement.bottom -e`

---

### dust — see what's eating your disk space, visually

**What:** A `du` (disk usage) replacement that draws a visual bar-graph of
which folders are hogging space, sorted biggest-first.

**Why a MERN/RN dev needs this:** `node_modules` folders, Android build
caches, Gradle caches, and Expo/EAS local build artifacts eat disk space like
nothing else. `dust` finds the culprits in seconds.

**Real-world example:**
```powershell
dust -d 2          # show top space-hogging folders, 2 levels deep, from current dir
dust ~\AppData     # find what's bloating your AppData folder
```

**Uninstall:** `winget uninstall --id bootandy.dust -e`

---

### gum & glow — pretty terminal output for your own scripts

**What:**
- **glow** renders Markdown files beautifully right in the terminal (headers,
  code blocks, tables, the works) — no browser needed.
- **gum** is a toolkit for building nice-looking interactive prompts
  (selection menus, spinners, confirmations, styled text) inside *your own*
  PowerShell scripts — like the `mpt-*` launcher scripts you already have.

**Real-world example:**
```powershell
glow README.md                       # read any project's README without leaving the terminal
glow https://raw.githubusercontent.com/facebook/react-native/main/README.md
```
For `gum`, here's a taste of what you could drop into a script like
`mpt-start.ps1` to make it feel like a polished CLI tool instead of a raw
script:
```powershell
$choice = gum choose "Start API" "Run Update" "Open Logs"
gum spin --title "Starting MoneyPrinterTurbo..." -- Start-Sleep 3
gum confirm "Deploy to production?" && git push
```

**Uninstall:**
`winget uninstall --id charmbracelet.gum -e`
`winget uninstall --id charmbracelet.glow -e`

---

### Terminal-Icons (PowerShell module) — the bug fix

**What it is:** A PowerShell module that adds file-type icons (via your Nerd
Font) to `ls`/`Get-ChildItem` output.

**The bug:** Your old profile had `Import-Module Terminal-Icons` — but the
module was **never actually installed**. Every single shell startup was
silently throwing an error you'd never see (it gets swallowed before the
banner prints). It's now properly installed for your user account, so that
line finally does what it was always supposed to do.

**Real-world example:** Just run `ls` or `dir` normally — folders and files
now show type-appropriate icons automatically.

**Uninstall:** `Uninstall-Module Terminal-Icons -Force` then remove the
`Import-Module Terminal-Icons` line.

---

### PSFzf (PowerShell module) — wires fzf into your command line

**What it is:** The PowerShell-side glue that connects the `fzf` binary to
PSReadLine, giving you the `Ctrl+T` / `Ctrl+R` shortcuts described above.

**Uninstall:** `Uninstall-Module PSFzf -Force` then remove the `Import-Module
PSFzf` block.

---

## 4. Things I deliberately did NOT touch (and why)

- **`ls`/`dir`/`gci`** — I didn't override these with `eza`, even though
  that's a popular move in Linux dotfiles. Reason: your own scripts (the
  `mpt-*` launchers, future automation) may rely on `ls`/`Get-ChildItem`
  returning real `FileInfo` *objects* you can pipe and filter. Aliasing it to
  `eza` (which prints text) would silently break that. You get the visual
  upgrade via `ll`/`lt` instead, with zero risk to scripts.
- **`cat`** — same reasoning; PowerShell's `cat` is a built-in alias for
  `Get-Content`, which scripts may depend on for raw text. `bat`/`preview`
  give you the pretty version on demand without the collision risk.
- **`posh-git`** — I installed it during setup, then removed it. Starship
  (which you already had) shows git branch/status in your prompt, making
  posh-git pure dead weight. One less thing to load on every shell start.
- **Oh My Posh** — you're already on Starship, which does the same job
  (cross-shell prompt theming). Running both would be redundant and slow
  startup down for no benefit.

---

## 5. Switching banner styles — the 10-second guide

1. Open `D:\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` in VS Code:
   ```powershell
   code $PROFILE
   ```
2. Find this line near the top (it's impossible to miss — it's in a big comment block):
   ```powershell
   $global:BannerStyle = 'hacker'
   ```
3. Change `'hacker'` to `'minimal'` or `'dynamic'`.
4. Save. Open a new Windows Terminal tab. Done — no restart, no reinstall.

---

## Full Rollback

If you ever decide "this isn't for me" — here's the complete undo, top to bottom.

**1. Switch Windows Terminal back to PowerShell 5.1 by default**
Open Windows Terminal → `Ctrl+,` (Settings) → Startup → Default profile →
select **"Windows PowerShell"**.

**2. Stop using the new profile** (keeps it on disk, just stops loading it)
Rename it so PowerShell 7 won't find it:
```powershell
Rename-Item "D:\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "Microsoft.PowerShell_profile.ps1.bak"
```
Your old PS 5.1 profile at `D:\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
was **never modified** — it's exactly as it was, ready to use the moment you're
back on PowerShell 5.1.

**3. Remove PowerShell 7 entirely (optional — only if you're sure)**
```powershell
winget uninstall --id Microsoft.PowerShell -e
```

**4. Remove all the new CLI tools in one batch** (only the ones you don't want — pick and choose)
```powershell
$tools = @(
  "BurntSushi.ripgrep.MSVC","sharkdp.fd","junegunn.fzf","sharkdp.bat",
  "eza-community.eza","ajeetdsouza.zoxide","JesseDuffield.lazygit",
  "dandavison.delta","jqlang.jq","Fastfetch-cli.Fastfetch","facebook.watchman",
  "Clement.bottom","bootandy.dust","charmbracelet.gum","charmbracelet.glow"
)
foreach ($id in $tools) { winget uninstall --id $id -e }
```

**5. Remove the PowerShell modules**
```powershell
Uninstall-Module Terminal-Icons,PSFzf -Force
```

**6. Undo the git delta config**
```powershell
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
git config --global --unset delta.navigate
git config --global --unset merge.conflictstyle
git config --global --unset diff.colorMoved
```

That's a complete, clean reversal — your machine returns to exactly how it was
before this session, with zero leftovers.

---

## Cheat Sheet — print this mentally

| You used to type | Now try |
|---|---|
| `Get-ChildItem` then squint | `ll` (icons + git status) or `lt` (tree view) |
| `Select-String "text" -Path *` | `rg "text"` |
| `Get-ChildItem -Recurse -Filter *.test.js` | `fd ".test.js"` |
| Retyping a long command from memory | `Ctrl+R` then type a fragment |
| `cd ..\..\..\deep\folder\name` | `z name` |
| `git add -p` then `git commit` | `lg` (visual, way faster) |
| `git diff` (red/green eyesore) | `git diff` (now pretty automatically — delta) |
| Manually reading JSON | `... | jq '.fieldName'` |
| `Get-Content config.json` | `bat config.json` / `preview config.json` |
| Wondering what's eating disk space | `dust -d 2` |
| Wondering what's eating CPU/RAM | `btm` |
