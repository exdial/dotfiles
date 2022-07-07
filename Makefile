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

all: $(TARGET)-extra ## Install dotfiles, packages and extra

install: $(TARGET) ## Install only dotfiles

linux: logo dotfiles sshconfig vim python-pip gitconfig bye

linux-extra: logo dotfiles sshconfig vim python-pip linux-packages gitconfig bye

mac: logo dotfiles sshconfig vim python-pip homebrew gitconfig bye

mac-extra: logo dotfiles sshconfig vim python-pip homebrew mac-packages mac-packages-extra gitconfig bye

wrong-platform: logo
	@echo Wrong platform

# Helpers
logo:
	@clear && head -n7 README.md | tail -n6 && echo

bye:
	@echo && echo The system has been successfully configured! 🍰 && echo

gitconfig: logo
	@read -p "Now let's configure git client. Enter your name: " NAME; \
	 git config --global user.name $$NAME
	@read -p "And Email: " EMAIL; \
	 git config --global user.email $$EMAIL

dotfiles:
	@echo
	@for i in $$(find files -type f -exec basename {} \;); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save_$(RAND) && mv ~/.$$i ~/dotfiles_save_$(RAND); \
		echo "λ => copying dotfiles... $$i"; \
		cp -Rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

sshconfig:
	@echo "λ => copying SSH config..."
	@test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config_save_$(RAND) || exit 0
	@mkdir -p ~/.ssh/tmp
	@cp -Rv ssh-config ~/.ssh/config

vim:
	@echo "λ => configuring Vim..."
	@mkdir -p ~/.vim/autoload ~/.vim/bundle
	@curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

python-pip:
	@echo "λ => installing Python PIP..."
	@curl -LSs https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	@python3 get-pip.py --user --no-warn-script-location && rm get-pip.py

homebrew:
	@echo "λ => installing Homebrew..."
	@test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	@curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

linux-packages:
	@echo "λ => installing Apt packages..."
	@sudo apt-get update
	@sudo apt-get install -y curl tar unzip rsync vim restic resilio-sync neofetch --no-install-recommends

mac-packages:
	@echo "λ => installing Brew packages..."
	@/Users/$$USER/.homebrew/bin/brew bundle

mac-packages-extra:
	@echo "λ => installing Brew extra packages..."
	@/Users/$$USER/.homebrew/bin/brew bundle --file Brewfile-extra

clean: ## Remove backup configs
	@echo "λ => removing backup configs..."
	@-rm -rf ~/dotfiles_save_*
	@-rm ~/.ssh/config_save_*

uninstall: ## Remove dotfiles including ssh config
	@echo "λ => removing dotfiles..."
	@-rm -rf ~/.bash_profile ~/.bashrc ~/.bashrc.local ~/.dircolors ~/.editorconfig \
			 ~/.gemrc ~/.gitconfig ~/.gitignore.global ~/.gitmessage ~/.hushlogin \
			 ~/.inputrc ~/.vimrc ~/.bash_history ~/.bash_sessions ~/.gitconfig.local \
			 ~/.lesshst ~/.ssh ~/.vim ~/.viminfo ~/.zsh_history ~/.zsh_sessions 2>/dev/null

secrets: ## Make an archive with ssh keys, aws tokens, etc
	@echo "λ => archiving secrets..."
	@-mkdir -p secrets && rm secrets.tar.gz
	@-for i in aws grip hal kube spin ssh; do \
		cp -Rn ~/.$$i secrets/$$i 2>/dev/null; \
	done
	@tar cvfz secrets.tar.gz secrets
	@-rm -rf secrets

tunemymac: ## Apply recommended MacOS settings
	@echo "λ => applying MacOS settings..."
	@chmod +x .macos
	@exec ./.macos
	@chmod -x ./macos

.PHONY: all clean install secrets uninstall

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
