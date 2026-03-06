# My Personal Dotfiles
These are my personal config files for vim, etc.

## Install Instructions
Run the following commands in the home directory (on Windows):
- `git clone https://github.com/reallyblackbuffalo/dotfiles .dotfiles`
- `.dotfiles\setupWin`

## Install Nerd Font
Some of the Neovim plugins require a [Nerd Font](https://github.com/ryanoasis/nerd-fonts) to show icons correctly.
This repo uses [Cascadia Code](https://github.com/microsoft/cascadia-code) (the CascadiaCodeNF and CascadiaMonoNF variants).

The `setupWin` script will run the Nerd Font install automatically. You can also run `setupScripts\Install-NerdFont.ps1` directly. Use the `-Force` flag to update to the latest version without prompting.

**Manual install:** Download the zip from the [latest release](https://github.com/microsoft/cascadia-code/releases/latest) (not the source), extract the archive, then in the otf folder, select all of the CascadiaCodeNF and CascadiaMonoNF files, right-click, and select Install.
