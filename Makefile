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

install: $(TARGET) ## Install dotfiles and packages

linux: common git-config

mac: common mac-specific git-config

wrong-platform:
	echo ❌ Wrong platform

common:
	clear && head -n7 README.md | tail -n6 && echo
	echo
	for i in $$(find files -type f -exec basename {} \;); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save_$(RAND) && mv ~/.$$i ~/dotfiles_save_$(RAND); \
		echo "λ => copying dotfiles... $$i"; \
		cp -Rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

	echo "λ => copying SSH config..."
	test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config_save_$(RAND) || exit 0
	mkdir -p ~/.ssh/tmp
	cp -Rv ssh-config ~/.ssh/config

	echo "λ => configuring Vim..."
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

	echo "λ => installing Python PIP..."
	curl -LSs https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python3 get-pip.py --user --no-warn-script-location && rm get-pip.py

mac-specific:
	echo "λ => installing Homebrew..."
	test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

	echo "λ => installing Homebrew packages..."
	/Users/$$USER/.homebrew/bin/brew bundle

git-config:
	read -p "💡 Now let's configure git client. Enter your name: " NAME; \
	 git config --global user.name $$NAME
	read -p "💡 And Email: " EMAIL; \
	 git config --global user.email $$EMAIL
	echo && echo 🍰 The system has been successfully configured! && echo

clean: ## Remove backup configs (~/dotfiles_save_* and ~/.ssh/config_save_*)
	echo "λ => removing backup configs..."
	-rm -rf ~/dotfiles_save_*
	-rm ~/.ssh/config_save_*

uninstall: ## Remove existing dotfiles from your system (inc. ssh config)
	echo "λ => removing dotfiles..."
	-rm -rf ~/.bash_profile ~/.bashrc ~/.bashrc.local ~/.dircolors ~/.editorconfig \
			 ~/.gemrc ~/.gitconfig ~/.gitignore.global ~/.gitmessage ~/.hushlogin \
			 ~/.inputrc ~/.vimrc ~/.bash_history ~/.bash_sessions ~/.gitconfig.local \
			 ~/.lesshst ~/.ssh ~/.vim ~/.viminfo ~/.zsh_history ~/.zsh_sessions 2>/dev/null

secrets: ## Make an archive with ssh keys, aws tokens, etc
	echo "λ => archiving secrets..."
	-mkdir -p secrets && rm secrets.tar.gz
	-for i in aws grip hal kube spin ssh; do \
		cp -Rn ~/.$$i secrets/$$i 2>/dev/null; \
	done
	tar cvfz secrets.tar.gz secrets
	-rm -rf secrets

tunemymac: ## Apply recommended MacOS settings
	echo "λ => applying MacOS settings..."
	chmod +x .macos
	exec ./.macos

.PHONY: clean uninstall secrets tunemymac

help:
	@clear && head -n7 README.md | tail -n6 && echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
.SILENT:
