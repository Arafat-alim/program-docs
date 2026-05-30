# MarkItDown — Complete Guide for Windows

## Installed Version: 0.1.6 (Python 3.14.2)

## What Is It

MarkItDown converts files (PDF, Word, Excel, PowerPoint, images, audio, HTML, CSV, YouTube URLs, EPubs, ZIP) into Markdown. Built by Microsoft AutoGen team. Designed for LLM pipelines.

---

## Installation

### Global Install (done — available system-wide)

> **Python 3.14 Note:** `pip install "markitdown[all]"` may downgrade to 0.0.2.
> Use the two-step approach below instead:

```powershell
# Step 1: install magika first (required by newer versions)
pip install "magika~=0.6.1"
# Step 2: force latest markitdown
pip install "markitdown==0.1.6"
# Step 3: install remaining extras
pip install pdfplumber lxml "azure-ai-contentunderstanding>=1.2.0b1"
```

Or simple install on Python ≤3.13:

```powershell
pip install "markitdown[all]"
```

This installs the `markitdown` CLI command globally. Run from any directory.

### Install Specific Formats Only

```powershell
pip install "markitdown[pdf]"          # PDF only
pip install "markitdown[docx]"         # Word only
pip install "markitdown[xlsx]"         # Excel only
pip install "markitdown[pptx]"         # PowerPoint only
pip install "markitdown[pdf,docx,pptx]" # Multiple
```

Available extras: `pdf`, `docx`, `xlsx`, `xls`, `pptx`, `outlook`, `az-doc-intel`, `az-content-understanding`, `audio-transcription`, `youtube-transcription`, `all`

---

## Usage — Command Line

### Basic Convert

```powershell
# Convert to stdout
markitdown document.pdf

# Convert to file
markitdown document.pdf -o document.md

# Pipe input
Get-Content document.pdf | markitdown
```

### Convert Any Supported File

```powershell
markitdown report.docx -o report.md
markitdown slides.pptx -o slides.md
markitdown data.xlsx   -o data.md
markitdown page.html   -o page.md
markitdown data.csv    -o data.md
markitdown image.jpg   -o image.md     # extracts EXIF metadata
```

### YouTube URL

```powershell
markitdown "https://www.youtube.com/watch?v=VIDEO_ID" -o transcript.md
```

### With Azure Document Intelligence (higher quality PDFs)

```powershell
markitdown document.pdf -o output.md -d -e "https://YOUR-ENDPOINT.cognitiveservices.azure.com/"
```

### With Azure Content Understanding (audio, video, structured fields)

```powershell
markitdown video.mp4 --use-cu --cu-endpoint "https://YOUR-ENDPOINT.cognitiveservices.azure.com/"
```

### Plugins

```powershell
markitdown --list-plugins                          # list installed plugins
markitdown --use-plugins document.pdf -o out.md   # enable plugins
```

---

## Usage — Python API

### Basic

```python
from markitdown import MarkItDown

md = MarkItDown()
result = md.convert("document.pdf")
print(result.text_content)
```

### With LLM Vision (image descriptions in PPTX + images)

```python
from markitdown import MarkItDown
from openai import OpenAI

client = OpenAI()  # needs OPENAI_API_KEY env var
md = MarkItDown(llm_client=client, llm_model="gpt-4o")
result = md.convert("presentation.pptx")
print(result.text_content)
```

### With Azure Document Intelligence

```python
from markitdown import MarkItDown

md = MarkItDown(docintel_endpoint="https://YOUR-ENDPOINT.cognitiveservices.azure.com/")
result = md.convert("scanned.pdf")
print(result.text_content)
```

### With Azure Content Understanding

```python
from markitdown import MarkItDown

md = MarkItDown(cu_endpoint="https://YOUR-ENDPOINT.cognitiveservices.azure.com/")
result = md.convert("meeting.mp4")   # video → prebuilt-videoSearch
result = md.convert("call.wav")      # audio → prebuilt-audioSearch
print(result.markdown)
```

### Narrowest API (safest for untrusted inputs)

```python
# Local files only
result = md.convert_local("document.pdf")

# Stream only
with open("document.pdf", "rb") as f:
    result = md.convert_stream(f)

# HTTP response only
import requests
resp = requests.get("https://example.com/doc.pdf")
result = md.convert_response(resp)
```

