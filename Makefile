USER := $(shell id -un)
GROUP := $(shell id -gn)
UNAME :=$(shell uname)
RAND := $(shell /bin/sh -c "echo $$RANDOM")

export USER GROUP UNAME RAND

ifeq ($(UNAME), Linux)
	TARGET = linux
else ifeq ($(UNAME), Darwin)
	TARGET = darwin
else
	TARGET = unsupported-platform
endif

all: $(TARGET) ## Install dotfiles, packages and extra
install: dotfiles ## Install dotfiles only
linux: dotfiles gitconfig bye
darwin: dotfiles homebrew gitconfig bye

unsupported-platform:
	echo ❌ Unsupported platform!
	echo Only Mac 🍏 and Linux 🐧 are supported platforms

logo:
	clear
	echo
	head -n7 README.md | tail -n6
	echo

dotfiles: logo
	find files -name .DS_Store -delete
	for i in $$(find files -type f -d 1 -exec basename {} \; | grep -v .local); do \
		test -f ~/.$$i && mkdir -p ~/dotfiles_save_$(RAND) && mv ~/.$$i ~/dotfiles_save_$(RAND); \
		echo "✔︎ copying dotfiles... $$i"; \
		cp -n files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

	# echo "✔︎ copying WezTerm configuration..."
	mkdir -p ~/.config/wezterm
	test -f ~/.config/wezterm/wezterm.lua && mv ~/.config/wezterm/wezterm.lua ~/dotfiles_save_$(RAND)
	cp -Rn files/config/wezterm ~/.config/wezterm

	# echo "✔︎ copying StarShip configuration..."
	mkdir -p ~/.config
	test -f ~/.config/starship.toml && mv ~/.config/starship.toml ~/dotfiles_save_$(RAND)
	cp -n files/config/starship.toml ~/.config/starship.toml

	echo "✔︎ copying SSH client configuration..."
	mkdir -p ~/.ssh
	test -f ~/.ssh/config && mv ~/.ssh/config ~/.ssh/config_save_$(RAND)
	cp -n files/ssh/config ~/.ssh/config

	echo "✔︎ configuring Vim..."
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

homebrew:
	echo "✔︎ installing Homebrew..."
	test -d ~/.homebrew && echo "~/.homebrew exists" && exit 1 || mkdir ~/.homebrew
	curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew

	echo "✔︎ installing Homebrew packages..."
	/Users/$$USER/.homebrew/bin/brew bundle

gitconfig:
	read -p "💡 Let's configure git client. Name: " NAME; \
	 git config --global user.name $$NAME
	read -p "💡 Email: " EMAIL; \
	 git config --global user.email $$EMAIL

bye:
	echo && echo 🍰 The system has been successfully configured! && echo

clean: ## Remove backup files (.dotfiles_save_)
	echo "✔︎ removing backup copies of configuration files..."
	-rm -rf ~/dotfiles_save_*
	-rm ~/.ssh/config_save_*

secrets: ## Make an archive with ssh keys, aws tokens, etc...
	echo "✔︎ archiving secrets..."
	-mkdir -p secrets
	-gpg --export-secret-keys --armor > secrets/gpg-private.key
	-gpg --export --armor > secrets/gpg-public.key
	-for i in aws docker grip hal kube spin ssh; do \
		cp -Rn ~/.$$i secrets/$$i 2>/dev/null; \
	done
	tar cvfz secrets.tar.gz secrets
	-rm -rf secrets
	echo && echo "🔐 secrets.tar.gz has been created" && echo

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

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
.SILENT:
