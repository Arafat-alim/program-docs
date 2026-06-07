# MoneyPrinterTurbo — Complete Guide for Windows

## Version Installed: Latest (git main branch, cloned 2026-05-31)
## Install Location: `D:\MoneyPrinterTurbo`

---

## What Is It

MoneyPrinterTurbo auto-generates short HD videos from a topic or keyword. It creates:
- Video script (AI-generated or custom)
- Video clips from Pexels/Pixabay or local files
- Subtitles (edge TTS or whisper)
- Background music
- Final rendered HD video (portrait 9:16 or landscape 16:9)

Supports WebUI (Streamlit) + REST API. Configured here with **Ollama** (local LLM) and **NVIDIA NIM** (cloud fallback).

---

## PC Requirements Check (Verified 2026-05-31)

| Requirement | Minimum | Your PC | Status |
|---|---|---|---|
| OS | Windows 10+ | Windows 11 Pro | PASS |
| CPU | 4 cores | i5-13420H (8 cores / 12 threads) | OPTIMAL |
| RAM | 4 GB | 16 GB | OPTIMAL |
| GPU | Not required | RTX 4050 4GB VRAM | OPTIMAL |
| Disk (D:) | ~5 GB | 72 GB free | PASS |

**Verdict: OPTIMAL tier. All requirements exceeded.**

---

## What Was Installed

| Component | Version | How |
|---|---|---|
| MoneyPrinterTurbo | latest (main) | git clone |
| Python | 3.11.15 | uv (isolated, project-only) |
| All Python deps | per uv.lock | uv sync --frozen |
| ImageMagick Q16 | 7.1.2.21 | winget |
| ffmpeg | pre-existing | Gyan full build |
| Ollama | 0.24.0 | pre-existing |

---

## Quick Start (Global Commands)

Open any PowerShell terminal — these work from anywhere:

```powershell
# Launch WebUI (browser opens automatically at http://localhost:8501)
mpt

# Launch API server only (http://localhost:8080/docs)
mpt-api

# Update to latest code
mpt-update
```

> Commands are registered in your PowerShell profile.
> Reload profile after this session: `. $PROFILE`

---

## Manual Start (if global commands not loaded yet)

```powershell
cd D:\MoneyPrinterTurbo

# WebUI
uv run streamlit run ./webui/Main.py --browser.gatherUsageStats=False

# API server
uv run python main.py
```

---

## URLs

| Service | URL |
|---|---|
| WebUI | http://localhost:8501 |
| API Docs (Swagger) | http://localhost:8080/docs |
| API Docs (ReDoc) | http://localhost:8080/redoc |
| LAN access (WebUI) | http://YOUR-LAN-IP:8501 |

To expose on LAN:
```powershell
$env:MPT_WEBUI_HOST = "0.0.0.0"
mpt
```

---

## Configuration

Config file: `D:\MoneyPrinterTurbo\config.toml`

### LLM Setup

**Default: Ollama (local, free)**

Active model: `gemma4:e4b` (9.6 GB, already downloaded)

Other available Ollama models on this machine:
- `qwen3-coder:30b` — 18 GB, coding-focused
- `glm-ocr:latest` — 2.2 GB, lighter option

To change model:
```toml
ollama_model_name = "qwen3-coder:30b"
```

**Switch to NVIDIA NIM:**

1. Open `D:\MoneyPrinterTurbo\config.toml`
2. Change:
```toml
llm_provider = "openai"
openai_api_key = "nvapi-YOUR-KEY-HERE"
openai_base_url = "https://integrate.api.nvidia.com/v1"
openai_model_name = "meta/llama-3.3-70b-instruct"
```

Available NVIDIA NIM models (OpenAI-compatible):
- `meta/llama-3.3-70b-instruct` — strong, general purpose
- `meta/llama-3.1-8b-instruct` — faster, lighter
- `nvidia/llama-3.1-nemotron-70b-instruct` — instruction-tuned
- `mistralai/mixtral-8x7b-instruct-v0.1`

**Switch back to Ollama:**
```toml
llm_provider = "ollama"
```

### Video Sources

For online video clips, add API keys to config.toml:

```toml
# Pexels: https://www.pexels.com/api/ (free, 200 req/hr)
pexels_api_keys = ["YOUR-PEXELS-KEY"]

# Pixabay: https://pixabay.com/api/docs/ (free)
pixabay_api_keys = ["YOUR-PIXABAY-KEY"]
```

To use local video files instead: upload them via WebUI or set `video_source = "local"`.

### Subtitle Provider

```toml
# Fast mode (default, recommended)
subtitle_provider = "edge"

# High-quality mode (requires 3GB whisper model download)
subtitle_provider = "whisper"
```

If using whisper with your RTX 4050:
```toml
[whisper]
device = "cuda"
compute_type = "int8_float16"
```

---

## How to Use — Step by Step

### Generate a Video (WebUI)

1. Run `mpt` in PowerShell
2. Browser opens at http://localhost:8501
3. Fill in:
   - **Video Subject** — your topic (e.g. "Why exercise is important")
   - **Video Language** — English or Chinese
   - **Video Terms** — keywords for clip search (auto-filled from subject)
   - **Video Aspect** — Portrait 9:16 (social) or Landscape 16:9
4. Configure panels:
   - **LLM** — select Ollama, confirm model = gemma4:e4b
   - **Voice** — pick any Edge TTS voice, preview in-browser
   - **Subtitle** — font, size, color, position
   - **Background Music** — random or upload your own
