<#
.SYNOPSIS
    Downloads and installs the Cascadia Code Nerd Font, then configures Windows Terminal to use it.
.DESCRIPTION
    Downloads the latest CascadiaCode release from microsoft/cascadia-code, installs
    CascadiaCodeNF and CascadiaMonoNF OTF font files per-user using the Windows Shell
    API, and sets "Cascadia Mono NF" as the default font in Windows Terminal.
    If fonts are already installed, checks for updates and prompts if one is available.
    Use -Force to update without prompting.
.PARAMETER FontName
    The font face name to set in Windows Terminal. Defaults to "Cascadia Mono NF".
.PARAMETER SkipTerminalConfig
    Skip updating Windows Terminal settings.
.PARAMETER Force
    Re-download and reinstall fonts even if already installed, without prompting.
#>
param(
    [string]$FontName = "Cascadia Mono NF",
    [switch]$SkipTerminalConfig,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# --- Configuration ---
$fontInstallDir  = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$fontFilePattern = '^Cascadia(Code|Mono)NF.*\.otf$'
$versionFile     = Join-Path $fontInstallDir '.cascadia-nf-version'
$shellFontsId    = 0x14  # CSIDL for per-user fonts namespace

# --- Helper functions ---

function Test-NerdFontsInstalled {
    if (-not (Test-Path $fontInstallDir)) { return $false }
    $existing = @(Get-ChildItem -Path $fontInstallDir -Filter '*.otf' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match $fontFilePattern })
    return ($existing.Count -gt 0)
}

function Get-InstalledNerdFontVersion {
    if (Test-Path $versionFile) {
        return (Get-Content -Path $versionFile -Raw).Trim()
    }
    return $null
}

function Get-LatestNerdFontRelease {
    $releaseUrl = 'https://api.github.com/repos/microsoft/cascadia-code/releases/latest'
    $headers = @{ 'User-Agent' = 'dotfiles-setup' }
    return Invoke-RestMethod -Uri $releaseUrl -Headers $headers
}

function Get-NerdFontArchive {
    <#
    .DESCRIPTION
        Downloads and extracts the Cascadia Code release zip.
        Returns a hashtable with TempDir (caller must clean up) and FontFiles.
        Cleans up on failure.
    #>
    param([object]$Release)

    $asset = $Release.assets |
        Where-Object { $_.name -match '\.zip$' -and $_.name -notmatch 'source' } |
        Select-Object -First 1
    if (-not $asset) { throw "No zip asset found in the latest release." }

    Write-Host "Downloading $($asset.name) ($([math]::Round($asset.size / 1MB, 1)) MB)..."

    $tempDir = Join-Path $env:TEMP "cascadia-nf-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        $zipPath = Join-Path $tempDir $asset.name
        # WebClient is much faster than Invoke-WebRequest for large files
        (New-Object System.Net.WebClient).DownloadFile($asset.browser_download_url, $zipPath)

        Write-Host "Extracting fonts..."
        $extractDir = Join-Path $tempDir 'extracted'
        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

        $fontFiles = @(Get-ChildItem -Path $extractDir -Recurse -Filter '*.otf' |
            Where-Object { $_.Name -match $fontFilePattern })

        if ($fontFiles.Count -eq 0) {
            throw "No matching Nerd Font OTF files found in the archive."
        }

        return @{ TempDir = $tempDir; FontFiles = $fontFiles }
    } catch {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        throw
    }
}

