# dotfiles

My macOS development setup, managed with [chezmoi](https://www.chezmoi.io/). One command sets up a new Mac: shell, terminal, editor, CLI tools, apps, and secrets.

## Overview

| Area | Tools |
| --- | --- |
| Shell | zsh, [Oh My Zsh](https://ohmyz.sh/), [fzf-tab](https://github.com/Aloxaf/fzf-tab), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), [Starship](https://starship.rs/) prompt |
| Terminal | [Ghostty](https://ghostty.org/) (with a custom app icon), [Zellij](https://zellij.dev/) |
| Editor and files | [Helix](https://helix-editor.com/), [Yazi](https://yazi-rs.github.io/) (also used as Helix's file picker) |
| Git | Global git config and ignore file, [diffnav](https://github.com/dlvhdr/diffnav) as diff pager, [gh-dash](https://github.com/dlvhdr/gh-dash) |
| Packages | A global `Brewfile` with Homebrew formulae, casks, Go tools, and npm packages |
| Claude Code | `CLAUDE.md`, rules, settings, and [ccstatusline](https://github.com/sirmalloc/ccstatusline) |

Ghostty, Helix, Yazi, and Zellij all use the [Catppuccin](https://catppuccin.com/) Frappé theme.

## Requirements

- macOS on Apple silicon. The package install script only runs on macOS.
- The [Bitwarden CLI](https://bitwarden.com/help/cli/) and a Bitwarden account. Secrets in `~/.zprofile` come from a Bitwarden item named `zprofile`.
- SSH access to GitHub. Git config rewrites `https://github.com/` URLs to SSH.

## Setup on a new Mac

1. Install Homebrew, chezmoi, and the Bitwarden CLI:

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   brew install chezmoi bitwarden-cli
   ```

2. Log in to Bitwarden:

   ```sh
   bw login
   ```

3. Clone and apply the dotfiles:

   ```sh
   chezmoi init --apply clemparent/dotfiles
   ```

> [!NOTE]
> The first apply takes a while. It downloads Oh My Zsh and its plugins, then runs `brew bundle` on the full `Brewfile`. chezmoi unlocks Bitwarden automatically (`unlock = "auto"`) and asks for your master password once.

## Day-to-day use

| Task | Command |
| --- | --- |
| Edit a managed file | `chezmoi edit ~/.zshrc` |
| Preview changes before applying | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Pull from GitHub and apply | `chezmoi update` |
| Start tracking a new file | `chezmoi add ~/.config/foo/config` |
| Open the source repo | `chezmoi cd` |

### Packages

The package list is in [`dot_Brewfile`](dot_Brewfile), which becomes `~/.Brewfile`. To add a package, add a line to the Brewfile and run `chezmoi apply`.

The script [`run_onchange_after_install-packages.sh.tmpl`](run_onchange_after_install-packages.sh.tmpl) includes a hash of the Brewfile, so chezmoi re-runs it whenever the Brewfile changes. It runs `brew bundle --global --no-upgrade`, which installs missing packages and leaves installed versions alone. Run `brew upgrade` separately when you want upgrades.

> [!TIP]
> Install each tool with one package manager only. A tool listed both as `brew` and as `cargo`, for example, gets installed twice and can make `brew bundle` fail.

### External downloads

[`.chezmoiexternal.toml`](.chezmoiexternal.toml) downloads Oh My Zsh, fzf-tab, and zsh-syntax-highlighting from GitHub and refreshes them every 7 days. To force a refresh, run:

```sh
chezmoi apply --refresh-externals
```

## Secrets

No secrets are stored in this repo. [`private_dot_zprofile.tmpl`](private_dot_zprofile.tmpl) reads API keys and connection strings from the custom fields of the Bitwarden `zprofile` item when chezmoi applies it. The `private_` prefix makes chezmoi write the file with `600` permissions.

To add a secret:

1. Add a custom field to the `zprofile` item in Bitwarden.
2. Add a line to `private_dot_zprofile.tmpl`:

   ```sh
   export MY_KEY='{{ (bitwardenFields "item" "zprofile").MY_KEY.value }}'
   ```

3. Run `chezmoi apply`.

> [!WARNING]
> This repo is public. Before committing, check that no real key or token is in the diff. Use a Bitwarden template, never a plain value.

## Repository layout

chezmoi turns source file names into target paths:

| Prefix or suffix | Meaning | Example |
| --- | --- | --- |
| `dot_` | Becomes a leading `.` | `dot_zshrc` → `~/.zshrc` |
| `private_` | Written with owner-only permissions | `private_dot_zprofile.tmpl` → `~/.zprofile` |
| `readonly_` | Written without write permission | Yazi flavor files |
| `.tmpl` | Rendered as a Go template | `dot_gitconfig.tmpl` |
| `run_onchange_` | Script that runs when its content changes | Package install script |