### With OCR Plugin

```python
from markitdown import MarkItDown
from openai import OpenAI

md = MarkItDown(
    enable_plugins=True,
    llm_client=OpenAI(),
    llm_model="gpt-4o",
)
result = md.convert("scanned_document.pdf")
print(result.text_content)
```

---

## Update

```powershell
# Update to latest version
pip install --upgrade "markitdown[all]"

# Check current version
pip show markitdown

# Check latest available
pip index versions markitdown
```

---

## Uninstall

```powershell
# Remove markitdown only
pip uninstall markitdown

# Remove markitdown + all its dependencies (use carefully)
pip uninstall markitdown mammoth python-pptx openpyxl xlrd pandas pdfminer-six pdfplumber lxml beautifulsoup4 markdownify pydub speechrecognition youtube-transcript-api openai azure-identity azure-ai-documentintelligence azure-ai-contentunderstanding
```

---

## Verify Installation

```powershell
# Confirm CLI is available
markitdown --help

# Confirm version
pip show markitdown

# Test convert (quick smoke test)
markitdown "https://www.google.com"
```

---

## Docker (Alternative)

```powershell
docker build -t markitdown:latest .
docker run --rm -i markitdown:latest < document.pdf > output.md
```

---

## Plugins

Install 3rd-party plugins from PyPI:

```powershell
# OCR plugin (extracts text from images in PDF/DOCX/PPTX/XLSX via LLM vision)
pip install markitdown-ocr
pip install openai
```

Search GitHub tag `#markitdown-plugin` for community plugins.

---

## Supported Input Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| PDF | `.pdf` | Text extraction; use az-doc-intel for scanned |
| Word | `.docx` | Full structure |
| PowerPoint | `.pptx` | Slides + speaker notes |
| Excel | `.xlsx`, `.xls` | All sheets |
| Images | `.jpg`, `.png`, `.gif`, etc. | EXIF + optional LLM description |
| Audio | `.wav`, `.mp3` | EXIF + optional transcription |
| HTML | `.html` | Full page |
| CSV | `.csv` | Table format |
| JSON | `.json` | Formatted |
| XML | `.xml` | Structured |
| ZIP | `.zip` | Iterates all contents |
| EPub | `.epub` | Chapters |
| YouTube | URL | Transcript |

---

## Security Notes

- `convert()` — permissive, handles files, URLs, streams. Use in trusted contexts.
- `convert_local()` — local files only. Use when input might be user-supplied.
- `convert_stream()` — max control, no auto file/URL resolution.
- Never pass untrusted user input directly to `convert()` in server apps.
- Restrict file paths, URI schemes, and network destinations for hosted use.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `markitdown` not found in PATH | Run `pip show markitdown` to find scripts dir, add to PATH |
| PDF extracts empty text | PDF is image-based — use `az-doc-intel` or `markitdown-ocr` plugin |
| Audio transcription fails | Needs `[audio-transcription]` extra + ffmpeg installed |
| YouTube fails | Needs `[youtube-transcription]` extra |
| Import error for Azure | Run `pip install "markitdown[az-doc-intel]"` |

### Fix PATH on Windows (if `markitdown` command not found)

```powershell
# Find where pip installed the script
pip show markitdown
# Look for "Location:" line, e.g. C:\Users\spark\AppData\Roaming\Python\Python314\site-packages
# Scripts are one level up in \Scripts\

# Add to PATH permanently (PowerShell)
$scriptsPath = "$env:APPDATA\Python\Python314\Scripts"
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$scriptsPath", "User")
# Restart terminal after this
```

---

## Quick Reference Card

```
INSTALL:   pip install "markitdown[all]"
UPDATE:    pip install --upgrade "markitdown[all]"
UNINSTALL: pip uninstall markitdown
VERSION:   pip show markitdown

CONVERT:   markitdown file.pdf -o out.md
STDOUT:    markitdown file.pdf
PIPE:      type file.pdf | markitdown
PLUGINS:   markitdown --use-plugins file.pdf -o out.md
AZURE:     markitdown file.pdf -d -e "https://ENDPOINT"
```
