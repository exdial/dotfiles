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
		echo "✔︎ copying dotfiles... $$i"; \
		cp -Rn files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

	echo "✔︎ copying SSH config..."
	test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config_save_$(RAND) || exit 0
	mkdir -p ~/.ssh/tmp
	cp -Rv ssh-config ~/.ssh/config

	echo "✔︎ configuring Vim..."
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

mac-specific:
	echo "✔︎ installing Homebrew..."
	test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

	echo "✔︎ installing Homebrew packages..."
	/Users/$$USER/.homebrew/bin/brew bundle

git-config:
	read -p "💡 Now let's configure git client. Enter your name: " NAME; \
	 git config --global user.name $$NAME
	read -p "💡 And Email: " EMAIL; \
	 git config --global user.email $$EMAIL
	echo && echo 🍰 The system has been successfully configured! && echo

clean: ## Remove backup configs (~/dotfiles_save_* and ~/.ssh/config_save_*)
	echo "✔︎ removing backup configs..."
	-rm -rf ~/dotfiles_save_*
	-rm ~/.ssh/config_save_*

uninstall: ## Remove existing dotfiles from your system (inc. ssh config)
	echo "✔︎ removing dotfiles..."
	-rm -rf ~/.bash_profile ~/.bashrc ~/.bashrc.local ~/.dircolors ~/.editorconfig \
			 ~/.gemrc ~/.gitconfig ~/.gitignore.global ~/.gitmessage ~/.hushlogin \
			 ~/.inputrc ~/.vimrc ~/.bash_history ~/.bash_sessions ~/.gitconfig.local \
			 ~/.lesshst ~/.ssh ~/.vim ~/.viminfo ~/.zsh_history ~/.zsh_sessions 2>/dev/null

secrets: ## Make an archive with ssh keys, aws tokens, etc
	echo "✔︎ archiving secrets..."
	-mkdir -p secrets && rm secrets.tar.gz
	-for i in aws grip hal kube spin ssh gnupg; do \
		cp -Rn ~/.$$i secrets/$$i 2>/dev/null; \
	done
	tar cvfz secrets.tar.gz secrets
	-rm -rf secrets

tunemymac: ## Apply recommended MacOS settings
	echo "✔︎ applying MacOS settings..."
	chmod +x .macos
	exec ./.macos

# VM should have ubuntu-22.04.3-live-server-amd64.iso on the CD drive.
# Use following settings to create a new VM:
# Virtualization platform: VMware Fusion
# Firmware type: Legacy BIOS
# Machine name: Ubuntu.vmwarevm
# CPU: 4, RAM 8192 MB
# Display:
# - Enabled Accelerated 3D Graphics
# - Shared graphics memory: 8192 MB
# - Enabled full resolution for Retina display
# HDD:
# - Disk size of 50 GB
# - Bus type: SCSI
# - Disabled "Split into multiple files"
# Removed devices:
# - Sound card
# - Printer
# - Camera
# USB & Bluetooth
# - USB Compatibility: USB 3.1
# - Disabled "Share Bluetooth devices with Linux"

# VMADDR format: user@ipaddress
VMADDR ?= unset
VMPASS ?= unset
bootstrap: ## Bootstrap a brand new Linux VM
	# upload the sudoers config into target system
	scp vm/etc/sudoers.d/nopasswd $(VMADDR):/tmp
	# using sudo move the sudoers config to the proper location
	ssh $(VMADDR) " \
		echo $(VMPASS) | sudo -S cp /tmp/nopasswd /etc/sudoers.d/ \
	"
	# install missing packages
	ssh $(VMADDR) " \
		sudo apt-get update && \
		sudo apt-get -y install dialog && \
		sudo apt-get -y upgrade && \
		sudo apt-get install locales && \
		sudo locale-gen --purge en_US.UTF-8 && \
		echo LANG=en_US.UTF-8 | sudo tee -a /etc/default/locale && \
		sudo apt-get -y install open-vm-tools open-vm-tools-desktop \
			xserver-xorg x11-xserver-utils lightdm lightdm-gtk-greeter \
			vim i3 kitty git make bash-completion htop \
			fonts-firacode fonts-emojione --no-install-recommends \
	"
	# configure display manager
	ssh $(VMADDR) "echo GDK_SCALE=2 | sudo tee -a /etc/environment"
	scp vm/etc/lightdm/lightdm.conf.d/50-display-setup.conf $(VMADDR):/tmp
	scp vm/usr/share/lightdm_display_setup.sh $(VMADDR):/tmp
	scp vm/usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_ubuntu.conf $(VMADDR):/tmp
	scp vm/home/$$USER/.Xresources $(VMADDR):/home/$$USER/.Xresources
	ssh $(VMADDR) " \
		sudo mv /tmp/50-display-setup.conf /etc/lightdm/lightdm.conf.d/ && \
		sudo mv /tmp/lightdm_display_setup.sh /usr/share/ && \
		sudo chown lightdm:lightdm /usr/share/lightdm_display_setup.sh && \
		sudo chmod +x /usr/share/lightdm_display_setup.sh && \
		sudo mv /tmp/01_ubuntu.conf /usr/share/lightdm/lightdm-gtk-greeter.conf.d/ \
	"
	echo "Now reboot the VM to apply the new settings"

.PHONY: clean uninstall secrets tunemymac

help:
	@clear && head -n7 README.md | tail -n6 && echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
.SILENT:
