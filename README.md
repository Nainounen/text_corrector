# Text Correction Helper (AutoHotkey v2)

A tiny Windows hotkey tool that corrects selected text **in place** using the OpenAI API—UTF-8 safe, works across apps, and adds your preferred sign-off. Press **Ctrl+Alt+K** to copy → correct → paste back.



## ✨ Features

* **One-key correction**: Select text anywhere → **Ctrl+Alt+K** → corrected text is pasted back.
* **UTF-8 safe**: Preserves umlauts/accents (ä, ö, ü, é, …).
* **Swiss German option**: Optional conversion of `ß → ss`.
* **Configurable**: Choose model, system instruction, temperature, etc.
* **Clipboard-friendly**: Restores your clipboard after a short delay.



## ✅ Requirements

* **Windows 10/11**
* **AutoHotkey v2** (with compiler)

  * Download: [https://www.autohotkey.com/download/ahk-v2.exe](https://www.autohotkey.com/download/ahk-v2.exe)
* An **OpenAI API key** set as an environment variable `OPENAI_API_KEY`



## 🚀 Quick Start

1. **Install AutoHotkey v2 (with compiler)**
   Download and run: [https://www.autohotkey.com/download/ahk-v2.exe](https://www.autohotkey.com/download/ahk-v2.exe)

2. **Create a new script file**
   Create a file, e.g. `text_correction_helper.ahk` and **paste the code** from the Script section below.

3. **Adjust configuration** *(optional)*
   At the top of the script you can change:

   * `MODEL` (default: `gpt-4o-mini`)
   * `SYSTEM_INSTRUCTION` (German correction instruction)
   * `USE_SWISS_GERMAN` (set `true` to convert `ß` → `ss`)

4. **Set your API key as an environment variable (Windows)**

   * Open **Start** → search **“Environment Variables”** → **Edit the system environment variables**
   * Click **Environment Variables…**
   * Under **System variables** click **New…**
   * **Variable name:** `OPENAI_API_KEY`
   * **Variable value:** *your actual API key*
   * Click **OK** on all dialogs, then **restart** any apps where you’ll use the hotkey.

5. **Compile the script to an .exe**

   * Right-click the `.ahk` file → **Compile Script** (uses Ahk2Exe), or open **Ahk2Exe** and select your script.

6. **Run the app**

   * Double-click the generated `.exe` (or run the `.ahk` directly).
   * Select any text in any app and press **Ctrl+Alt+K**.



## 🛠️ Configuration Reference

| Key                   | What it does                         | Default                                      |
| --------------------- | ------------------------------------ | -------------------------------------------- |
| `OPENAI_API_ENDPOINT` | OpenAI Chat Completions endpoint     | `https://api.openai.com/v1/chat/completions` |
| `MODEL`               | OpenAI model to use                  | `gpt-4o-mini`                                |
| `SYSTEM_INSTRUCTION`  | System prompt for correction style   | German helper                                |
| `USE_SWISS_GERMAN`    | If `true`, convert `ß` → `ss`        | `true`                                       |
| `API_KEY`             | Read from `EnvGet("OPENAI_API_KEY")` | *(required)*                                 |

> 🔎 Tip: You can fine-tune style by editing `SYSTEM_INSTRUCTION`.



## ⌨️ Usage

1. Highlight text in any application (browser, mail, Word, Slack, …).
2. Press **Ctrl+Alt+K**.
3. The tool copies, corrects via the API, and pastes the result back.
4. Your original clipboard is restored after \~3 seconds.



## 🧰 Troubleshooting

* **“No OpenAI API key found”**
  Ensure you created the system variable **`OPENAI_API_KEY`** and restarted apps (or sign out/in).
* **Nothing happens when pressing the hotkey**
  Make sure the script/exe is running (green “H” icon in the tray for `.ahk`). Some elevated apps may require you to **Run as administrator**.
* **Weird characters (garbled umlauts)**
  This script is UTF-8 safe. If issues persist, ensure the source file is saved as **UTF-8 (with BOM)** and that the target app accepts Unicode paste.
* **HTTP error (401/429/5xx)**

  * 401: Invalid/expired key.
  * 429: Rate limit—try again later.
  * 5xx: Temporary server issue—retry.
* **Corporate proxies/firewalls**
  Network filtering may block API calls. Check with your network administrator or set proxy in system settings.



## 🔒 Privacy & Security

* The selected text is sent to OpenAI for correction.
* No logs are written to disk by default.
* Review your organization’s data-handling policy before use.



## 🙌 Credits

Built with ❤️ using **AutoHotkey v2** and the **OpenAI API**.
