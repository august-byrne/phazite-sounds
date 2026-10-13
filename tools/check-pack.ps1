# SPDX-License-Identifier: CC0-1.0
# Checks the pack before it is committed or released (CI runs it on every push):
#  - pack/sources.json lists every sound in pack/, and only those, each as CC0 1.0;
#  - every sound taken from a collection names its sources: title, author, an https link, the evidence that the
#    source is CC0, and the downloaded file's SHA-256;
#  - every sound is a FLAC file, no file is larger than 5 MiB, and README.txt and the CC0 legal code go with the pack.
# Run it from the repository's folder:
#   Windows: powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-pack.ps1
#   Linux, macOS: pwsh tools/check-pack.ps1
# Works with Windows PowerShell 5.1 and PowerShell 7.
$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$pack = Join-Path $repository 'pack'
$problems = New-Object System.Collections.Generic.List[string]

function Test-Text ($value) { ($value -is [string]) -and ($value.Trim().Length -gt 0) }

$manifestFile = Join-Path $pack 'sources.json'

if (-not (Test-Path -LiteralPath $manifestFile -PathType Leaf)) {
    Write-Host 'pack/sources.json is missing: render the pack first (README.md, "Making the pack").'
    exit 1
}

$manifest = [System.IO.File]::ReadAllText($manifestFile) | ConvertFrom-Json

if (-not (Test-Text $manifest.pack)) { $problems.Add('sources.json has no "pack" name.') }
if (-not ($manifest.version -is [int] -or $manifest.version -is [long]) -or $manifest.version -lt 1) { $problems.Add('sources.json has no whole "version".') }
if (-not ("$($manifest.date)" -match '^\d{4}-\d{2}-\d{2}$')) { $problems.Add('sources.json has no "date" written as 2026-10-13.') }

# The sounds sources.json lists, and how each was made.
$listed = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)

foreach ($sound in @($manifest.sounds)) {
    $file = $sound.file

    if (-not (Test-Text $file)) { $problems.Add('sources.json has a sound without a "file".'); continue }
    if (-not $listed.Add($file)) { $problems.Add("$file is listed twice.") }
    if ($sound.licence -cne 'CC0-1.0') { $problems.Add("$file isn't listed as CC0-1.0.") }
    if (-not (Test-Text $sound.made)) { $problems.Add("$file doesn't say how it was made."); continue }
    if (-not (Test-Text $sound.processing)) { $problems.Add("$file doesn't say how it was processed.") }

    $sources = @($sound.sources | Where-Object { $null -ne $_ })

    if ($sound.made -match '^(taken|mixed) ') {
        if ($sources.Count -eq 0) { $problems.Add("$file is taken from a collection but names no source.") }
    }
    elseif ($sound.made -notmatch '^(synthesized|played) ') {
        $problems.Add("$file was made in a way this check doesn't know: $($sound.made)")
    }

    foreach ($source in $sources) {
        $what = "$file's source $($source.title)"
        if (-not (Test-Text $source.title) -or -not (Test-Text $source.author)) { $problems.Add("$what needs a title and an author.") }
        if (-not ("$($source.url)" -match '^https://\S+$')) { $problems.Add("$what needs an https link.") }
        if ($source.licence -cne 'CC0-1.0') { $problems.Add("$what isn't listed as CC0-1.0.") }
        if (-not (Test-Text $source.licenceEvidence)) { $problems.Add("$what needs the evidence that it is CC0.") }
        if (-not ("$($source.sha256)" -cmatch '^[0-9a-f]{64}$')) { $problems.Add("$what needs the SHA-256 of the downloaded file.") }
    }
}

# The files in the pack: every sound listed, every one FLAC, none too large.
$present = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$audio = '.flac', '.wav', '.ogg', '.mp3', '.aif', '.aiff', '.m4a', '.opus'

foreach ($item in Get-ChildItem -LiteralPath $pack -Recurse -File) {
    $path = $item.FullName.Substring($pack.Length + 1).Replace('\', '/')

    if ($item.Length -gt 5MB) { $problems.Add("$path is larger than 5 MiB.") }
    if ($audio -notcontains $item.Extension.ToLowerInvariant()) { continue }

    [void] $present.Add($path)

    if (-not $listed.Contains($path)) { $problems.Add("$path isn't listed in sources.json.") }

    $stream = [System.IO.File]::OpenRead($item.FullName)

    try {
        $start = New-Object byte[] 4
        $read = $stream.Read($start, 0, 4)
    }
    finally {
        $stream.Dispose()
    }

    if ($read -ne 4 -or [System.Text.Encoding]::ASCII.GetString($start) -cne 'fLaC') { $problems.Add("$path isn't a FLAC file.") }
}

foreach ($file in $listed) {
    if (-not $present.Contains($file)) { $problems.Add("$file is listed in sources.json but isn't in pack/.") }
}

foreach ($name in 'README.txt', 'LICENSE.txt') {
    if (-not (Test-Path -LiteralPath (Join-Path $pack $name) -PathType Leaf)) { $problems.Add("pack/$name is missing.") }
}

$licence = Join-Path $pack 'LICENSE.txt'

if ((Test-Path -LiteralPath $licence -PathType Leaf) -and -not ([System.IO.File]::ReadAllText($licence).Contains('CC0 1.0 Universal'))) {
    $problems.Add("pack/LICENSE.txt isn't the CC0 1.0 Universal legal code.")
}

if ($problems.Count -gt 0) {
    Write-Host "The pack has $($problems.Count) problem(s):"
    $problems | ForEach-Object { Write-Host "  $_" }
    exit 1
}

Write-Host "The pack is fine: $($listed.Count) sounds, every one CC0 1.0 and listed in sources.json with where it came from."
