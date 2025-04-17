function SafeMake-Symlink {
    param (
        [string]$sourcePath,
        [string]$destPath
    )

    if (Test-Path -Path $destPath) {
        Write-Host "The destination ""$destPath"" already exists; skipping creation of symlink to avoid overwriting."
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path "$destPath" -Target "$sourcePath" -ErrorAction Stop > $null
            Write-Host "Made a symlink from $sourcePath to $destPath."
        } catch {
            Write-Host "Error trying to make symlink from ${sourcePath} to ${destPath}: $($_.Exception.Message)"
        }
    }
}

$homePath = Split-Path -Parent $PWD
SafeMake-Symlink "vimfiles" "$homePath\vimfiles"
SafeMake-Symlink "vimfiles" "$homePath\.vim"
SafeMake-Symlink ".config\nvim" "$homePath\AppData\Local\nvim"
SafeMake-Symlink ".config\Code\User\keybindings.json" "$homePath\AppData\Roaming\Code\User\keybindings.json"

if ($Host.Name -eq "ConsoleHost") {
    Write-Host "`nPress any key to continue..."
    $Host.UI.RawUI.FlushInputBuffer()
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
