# Ansible Silverblue Kiosk
Creates a kiosk that displays a URL full screen

## Bootstrap new system
```bash
bash -c "$(wget -O- tms-kiosk.borcean.xyz)"
```

## Install OS and run provision with Kickstart
```bash
dnf in -y lorax
curl https://raw.githubusercontent.com/borcean/ansible-silverblue-kiosk/refs/heads/main/kickstart.cfg -o kickstart.cfg
mkksiso --ks kickstart.cfg Fedora-Silverblue-ostree-x86_64-42-1.1.iso kiosk.iso
dd if=kiosk.iso of=/dev/INSTALL_DISK bs=4M status=progress oflag=sync; eject /dev/INSTALL_DISK
```
