.SILENT:
.DEFAULT_GOAL := help

USER := $(shell id -un)
GROUP := $(shell id -gn)
OS := $(shell uname)

ifeq ($(OS), Linux)
	PLATFORM = linux
else ifeq ($(OS), Darwin)
	PLATFORM = darwin
else
	PLATFORM = unsupported
endif

all: $(PLATFORM) ## Install dotfiles, packages and extra
install: dotfiles ## Install dotfiles only

linux: dotfiles gitconfig bye

darwin: dotfiles homebrew gitcongig bye

unsupported:
	printf "❌ Unsupported platform :(\nOnly Mac 🍏 and Linux 🐧 are supported\n"

logo:
	clear
	echo
	head -n7 README.md | tail -n6
	echo

bye:
	printf "\n🍰 The system has been successfully configured.\n\n"

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[31m%-20s\033[0m %s\n", $$1, $$2}'

dotfiles: logo
	find files -name .DS_Store -delete &>/dev/null
	for i in $$(find files -maxdepth 1 -type f -exec basename {} \;); do \
		echo "✔︎ copying dotfiles... $$i"; \
		cp -n files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

	echo "✔︎ configuring Vim..."
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	if [ ! -f ~/.vim/autoload/pathogen.vim ]; then \
		curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim; \
	fi

	echo "✔︎ copying SSH client configuration..."
	mkdir -p ~/.ssh
	-cp -n files/ssh/config ~/.ssh/config

	echo "✔︎ copying WezTerm configuration..."
	mkdir -p ~/.config/wezterm
	if [ ! -d ~/.config/wezterm ]; then \
		cp -R files/config/wezterm ~/.config; \
	fi

	echo "✔︎ copying StarShip configuration..."
	mkdir -p ~/.config
	-cp -n files/config/starship.toml ~/.config/starship.toml

	echo "✔︎ copying Zed configuration..."
	mkdir -p ~/.config/zed
	if [ ! -d ~/.config/zed ]; then \
		cp -R files/config/zed ~/.config; \
	fi

	echo "✔︎ copying MTMR (My TouchBar My rules) configuration..."
	mkdir -p ~/"Library/Application Support/MTMR"
	-cp -n "files/Library/Application Support/MTMR/items.json" ~/"Library/Application Support/MTMR/items.json"

homebrew:
	echo "✔︎ installing Homebrew..."
	if [ ! -d ~/.homebrew ]; then \
		mkdir ~/.homebrew \
		curl -LSs https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.homebrew \
	fi

	echo "✔︎ installing Homebrew packages..."
	#/Users/$$USER/.homebrew/bin/brew bundle

gitconfig:
	read -p "💡 Let's configure git client. Name: " NAME; \
	 git config --global user.name $$NAME
	read -p "💡 Email: " EMAIL; \
	 git config --global user.email $$EMAIL

secrets: ## Make an archive with keys, tokens, etc...
	echo "✔︎ archiving secrets..."
	-mkdir -p secrets
	-gpg --export-secret-keys --armor > secrets/gpg-private.key
	-gpg --export --armor > secrets/gpg-public.key
	-for i in aws docker grip hal kube spin ssh bashrc.local; do \
		cp -Rn ~/.$$i secrets/$$i 2>/dev/null; \
	done
	tar cvfz secrets.tar.gz secrets
	-rm -rf secrets
	printf "\n🔐 secrets.tar.gz has been created\n\n"


# The VM should have Debian ISO on the CD drive.
# Set the password of the root user to "root".
# Make sure `PermitRootLogin` is enabled in /etc/sshd/sshd_config.
# Restart sshd after changing the configuration.
#
# Use following settings to create a VM:
# 	Virtualization platform: VMware Fusion
#		Firmware type: UEFI
#   CPU: 4, RAM 8192 MB
#   Display:
#   - Enabled Accelerated 3D Graphics
#   - Shared graphics memory: 8192 MB
#   - Enabled full resolution for Retina display
#   HDD:
#   - Disk size of 50 GB
#   - Bus type: SCSI
#   - Disabled "Split into multiple files"
#   Remove followind devices:
#   - Sound card
#   - Printer
#   - Camera
#   - USB

VMADDR ?= 192.168.71.135
VMUSER ?= exdial

# SSH options that are used
SSH_OPTS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# TODO: Define GRUB
# "ipv6.disable=1 mitigations=off nowatchdog systemd.show_status=true"
#
vminit: ## Bootstrap a brand new Linux VM
	ssh-copy-id -f root@$(VMADDR)
	scp extras/vm/etc/sudoers.d/nopasswd root@$(VMADDR):/tmp
	ssh root@$(VMADDR) "apt-get update && apt-get -y install dialog && apt-get -y upgrade && \
		apt-get -y install sudo vim make i3 kitty git htop bash-completion \
		  xserver-xorg xserver-xorg-video-vmware x11-xserver-utils x11-utils \
			mesa-utils lightdm lightdm-gtk-greeter \
			open-vm-tools open-vm-tools-desktop fonts-firacode --no-install-recommends && \
		mkdir -m 0700 -p /home/$(VMUSER)/.ssh && \
		mv  /root/.ssh/authorized_keys /home/$(VMUSER)/.ssh/ && \
		chown -R $(VMUSER):$(VMUSER) /home/$(VMUSER) && \
		usermod -aG sudo $(VMUSER) && \
		mv /tmp/nopasswd /etc/sudoers.d/"
	# configure display manager
	ssh $(VMUSER)@$(VMADDR) "echo GDK_SCALE=2 | sudo tee -a /etc/environment"
	scp extras/vm/etc/lightdm/lightdm.conf.d/50-display-setup.conf $(VMUSER)@$(VMADDR):/tmp
	scp extras/vm/usr/share/lightdm_display_setup.sh $(VMUSER)@$(VMADDR):/tmp
	scp extras/vm/usr/share/lightdm/lightdm-gtk-greeter.conf.d/99_custom.conf $(VMUSER)@$(VMADDR):/tmp
	scp extras/vm/home/user/.Xresources $(VMUSER)@$(VMADDR):/home/$(VMUSER)/.Xresources
	ssh $(VMUSER)@$(VMADDR) "\
		sudo mkdir -p /etc/lightdm/lightdm.conf.d && \
		sudo mv /tmp/50-display-setup.conf /etc/lightdm/lightdm.conf.d/ && \
		sudo mv /tmp/lightdm_display_setup.sh /usr/share/ && \
		sudo chown lightdm:lightdm /usr/share/lightdm_display_setup.sh && \
		sudo chmod +x /usr/share/lightdm_display_setup.sh && \
		sudo mv /tmp/99_custom.conf /usr/share/lightdm/lightdm-gtk-greeter.conf.d/ && \
		sudo reboot"
