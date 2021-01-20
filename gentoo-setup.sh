#!/usr/bin/env bash
set -euo pipefail
source ./ask.sh

# Majority of commands taken directly from https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation

function partition_drive {
    lsblk
    echo "Enter the block device for partitioning: "
    read blockdevice
    sudo -u root cfdisk $blockdevice
}

function mount_and_install {
    lsblk
    echo "Select root partition to mount to /mnt/gentoo: "
    read root_partition
    mount $root_partition /mnt/gentoo
    if ask "Do you wish to install stage 3 tarbell (systemd)?" N; then
        (cd /mnt/gentoo; wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210117T214503Z/stage3-amd64-systemd-20210117T214503Z.tar.xz)
        echo "Unpacking tarbell..."
        (cd /mnt/gentoo; tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner)
    else
        echo "Skipping installation of stage 3 tarbell..."
    fi
}

function fast_gentoo_chroot {
    mount --types proc /proc /mnt/gentoo/proc && mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys && mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev && test -L /dev/shm && rm /dev/shm && mkdir /dev/shm && mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm && chmod 1777 /dev/shm && chroot /mnt/gentoo /bin/bash && source /etc/profile && export PS1="(chroot) ${PS1}"
}

# partitioning, mounting, installing, and chrooting

if ask "Do you want to partition?" N; then
    partition_drive
else
    echo "Skipping partitioning..."
fi

if ask "Continue to mount and install?" N; then
    mount_and_install
else
    echo "Skipping mount and install..."
fi

if ask "Do you want to chroot now?" N; then
    fast_gentoo_chroot
else
    echo "Ignoring chroot..."
fi
