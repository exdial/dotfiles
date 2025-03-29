```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

[![pre-commit](https://github.com/exdial/dotfiles/actions/workflows/pre-commit.yml/badge.svg?branch=master)](https://github.com/exdial/dotfiles/actions/workflows/pre-commit.yml)

# Abstract

This repository serves as a storage for all environment settings (dotfiles).

Built-in Makefile provides automated installation of dotfiles and packages.

Only Mac 🍏 and Linux 🐧 are supported platforms.

![](.github/images/screenshot.png)

Built-in Makefile will help you manage **Bash**, **Git** and **Vim** settings,
**.dircolors**, **.editorconfig**, **.inputrc**, etc...

## MTMR (My Touchbar My Rules) preset

[![](.github/images/touchbar.png)](https://github.com/exdial/dotfiles/blob/master/files/Library/Application%20Support/MTMR/items.json)

## Usage

Open Terminal program on this repository and run `make`.
You will see the options available to you.

```
all                  Install dotfiles, packages and extra
install              Install dotfiles only
secrets              Make an archive with keys, tokens, etc...
vminit               Bootstrap a brand new Linux VM
```

Run `make all` to copy dotfiles, install homebrew and set up
the git client on your system. At the end of the installation, you will be asked to
provide an email address and name to complete the *.gitconfig* setup.

The `make install` command install only dotfiles.

## Secrets

The sensitive directories `~/.aws`, `~/.grip`, `~/.hal`, `~/.kube`, `~/.spin`, `~/.ssh`
will not be overwritten or deleted by the automatic installation.
The `make secrets` will copy these directories and create
an archive in the current directory named *secrets.tar.gz*,
which can be easily saved to a new location.

## Feedback

[Suggestions and improvements](https://github.com/exdial/dotfiles/issues).