5. Click **Generate Video**
6. Wait 2–5 minutes
7. Download the final MP4

### Generate via API

```bash
# POST a task
curl -X POST http://localhost:8080/api/v1/videos \
  -H "Content-Type: application/json" \
  -d '{
    "video_subject": "Why exercise is important",
    "video_language": "en",
    "video_aspect": "portrait",
    "llm_provider": "ollama"
  }'

# Response: { "task_id": "abc123..." }

# Check status
curl http://localhost:8080/api/v1/tasks/abc123.../progress
```

Full API explorer: http://localhost:8080/docs

---

## Update

```powershell
mpt-update
```

What it does:
1. `git pull origin main` — fetch latest code
2. `uv sync --frozen` — sync any new dependencies

> Note: After major updates, review `config.example.toml` for new config options not yet in your `config.toml`.

Manual update:
```powershell
cd D:\MoneyPrinterTurbo
git pull origin main
uv sync --frozen
```

---

## Uninstall (Complete Removal)

**Warning: This permanently deletes all videos generated under the project directory.**

```powershell
cd D:\MoneyPrinterTurbo
.\mpt-uninstall.ps1
```

The script:
1. Confirms with `YES` prompt
2. Deletes `D:\MoneyPrinterTurbo` (entire project + venv + generated videos)
3. Removes `mpt` / `mpt-api` / `mpt-update` from PowerShell profile
4. Optionally uninstalls ImageMagick

**Manual uninstall steps:**

```powershell
# 1. Delete project
Remove-Item -Recurse -Force D:\MoneyPrinterTurbo

# 2. Uninstall ImageMagick
winget uninstall ImageMagick.Q16

# 3. Remove profile entries
#    Edit D:\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#    Delete the # MPT-GLOBAL-LAUNCHERS ... # /MPT-GLOBAL-LAUNCHERS block
```

Python 3.11 installed by uv is isolated — removing `D:\MoneyPrinterTurbo\.venv` removes all project dependencies. System Python (3.14.5) is untouched.

---

## Known Issues & Fixes

### Ollama 404 error (fixed 2026-05-31)
**Symptom:** `Error: 404 page not found` on video generation with Ollama provider.
**Cause:** `ollama_base_url` must include `/v1` suffix for OpenAI-compatible endpoint.
**Fix applied:** `ollama_base_url = "http://localhost:11434/v1"` in config.toml.

### Ollama first-request timeout
**Symptom:** First video generation takes 1-2 minutes; may time out in some clients.
**Cause:** 9.6GB gemma4 model loads into RAM/VRAM on first call.
**Fix:** `mpt` launcher now pre-warms the model before opening WebUI.

---

## Troubleshooting

### ffmpeg not found
Already installed at:
```
C:\Users\spark\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_...\ffmpeg-8.1.1-full_build\bin\ffmpeg.exe
```
Config already points to it. If error persists, verify `ffmpeg_path` in config.toml.

### ImageMagick errors
Path: `C:\Users\spark\AppData\Local\Microsoft\WindowsApps\magick.exe`
Test: `magick --version` in terminal.

### Ollama not running
The launcher script auto-starts Ollama. If it fails:
```powershell
ollama serve
# In a separate terminal:
mpt
```

### LAN Access
```powershell
$env:MPT_WEBUI_HOST = "0.0.0.0"
mpt
```
Then access: `http://YOUR-MACHINE-IP:8501`

### Whisper model missing
If using `subtitle_provider = "whisper"`, first download model:
```powershell
cd D:\MoneyPrinterTurbo
uv run python -c "from faster_whisper import WhisperModel; WhisperModel('large-v3', device='cuda')"
```
Downloads ~3 GB from HuggingFace automatically.

### Out of VRAM
If RTX 4050 runs out of memory during whisper:
```toml
[whisper]
device = "cpu"
compute_type = "int8"
```

---

## File Structure

```
D:\MoneyPrinterTurbo\
├── config.toml             ← your settings (don't overwrite)
├── config.example.toml     ← reference for new options
├── mpt-start.ps1           ← WebUI launcher
├── mpt-api.ps1             ← API server launcher
├── mpt-update.ps1          ← updater
├── mpt-uninstall.ps1       ← uninstaller
├── .venv\                  ← Python 3.11 + all deps (managed by uv)
├── storage\
│   ├── cache_videos\       ← downloaded video clips (cached)
│   └── tasks\              ← generated videos go here
├── resource\
│   ├── fonts\              ← subtitle fonts (add your own here)
│   └── songs\              ← background music files
├── models\                 ← whisper model goes here (if used)
└── webui\                  ← Streamlit frontend
```

Generated videos location: `D:\MoneyPrinterTurbo\storage\tasks\`

---

## LLM Quick Reference

| Provider | Free | Speed | Quality | Config |
|---|---|---|---|---|
| Ollama gemma4:e4b | Yes | Medium | Good | Default |
| Ollama qwen3-coder:30b | Yes | Slow | Excellent | Change model name |
| NVIDIA NIM llama-3.3-70b | Paid | Fast | Excellent | Change provider + key |
| NVIDIA NIM llama-3.1-8b | Paid | Very fast | Good | Change provider + key |

---

*Installed: 2026-05-31 | Location: D:\MoneyPrinterTurbo | Docs: D:\programs-docs\moneyprinterturbo-guide.md*
