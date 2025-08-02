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

darwin: dotfiles homebrew gitconfig bye

unsupported:
	printf "❌ Unsupported platform :(\nOnly Intel Mac 🍏 and Linux 🐧 are supported\n"
	exit 1

logo:
	clear && echo && sed -n '2,7p' README.md && echo

bye:
	printf "\n🍰 The system has been successfully configured.\n\n"

help: logo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[31m%-20s\033[0m %s\n", $$1, $$2}'

dotfiles: logo
	find files -name .DS_Store -delete &>/dev/null
	for i in $$(find files -maxdepth 1 -type f -exec basename {} \;); do \
		echo "✔︎ copying dotfiles... $$i"; \
		cp -f files/$$i ~/.$$i; \
		chown $$USER:$$GROUP ~/.$$i; \
		chmod 0644 ~/.$$i; \
	done

	echo "✔︎ configuring Vim..."
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	if [ ! -f ~/.vim/autoload/pathogen.vim ]; then \
		curl -LSkso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim; \
	fi

	echo "✔︎ copying WezTerm configuration..."
	mkdir -p ~/.config/wezterm
	cp -R files/config/wezterm ~/.config

	echo "✔︎ copying StarShip configuration..."
	mkdir -p ~/.config
	cp -f files/config/starship.toml ~/.config/starship.toml

	echo "✔︎ copying Zed configuration..."
	mkdir -p ~/.config/zed
	cp -R files/config/zed ~/.config

	echo "✔︎ copying MTMR (My TouchBar My rules) configuration..."
	mkdir -p ~/"Library/Application Support/MTMR"
	cp -f "files/Library/Application Support/MTMR/items.json" ~/"Library/Application Support/MTMR/items.json"

homebrew:
	echo "✔︎ installing Homebrew..."
	if [ ! -d "/usr/local/Homebrew" ]; then \
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo "✔︎ installing Homebrew packages..."
	/usr/local/bin/brew bundle

gitconfig:
	@read -p "💡 Git name: " NAME && \
	read -p "📧 Email: " EMAIL && \
	git config --global user.name "$$NAME" && \
	git config --global user.email "$$EMAIL"

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

# The VM should have Ubuntu Noble ISO on the CD drive.
# Set the password of the root user to "root".
# Make sure `PermitRootLogin` is enabled in /etc/sshd/sshd_config.
# Restart sshd after changing the configuration.
#
# Use following settings to create a VM:
# 	Virtualization platform: VMware Fusion
#	Firmware type: UEFI
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

VMADDR ?=
VMUSER ?=

# SSH options that are used
SSH_OPTS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519

vminit: ## Bootstrap a brand new Linux VM
	@test -n "$(VMADDR)" || (echo "❌ VMADDR is not set"; exit 1)
	@test -n "$(VMUSER)" || (echo "❌ VMUSER is not set"; exit 1)

	ssh-copy-id -f root@$(VMADDR)
	scp $(SSH_OPTS) extras/vm/etc/sudoers.d/nopasswd root@$(VMADDR):/etc/sudoers.d/nopasswd
	ssh $(SSH_OPTS) root@$(VMADDR) "mkdir -p /etc/systemd/system/getty@tty1.service.d"
	scp $(SSH_OPTS) extras/vm/etc/systemd/system/getty/override.conf root@$(VMADDR):/etc/systemd/system/getty@tty1.service.d/override.conf
	ssh $(SSH_OPTS) root@$(VMADDR) "systemctl stop snapd ModemManager \
		packagekit multipath-tools udisks2 unattended-upgrades &>/dev/null && \
		apt-get -y purge snapd cloud-init modemmanager packagekit multipath-tools udisks2 \
			unattended-upgrades apport ubuntu-pro* update-notifier-common xdg-user-dirs \
			lxd-agent-loader lxd-installer byobu fonts-dejavu-* fonts-ubuntu* && \
		rm -rf ~/snap /snap /var/snap /var/lib/snapd /etc/cloud/ /var/lib/cloud/ && \
		apt-get -y autoremove --purge && apt-get -y clean && \
		apt-get update && apt-get -y upgrade && \
		apt-get -y install sudo make curl vim git htop bash-completion \
			xserver-xorg-core xserver-xorg x11-xserver-utils xserver-xorg-video-vmware \
			xinit i3-wm alacritty fonts-firacode open-vm-tools open-vm-tools-desktop && \
		mkdir -m 0700 -p /home/$(VMUSER)/.ssh && \
		mv  /root/.ssh/authorized_keys /home/$(VMUSER)/.ssh/ && \
		chown -R $(VMUSER):$(VMUSER) /home/$(VMUSER) && \
		usermod -aG sudo $(VMUSER) && \
		sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"quiet loglevel=1 nowatchdog ipv6.disable=1 mitigations=off plymouth.enable=0 vt.global_cursor_default=0 nohz=on\"/g' /etc/default/grub && \
		sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=1/g' /etc/default/grub && \
		update-grub"
	scp $(SSH_OPTS) extras/vm/home/user/.xinitrc $(VMUSER)@$(VMADDR):/home/$(VMUSER)/.xinitrc
	scp $(SSH_OPTS) extras/vm/home/user/.Xresources $(VMUSER)@$(VMADDR):/home/$(VMUSER)/.Xresources
	scp $(SSH_OPTS) extras/vm/home/user/.bash_profile $(VMUSER)@$(VMADDR):/home/$(VMUSER)/.bash_profile
	scp $(SSH_OPTS) -r extras/vm/home/user/.config $(VMUSER)@$(VMADDR):/home/$(VMUSER)/.config
	ssh $(SSH_OPTS) $(VMUSER)@$(VMADDR) "sudo reboot"
