; AutoHotkey v2 — Text Correction Helper (UTF-8 safe)
#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================
; Configuration
; =========================
OPENAI_API_ENDPOINT := "https://api.openai.com/v1/chat/completions"
MODEL := "gpt-4o-mini"
SYSTEM_INSTRUCTION := "Du bist ein Textkorrektur-Assistent. Korrigiere Rechtschreibung und Grammatik, formuliere stilistisch schöner."
USE_SWISS_GERMAN := true  ; Set to false if you want to keep ß
API_KEY := EnvGet("OPENAI_API_KEY") ; Set in environment variables

; Hotkey: Ctrl+Alt+K
^!k::CorrectSelectedText()

; =========================
; Main Function
; =========================
CorrectSelectedText() {
    global API_KEY, MODEL, OPENAI_API_ENDPOINT, SYSTEM_INSTRUCTION

    if (!API_KEY) {
        Notify("Error: No OpenAI API key found. Set 'OPENAI_API_KEY' environment variable.", 4000)
        return
    }

    ; Get selected text
    savedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    
    ; timeout
    if !ClipWait(2) {
        Notify("Error: No text selected.", 3000)
        A_Clipboard := savedClip
        return
    }
    
    selectedText := A_Clipboard
    if (Trim(selectedText) = "") {
        Notify("Error: No text selected or clipboard empty.", 3000)
        A_Clipboard := savedClip
        return
    }

    ; Show processing
    Notify("Processing text...", 1000)

    ; Build JSON payload
    payloadObj := Map(
        "model", MODEL,
        "messages", [
            Map("role", "system", "content", SYSTEM_INSTRUCTION),
            Map("role", "user", "content", selectedText)
        ],
        "temperature", 0.3,
        "max_tokens", 2000
    )

    ; Convert to JSON string
    jsonPayload := ObjToJson(payloadObj)

    ; API request
    response := HttpPostUtf8(OPENAI_API_ENDPOINT, jsonPayload, API_KEY)
    if (!response) {
        Notify("Error: No response from API.", 4000)
        A_Clipboard := savedClip
        return
    }

    ; Extract corrected text
    corrected := ExtractCorrectedText(response)
    if (!corrected) {
        Notify("Error: Could not extract corrected text from response.", 4000)
        A_Clipboard := savedClip
        return
    }

    ; Convert ß to ss for Swiss German if enabled
    if (USE_SWISS_GERMAN) {
        corrected := ConvertToSwissGerman(corrected)
    }

    ; Replace text
    A_Clipboard := corrected
    Send("^v")
    Notify("Text corrected successfully!", 2000)

    ; Restore original clipboard after delay
    SetTimer(() => A_Clipboard := savedClip, -3000)
}

; =========================
; HTTP POST with proper UTF-8 handling
; =========================
HttpPostUtf8(url, jsonData, apiKey) {
    try {
        ; Use reliable HTTP object
        http := ComObject("MSXML2.XMLHTTP.6.0")
        http.Open("POST", url, false)
        
        ; Set headers
        http.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        http.SetRequestHeader("Authorization", "Bearer " . apiKey)
        http.SetRequestHeader("User-Agent", "AutoHotkey/2.0 TextCorrector")
        
        ; Send UTF-8 encoded string
        http.Send(jsonData)

        ; Check response status
        if (http.Status != 200) {
            errorMsg := "HTTP Error: " . http.Status . " - " . http.StatusText
            if (http.ResponseText) {
                errorMsg .= "`nResponse: " . SubStr(http.ResponseText, 1, 200) . "..."
            }
            Notify(errorMsg, 5000)
            return ""
        }

        ; Return text (handles UTF-8)
        return http.ResponseText
        
    } catch Error as e {
        Notify("Network error: " . e.Message, 4000)
        return ""
    }
}

; =========================
; JSON: Object to string
; =========================
ObjToJson(val) {
    t := Type(val)
    
    switch t {
        case "String":
            return '"' . JsonEscape(val) . '"'
        case "Integer", "Float":
            return String(val)
        case "Array":
            parts := []
            for v in val {
                parts.Push(ObjToJson(v))
            }
            return "[" . StrJoin(parts, ",") . "]"
        case "Map":
            parts := []
            for k, v in val {
                parts.Push('"' . JsonEscape(String(k)) . '":' . ObjToJson(v))
            }
            return "{" . StrJoin(parts, ",") . "}"
        default:
            return "null"
    }
}

JsonEscape(s) {
    ; Escape special JSON characters
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`b", "\b")
    s := StrReplace(s, "`f", "\f")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "\r")
    s := StrReplace(s, "`t", "\t")
    
    ; Handle Unicode characters (0x00-0x1F)
    loop 32 {
        char := Chr(A_Index - 1)
        if (InStr(s, char)) {
            s := StrReplace(s, char, "\u" . Format("{:04X}", A_Index - 1))
        }
    }
    
    return s
}

StrJoin(arr, sep) {
    result := ""
    for i, v in arr {
        if (i > 1) {
            result .= sep
        }
        result .= v
    }
    return result
}

; =========================
; Extract corrected text
; =========================
ExtractCorrectedText(jsonResponse) {
    try {
        pattern := '"content"\s*:\s*"((?:[^"\\]|\\.)*)"|"content"\s*:\s*`"((?:[^`"\\\\]|\\\\.)*)"`"'
        
        if RegExMatch(jsonResponse, pattern, &match) {
            content := match[1] ? match[1] : match[2]
            
            ; Unescape JSON string
            content := JsonUnescape(content)
            
            ; Trim whitespace
            content := Trim(content)
            
            return content
        }
        
        if RegExMatch(jsonResponse, '"role"\s*:\s*"assistant".*?"content"\s*:\s*"((?:[^"\\]|\\.)*)"', &match2) {
            return JsonUnescape(Trim(match2[1]))
        }
        
    } catch Error as e {
        Notify("JSON parsing error: " . e.Message, 3000)
    }
    
    return ""
}

JsonUnescape(s) {
    ; Unescape JSON string reverse order of escaping
    s := StrReplace(s, '\"', '"')
    s := StrReplace(s, "\\", "\")
    s := StrReplace(s, "\b", "`b")
    s := StrReplace(s, "\f", "`f")
    s := StrReplace(s, "\n", "`n")
    s := StrReplace(s, "\r", "`r")
    s := StrReplace(s, "\t", "`t")
    
    ; Handle Unicode escapes \uXXXX
    while RegExMatch(s, "\\u([0-9A-Fa-f]{4})", &match) {
        unicodeChar := Chr("0x" . match[1])
        s := StrReplace(s, match[0], unicodeChar)
    }
    
    return s
}

; =========================
; Swiss German conversion (ß to ss)
; =========================
ConvertToSwissGerman(text) {
    return StrReplace(text, "ß", "ss")
}

; =========================
; UI Helper
; =========================
Notify(message, duration := 2000) {
    ; mouse position for tooltip
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    
    ; offset
    ToolTip(message, x + 15, y + 15)
    
    ; Auto-hide
    SetTimer(() => ToolTip(), -duration)
}