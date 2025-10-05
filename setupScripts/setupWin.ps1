param(
    [string]$Tags,
    [string]$Ids,
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Prune
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Wait and exit helper (pauses when run interactively)
function Wait-ForKeyAndExit {
    param(
        [int]$Code = 0,
        [string]$Message = ''
    )
    if ($Message) { Write-Host $Message }
    if ($Host.Name -eq "ConsoleHost") {
        Write-Host "`nPress any key to continue..."
        $Host.UI.RawUI.FlushInputBuffer()
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
    }
    exit $Code
}

# Read PSV lines
$configPath = Join-Path $scriptDir 'setup-config.psv'
if (-not (Test-Path $configPath)) { Wait-ForKeyAndExit -Code 2 -Message "Config file not found: $configPath" }
$lines = Get-Content $configPath -ErrorAction Stop | ForEach-Object { $_.Trim() } | Where-Object { $_ -notmatch '^[#\s]*$' -and $_ -notmatch '^[#]' }

# Platform for this wrapper is 'windows'
$platform = 'windows'

# Initialize filters from parameters
$tagFilter = if ($Tags) { $Tags -split ',' | ForEach-Object { $_.Trim() } } else { @() }
$idFilter  = if ($Ids)  { $Ids  -split ',' | ForEach-Object { $_.Trim() } } else { @() }

function Resolve-PathString {
    param([string]$s)
    $s = $s -replace '\$\{REPO_ROOT\}', (Split-Path -Parent $scriptDir)
    $s = $s -replace '\$\{HOME\}', [Environment]::GetFolderPath('UserProfile')
    $s = $s -replace '\$\{USERPROFILE\}', $env:USERPROFILE
    $s = $s -replace '\$\{LOCALAPPDATA\}', $env:LOCALAPPDATA
    return [Environment]::ExpandEnvironmentVariables($s)
}

function Get-LinkTarget {
    param([string]$path)
    try {
        if (-not (Test-Path $path -PathType Any -ErrorAction SilentlyContinue)) { return $null }
        $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and $item.PSObject.Properties.Match('Target')) {
            $target = $item.Target
            # If target is an absolute path, resolve it. If it's relative, make it relative to the link's parent.
            try {
                if ($target -and (Test-Path $target)) {
                    return (Resolve-Path -LiteralPath $target -ErrorAction Stop).ProviderPath
                }
            } catch { }
            try {
                $parent = Split-Path -Parent $path
                $candidate = Join-Path $parent $target
                if ($target -and (Test-Path $candidate)) {
                    return (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).ProviderPath
                }
            } catch { }
            return $target
        }
        return $null
    } catch {
        return $null
    }
}

function New-SafeSymlink {
    param(
        [Parameter(Mandatory=$true)][string]$src,
        [Parameter(Mandatory=$true)][string]$dest,
        [switch]$force,
        [switch]$dryRun
    )

    # Resolve source and destination parent
    try { $resolvedSrc = (Resolve-Path -LiteralPath $src -ErrorAction Stop).ProviderPath } catch { $resolvedSrc = $src }
    $destParent = Split-Path -Parent $dest

    # Ensure parent exists
    if (-not (Test-Path $destParent)) {
        if ($dryRun) {
            Write-Host "DRY RUN: Would create parent directory $destParent"
        } else {
            Write-Host "Creating parent directory $destParent"
            New-Item -ItemType Directory -Force -Path $destParent | Out-Null
        }
    }

    # If destination is a symlink and points to desired source, nothing to do
    try {
        if (Test-Path $dest -PathType Any -ErrorAction SilentlyContinue) {
            $linkTarget = Get-LinkTarget -path $dest
            if ($linkTarget) {
                try { $resolvedLinkTarget = (Resolve-Path -LiteralPath $linkTarget -ErrorAction Stop).ProviderPath } catch { $resolvedLinkTarget = $linkTarget }
                if ($resolvedLinkTarget -and ($resolvedLinkTarget -eq $resolvedSrc)) {
                    Write-Host "Already linked: $dest -> $src"
                    return $true
                }
            }
        }
    } catch { }

    # If dest exists and not forced, bail
    if (Test-Path $dest -PathType Any) {
        if (-not $force) {
            Write-Host "Destination exists and is not the desired link: $dest (use -Force to replace)"; return $false
        }
        if ($dryRun) {
            Write-Host "DRY RUN: Would remove existing $dest"
        } else {
            # If it's a reparse point, remove it. Otherwise backup and move
            $existing = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
            if ($existing -and ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                Write-Host "Removing existing reparse point $dest"
                Remove-Item -LiteralPath $dest -Force
            } else {
                $backup = Join-Path (Split-Path -Parent $dest) ("$((Split-Path -Leaf $dest)).backup.$([int][double]::Parse((Get-Date -UFormat %s)))")
                Write-Host "Backing up existing $dest -> $backup"
                Move-Item -LiteralPath $dest -Destination $backup -Force
            }
        }
    }

    if ($dryRun) {
        Write-Host "DRY RUN: would create link $dest -> $src"
        return $true
    }

    # Attempt to create a symbolic link via New-Item
    try {
        New-Item -ItemType SymbolicLink -Path $dest -Target $src -ErrorAction Stop | Out-Null
    Write-Host "Created symlink $dest -> $src"
        return $true
    } catch {
        # If source is a directory, attempt junction fallback
        if (Test-Path $src -PathType Container) {
            try {
                Write-Host ('Attempting junction: mklink /J "' + $dest + '" "' + $src + '"')
                cmd /c mklink /J "$dest" "$src" | Out-Null
                Write-Host "Created junction $dest -> $src"
                return $true
            } catch {
                Write-Host "Failed to create junction or symlink for ${dest}: $($_.Exception.Message)"; return $false
            }
        } else {
            Write-Host "Failed to create symlink for file ${dest}: $($_.Exception.Message)"; return $false
        }
    }
}

