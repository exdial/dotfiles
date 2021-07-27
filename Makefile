USER := $(shell id -un)
GROUP := $(shell id -gn)

export USER GROUP

welcome:
	@head -n 7 README.md | tail -n6
	@echo
	@sleep 2

goodbye:
	@echo The system has been successfully configured.

copy-dotfiles: ## Copy dotfiles to $HOME
	@for i in $$(find files -type f -exec basename {} \;); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save && mv ~/.$$i ~/dotfiles_save/; \
		echo "λ => copying dotfiles... $$i"; \
		cp -rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

copy-ssh-config:
	@echo "λ => copying SSH config"
	@mkdir -p ~/.ssh
	@test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config.save
	@cp -rn ssh-config ~/.ssh/config

configure-vim:
	@echo "λ => configuring Vim"
	@mkdir -p ~/.vim/autoload ~/.vim/bundle
	@curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

install-pip:
	@echo "λ => installing Python PIP"
	@curl -LSs https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	@python3 get-pip.py --user
	@rm git-pip.py

install-homebrew-mac:
	@echo "λ => installing Homebrew"
	@test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	@curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

install-packages-linux:
	@echo "λ => installing Linux packages"
	@sudo apt-get update
	@sudo apt-get install -y curl tar git unzip rsync vim restic neofetch --no-install-recommends

install-packages-mac:
	@command -v brew > /dev/null || exit 1
	@echo "λ => installing Brew packages"
	@brew bundle

check-git:
	@command -v git > /dev/null || exit 1

pull-sublime-config-mac: ## Pull Sublime Text settings (mac only)
	@echo 'λ => pulling Sublime Text settings "Installed Packages"...'
	@rsync -arulzh -progress "/Users/$$USER/Library/Application Support/Sublime Text/Installed Packages" sublime/
	@echo 'λ => pulling Sublime Text settings "Packages/User"...'
	@rsync -arulzh -progress "/Users/$$USER/Library/Application Support/Sublime Text/Packages/User" sublime/Packages/

restore-sublime-config-mac: ## Restore Sublime Text settings (mac only)
	@echo 'λ => copying Sublime Text settings "Installed Packages"...'
	@rsync -arulzh -progress "sublime/Installed Packages" "/Users/$$USER/Library/Application Support/Sublime Text"
	@echo 'λ => copying Sublime Text settings "Packages/User"...'
	@rsync -arulzh -progress "sublime/Packages" "/Users/$$USER/Library/Application Support/Sublime Text"

wrong-platform:
	@echo wrong platform

install-on-mac: welcome check-git copy-dotfiles copy-ssh-config install-homebrew-mac install-packages-mac configure-vim install-pip goodbye

install-on-linux: welcome install-packages-linux copy-dotfiles copy-ssh-config configure-vim goodbye

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	TARGET = install-on-linux
else ifeq ($(UNAME), Darwin)
	TARGET = install-on-mac
else
	TARGET = wrong-platform
endif

install: $(TARGET) ## Install dotfiles, software packages, configure Vim


.PHONY: install install-on-mac install-on-linux

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
