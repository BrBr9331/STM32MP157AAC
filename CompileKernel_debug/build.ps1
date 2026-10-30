# Expand the @import list in main.md into README.md. README is a build artifact.
# Behaviour mirrors Markdown Preview Enhanced:
#  - an import on its own line gets wrapped in a fenced code block whose language
#    is guessed from the file extension;
#  - an import already inside a fence is inserted as raw text, no extra fence;
#  - inside a blockquote every emitted line gets the "> " prefix;
#  - imports are expanded recursively.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Get-FenceLang([string]$name) {
    switch ([System.IO.Path]::GetExtension($name).ToLowerInvariant()) {
        '.bash' { 'bash' }
        '.sh' { 'bash' }
        '.txt' { 'text' }
        '.py' { 'python' }
        '.c' { 'c' }
        '.json' { 'json' }
        '.xml' { 'xml' }
        default { '' }
    }
}

function Expand-File([string]$path, [int]$depth) {
    if ($depth -gt 10) { throw "import nesting too deep: $path" }
    $enc = New-Object System.Text.UTF8Encoding($false)
    $lines = [System.IO.File]::ReadAllLines($path, $enc)
    $inFence = $false

    foreach ($line in $lines) {
        if ($line -match '^(\s*)((?:>\s*)*)@import\s+"([^"]+)"\s*$') {
            $indent = $Matches[1]
            $quote = $Matches[2]
            $rel = $Matches[3]
            $file = Join-Path $root $rel
            if (-not (Test-Path $file)) { throw "missing import: $rel (in $path)" }

            $prefix = $indent
            if ($quote) { $prefix = $indent + $quote.TrimEnd() + ' ' }

            $lang = Get-FenceLang $rel
            if ($inFence -or -not $lang) {
                foreach ($l in (Expand-File $file ($depth + 1))) { $prefix + $l }
            }
            else {
                $prefix + '```' + $lang
                foreach ($l in (Expand-File $file ($depth + 1))) { $prefix + $l }
                $prefix + '```'
            }
            continue
        }

        if (($line -replace '^(\s*(?:>\s*)*)', '') -match '^```') { $inFence = -not $inFence }
        $line
    }
}

$out = Expand-File (Join-Path $root 'main.md') 0
$text = (($out -join "`r`n").TrimEnd()) + "`r`n"

$readmePath = Join-Path $root 'README.md'
$bom = $false
if (Test-Path $readmePath) {
    $b = [System.IO.File]::ReadAllBytes($readmePath)
    $bom = ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF)
}

[System.IO.File]::WriteAllText($readmePath, $text, (New-Object System.Text.UTF8Encoding($bom)))
Write-Host "README.md rebuilt"
