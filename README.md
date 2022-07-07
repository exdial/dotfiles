```
            _       _    __ _ _
           | |     | |  / _(_) |
         __| | ___ | |_| |_ _| | ___  ___
        / _` |/ _ \| __|  _| | |/ _ \/ __|
       | (_| | (_) | |_| | | | |  __/\__ \
        \__,_|\___/ \__|_| |_|_|\___||___/
```

[![pre-commit](https://github.com/repconn/dotfiles/actions/workflows/pre-commit.yml/badge.svg?branch=master)](https://github.com/repconn/dotfiles/actions/workflows/pre-commit.yml)

# Abstract

This repository serves as a storage for all environment settings (dotfiles).
Built-in Makefile provides automated installation of environment settings
and recommended software.

Only Mac 🍏 and Linux 🐧 are supported platforms.

![](assets/screenshot.png)

Built-in Makefile will help you manage **Bash**, **Git** and **Vim** settings,
**.dircolors**, **.editorconfig**, **.inputrc** and so on.

This will never change or delete [sensitive files or directories](#secrets),
which usually contain important tokens and keys.

## Usage

Open Terminal program on this repository and run `make`.
You will see the options available to you.

```
all            Install all dotfiles, packages and extra
clean          Remove backup configs
install        Install dotfiles
secrets        Make an archive with ssh keys, aws tokens, etc
tunemymac      Apply recommended MacOS settings
uninstall      Remove dotfiles including ssh config
```

Run `make all` to install pre-configured dotfiles and the list of recommended software
on your system. Please note it is potentially dangerous operation that can delete
all your previous settings. In the end of installation, you will be asking for
email and name to complete configuration of *.gitconfig*.

Installation process will backup existing dotfiles if any.
You can find them by name *dotfiles_save_* in your home directory.
`make clean` command will delete these backup directories from your computer.

You can run `make install` instead of `make all` to install the only dotfiles
without performing installation heavy packages, like browsers, messengers, etc.

You can find uninstallation the option quite useful as well.
Run `make uninstall` to remove all dotfiles including SSH configuration file.

## Secrets

These sensitive directories will not be overwritten or deleted as a result of
automated installation: `~/.aws`, `~/.grip`, `~/.hal`, `~/.kube`, `~/.spin`, `~/.ssh`.
The option `make secrets` will copy these directories and create
an archive in the current directory named *secrets.tar.gz*,
that can be easily transferred to a new location.

## Feedback

[Suggestions and improvements](https://github.com/repconn/dotfiles/issues).
