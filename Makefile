USER := $(shell id -un)
GROUP := $(shell id -gn)

export USER GROUP

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	TARGET = install-on-linux
else ifeq ($(UNAME), Darwin)
	TARGET = install-on-mac
else
	TARGET = wrong-platform
endif

logo:
	@clear && head -n7 README.md | tail -n6 && echo

bye:
	@echo
	@echo The system has been successfully configured!

check-git:
	@command -v git > /dev/null || exit 1

copy-dotfiles: logo ## Copy dotfiles to home directory
	@for i in $$(find files -type f -exec basename {} \;); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save && mv ~/.$$i ~/dotfiles_save/; \
		echo "λ => copying dotfiles... $$i"; \
		cp -Rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done
	@source ~/.bashrc

config-ssh: logo ## Copy SSH config to ~/.ssh
	@echo "λ => copying SSH config..."
	@test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config.save || exit 0
	@mkdir -p ~/.ssh/tmp
	@cp -Rv ssh-config ~/.ssh/config

config-vim: logo ## Configure Vim
	@echo "λ => configuring Vim..."
	@mkdir -p ~/.vim/autoload ~/.vim/bundle
	@curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

install-pip: logo ## Install Python PIP
	@echo "λ => installing Python PIP..."
	@curl -LSs https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	@python3 get-pip.py --user --no-warn-script-location && rm get-pip.py

install-pkgs-linux:
	@echo "λ => installing Linux packages..."
	@sudo apt-get update
	@sudo apt-get install -y curl tar git unzip rsync vim restic resilio-sync neofetch --no-install-recommends

install-pkgs-mac:
	@export PATH=/Users/$$USER/.homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
	@command -v brew > /dev/null || echo brew missing && exit 1
	@echo "λ => installing Brew packages"
	@brew bundle

install-extra-pkgs-mac:
	@export PATH=/Users/$$USER/.homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
	@command -v brew > /dev/null || echo brew missing && exit 1
	@echo "λ => installing Brew extra packages"
	@brew bundle --file Brewfile-extra

install-homebrew-mac:
	@echo "λ => installing Homebrew"
	@test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	@curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

install-sublime-config-mac: ## Install Sublime Text config (mac only)
	@echo 'λ => copying Sublime Text settings "Installed Packages"...'
	@rsync -arulzh -progress "sublime/Installed Packages" \
		"/Users/$$USER/Library/Application Support/Sublime Text"
	@echo 'λ => copying Sublime Text settings "Packages/User"...'
	@rsync -arulzh -progress "sublime/Packages" \
		"/Users/$$USER/Library/Application Support/Sublime Text"

backup-sublime-config-mac: ## Backup Sublime Text config (mac only)
	@echo 'λ => pulling Sublime Text settings "Installed Packages"...'
	@rsync -arulzh -progress "/Users/$$USER/Library/Application Support/Sublime Text/Installed Packages" sublime/
	@echo 'λ => pulling Sublime Text settings "Packages/User"...'
	@rsync -arulzh -progress "/Users/$$USER/Library/Application Support/Sublime Text/Packages/User" sublime/Packages/

install: $(TARGET) ## Install software and configure environment

install-on-linux: logo check-git copy-dotfiles config-ssh config-vim install-pip install-pkgs-linux bye

install-on-mac: logo check-git copy-dotfiles config-ssh config-vim install-pip install-homebrew-mac install-pkgs-mac install-extra-pkgs-mac install-sublime-config-mac bye

wrong-platform:
	@echo Wrong platform


.PHONY: install install-on-mac install-on-linux

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