function Install-NerdFontFiles {
    <#
    .DESCRIPTION
        Installs font files using the Windows Shell API (same as right-click > Install).
        Handles locked file replacement natively.
    #>
    param(
        [Parameter(Mandatory)][object[]]$FontFiles,
        [string]$Version
    )

    $shell = New-Object -ComObject Shell.Application
    $fontsFolder = $shell.Namespace($shellFontsId)

    # Stage all fonts in a flat temp directory for a single batch CopyHere call
    $stagingDir = Join-Path $env:TEMP "cascadia-nf-stage-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

    try {
        foreach ($font in $FontFiles) {
            Copy-Item -LiteralPath $font.FullName -Destination (Join-Path $stagingDir $font.Name)
        }

        $stagingFolder = $shell.Namespace($stagingDir)
        $items = $stagingFolder.Items()

        # CopyHere flags: 0x10 = yes to all, 0x4 = no progress dialog, 0x400 = no error UI
        $copyFlags = 0x10 -bor 0x4 -bor 0x400
        $fontsFolder.CopyHere($items, $copyFlags)

        Write-Host "  Installed $($FontFiles.Count) font files."
    } finally {
        Remove-Item -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($Version) {
        if (-not (Test-Path $fontInstallDir)) {
            New-Item -ItemType Directory -Path $fontInstallDir -Force | Out-Null
        }
        $Version | Set-Content -Path $versionFile -NoNewline
    }
}

# --- Install/update fonts ---
$alreadyInstalled = Test-NerdFontsInstalled

if ($alreadyInstalled -and -not $Force) {
    Write-Host "Nerd Font files already installed."

    # Check if an update is available
    Write-Host "Checking for updates..."
    try {
        $release = Get-LatestNerdFontRelease
        $latestVersion = $release.tag_name
        $installedVersion = Get-InstalledNerdFontVersion

        if ($installedVersion -and $installedVersion -eq $latestVersion) {
            Write-Host "Already up to date ($installedVersion)."
        } else {
            if ($installedVersion) {
                Write-Host "Update available: $installedVersion -> $latestVersion"
            } else {
                Write-Host "Latest version: $latestVersion"
            }

            $response = Read-Host "Would you like to update? (y/n)"
            if ($response -match '^[yY]') {
                $Force = $true
            }
        }
    } catch {
        Write-Warning "Could not check for updates: $($_.Exception.Message)"
    }
}

if (-not $alreadyInstalled -or $Force) {
    if (-not $release) {
        Write-Host "Fetching latest release info from microsoft/cascadia-code..."
        $release = Get-LatestNerdFontRelease
    }
    Write-Host "Latest release: $($release.name)"

    if ($alreadyInstalled) {
        $installedVersion = Get-InstalledNerdFontVersion
        if ($installedVersion -and $installedVersion -eq $release.tag_name) {
            Write-Host "Already up to date ($installedVersion). Reinstalling..."
        } elseif ($installedVersion) {
            Write-Host "Updating: $installedVersion -> $($release.tag_name)"
        }
    }

    $archive = Get-NerdFontArchive -Release $release
    try {
        Write-Host "Installing $($archive.FontFiles.Count) font files..."
        Install-NerdFontFiles -FontFiles $archive.FontFiles -Version $release.tag_name
        Write-Host "Font installation complete."
    } finally {
        Remove-Item -Path $archive.TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# --- Configure Windows Terminal (surgical edit to preserve comments/formatting) ---
if (-not $SkipTerminalConfig) {
    $wtInstalls = @(
        @{ Name = 'Windows Terminal';         Paths = @(
            (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
            (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
        )},
        @{ Name = 'Windows Terminal Preview'; Paths = @(
            (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
        )}
    )

    $foundAny = $false

    foreach ($wt in $wtInstalls) {
        $settingsFile = $wt.Paths | Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $settingsFile) { continue }
        $foundAny = $true
        $wtName = $wt.Name

        $content = Get-Content -Path $settingsFile -Raw

        # Check if defaults already has the right font and no non-NF overrides exist
        $defaultsHasFont = $content -match '"defaults"\s*:\s*\{[^}]*"face"\s*:\s*"' + [regex]::Escape($FontName) + '"'
        $hasNonNFOverrides = $content -match '"face"\s*:\s*"Cascadia (Mono|Code)(?!\s*NF)"'

        if ($defaultsHasFont -and -not $hasNonNFOverrides) {
            Write-Host "$wtName already configured for '$FontName'."
            continue
        }

        Write-Host "Configuring $wtName ($settingsFile)..."

        $fontBlock = "`"font`":`n            {`n                `"face`": `"$FontName`"`n            }"
        $modified = $false

        # Case 1: defaults already has a "font" block — replace it
        if ($content -match '("defaults"\s*:\s*\{[^}]*)"font"\s*:\s*\{[^}]*\}') {
            $content = $content -replace '("defaults"\s*:\s*\{[^}]*)"font"\s*:\s*\{[^}]*\}', "`$1$fontBlock"
            $modified = $true
        }
        # Case 2: defaults exists but is empty — inject font into it
        elseif ($content -match '"defaults"\s*:\s*\{\s*\}') {
            $content = $content -replace '"defaults"\s*:\s*\{\s*\}', "`"defaults`":`n        {`n            $fontBlock`n        }"
            $modified = $true
        }
        # Case 3: defaults exists with other content but no font — append font
        elseif ($content -match '("defaults"\s*:\s*\{)(\s*)') {
            $content = $content -replace '("defaults"\s*:\s*\{)(\s*)', "`$1`$2$fontBlock,`$2"
            $modified = $true
        }

        # Replace non-NF Cascadia font overrides with NF equivalents in profiles
        $fontReplacements = @{
            'Cascadia Mono'  = 'Cascadia Mono NF'
            'Cascadia Code'  = 'Cascadia Code NF'
        }

        $defaultsEnd = $content.IndexOf('"defaults"')
        if ($defaultsEnd -ge 0) {
            $listStart = $content.IndexOf('"list"', $defaultsEnd)
            if ($listStart -ge 0) {
                $before = $content.Substring(0, $listStart)
                $after = $content.Substring($listStart)

                foreach ($oldFont in $fontReplacements.Keys) {
                    $newFont = $fontReplacements[$oldFont]
                    $replacePattern = '("face"\s*:\s*")' + [regex]::Escape($oldFont) + '(?!\s*NF)(")'
                    $after = [regex]::Replace($after, $replacePattern, "`$1$newFont`$2")
                }

                # Remove per-profile font blocks that are now redundant (match the default)
                $redundantPattern = ',?\s*"font"\s*:\s*\{\s*"face"\s*:\s*"' + [regex]::Escape($FontName) + '"\s*\}'
                $after = [regex]::Replace($after, $redundantPattern, '')
                $after = $after -replace ',(\s*})', '$1'
                $after = $after -replace '{(\s*),', '{$1'

                $content = $before + $after
                $modified = $true
            }
        }

        if ($modified) {
            Set-Content -Path $settingsFile -Value $content -NoNewline -Encoding UTF8
            Write-Host "$wtName default font set to '$FontName'."
        } else {
            Write-Warning "Could not locate 'defaults' in $wtName settings. You may need to set the font manually."
        }
    }

    if (-not $foundAny) {
        Write-Host "Windows Terminal settings not found. Skipping terminal configuration."
    }
}

Write-Host "`nDone!"