$planned = @()
foreach ($line in $lines) {
    # collapse whitespace around pipes: 'a | b' -> 'a|b'
    $norm = $line -replace '\s*\|\s*', '|'
    $parts = $norm -split '\|'

    # Expect at least: id|source|platform|dest
    if ($parts.Count -lt 4) { Write-Warning "Skipping malformed line (expected at least 4 fields): '$line'"; continue }

    $id = $parts[0].Trim()
    $srcRel = $parts[1].Trim()
    $tplatform = $parts[2].Trim()
    $destRaw = $parts[3].Trim()
    $tagsStr = if ($parts.Count -ge 5) { $parts[4].Trim() } else { '' }

    # tag filter
    if ($tagFilter.Count -gt 0 -and $tagsStr) {
        $entryTags = $tagsStr -split ',' | ForEach-Object { $_.Trim() }
        if (-not (@($entryTags) | Where-Object { $tagFilter -contains $_ })) { continue }
    }
    if ($idFilter.Count -gt 0 -and $id -and ($idFilter -notcontains $id)) { continue }

    if ($tplatform -eq 'all' -or $tplatform -eq $platform) {
        $src = Join-Path (Split-Path -Parent $scriptDir) $srcRel
        $destResolved = Resolve-PathString $destRaw
        $planned += [PSCustomObject]@{ id=$id; src=$src; dest=$destResolved }
    }
}

    Write-Host "Planned links:"; $planned | ForEach-Object { Write-Host "  $($_.id): $($_.dest) -> $($_.src)" }

# Build set of planned destinations (use the resolved dests already stored in the plan)
$plannedDestSet = @{}
foreach ($p in $planned) { $plannedDestSet[$($p.dest.ToLower())] = $true }

$allSuccess = $true
foreach ($p in $planned) {
    $src = $p.src
    $dest = $p.dest
    if (-not (Test-Path $src)) { Write-Host "Source missing for $($p.id): $src"; $allSuccess = $false; continue }
    $ok = New-SafeSymlink -src $src -dest $dest -force:$Force -dryRun:$DryRun
    if (-not $ok) { $allSuccess = $false }
}

if ($Prune) {
    if ($tagFilter.Count -gt 0 -or $idFilter.Count -gt 0) {
        Write-Host "Prune skipped because --Tags/--Ids filters were used. Run prune with the full config to avoid accidental removal of valid links."; 
    } else {
        # prune symlinks that point into repo root but are not in plannedDestSet
        $repoRoot = (Split-Path -Parent $scriptDir)
        $parents = $planned | ForEach-Object { Split-Path -Parent $_.dest } | Sort-Object -Unique
        foreach ($parent in $parents) {
            if (-not (Test-Path $parent)) { continue }
            Get-ChildItem -LiteralPath $parent -Force | ForEach-Object {
                try {
                    if ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                        $childPath = $_.FullName
                        $target = Get-LinkTarget -path $childPath
                        if ($target -and ($target -like "$repoRoot*")) {
                            $lc = $childPath.ToLower()
                            if (-not $plannedDestSet.ContainsKey($lc)) {
                                if ($DryRun) { Write-Host "DRY RUN: Would prune $childPath (points to $target)" } else { Write-Host "Pruning $childPath (points to $target)"; Remove-Item -LiteralPath $childPath -Force }
                            }
                        }
                    }
                } catch {
                    Write-Host "Prune check failed for $($_.FullName): $($_.Exception.Message)"
                }
            }
        }
    }
}

# Final pause & exit
if (-not $allSuccess) { Wait-ForKeyAndExit -Code 1 } else { Wait-ForKeyAndExit -Code 0 }
