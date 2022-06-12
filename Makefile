USER := $(shell id -un)
GROUP := $(shell id -gn)
UNAME :=$(shell uname)
RAND := $(shell /bin/sh -c "echo $$RANDOM")

export USER GROUP UNAME

ifeq ($(UNAME), Linux)
	TARGET = linux
else ifeq ($(UNAME), Darwin)
	TARGET = mac
else
	TARGET = wrong-platform
endif


install: $(TARGET) ## Install all

linux: logo dotfiles sshconfig vim python-pip linux-packages gitconfig bye

mac: logo dotfiles sshconfig vim python-pip mac-packages gitconfig bye

wrong-platform: logo
	@echo Wrong platform

# Helpers
logo:
	@clear && head -n7 README.md | tail -n6 && echo

bye:
	@echo && echo The system has been successfully configured! 🍰 && echo

gitconfig: logo ## Configure git client
	@read -p "Now let's configure git client. Enter your name: " NAME; \
	 git config --global user.name $$NAME
	@read -p "And Email: " EMAIL; \
	 git config --global user.email $$EMAIL

dotfiles: ## Copy dotfiles to home directory
	@for i in $$(find files -type f -exec basename {} \;); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save_$(RAND) && mv ~/.$$i ~/dotfiles_save_$(RAND); \
		echo "λ => copying dotfiles... $$i"; \
		cp -Rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

sshconfig: ## Configure SSH client
	@echo "λ => copying SSH config..."
	@test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config_save_$(RAND) || exit 0
	@mkdir -p ~/.ssh/tmp
	@cp -Rv ssh-config ~/.ssh/config

vim: ## Configure Vim
	@echo "λ => configuring Vim..."
	@mkdir -p ~/.vim/autoload ~/.vim/bundle
	@curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

python-pip: ## Configure Python PIP
	@echo "λ => installing Python PIP..."
	@curl -LSs https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	@python3 get-pip.py --user --no-warn-script-location && rm get-pip.py

homebrew: ## Install homebrew (mac only)
	@echo "λ => installing Homebrew"
	@test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	@curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

linux-packages: ## Install Linux packages
	@echo "λ => installing Apt packages..."
	@sudo apt-get update
	@sudo apt-get install -y curl tar unzip rsync vim restic resilio-sync neofetch --no-install-recommends

mac-packages: ## Install Brew packages
	@echo "λ => installing Brew packages"
	@/Users/$$USER/.homebrew/bin/brew bundle

mac-packages-extra: ## Install extra Mac packages
	@echo "λ => installing Brew extra packages"
	@/Users/$$USER/.homebrew/bin/brew bundle --file Brewfile-extra

clean: ## Remove backup configs
	@echo "λ => removing backup configs"
	@rm -rf /Users/$$USER/dotfiles_save_*
	@rm /Users/$$USER/.ssh/config_save_*


.PHONY: install linux mac wrong-platform logo bye dotfiles sshconfig vim python-pip homebrew linux-packages mac-packages mac-packages-extra clean gitconfig

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
