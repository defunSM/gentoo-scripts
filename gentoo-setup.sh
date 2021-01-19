#!/usr/bin/env bash
set -euo pipefail

# Majority of commands taken directly from https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation

function fast_gentoo_chroot {
    mount --types proc /proc /mnt/gentoo/proc
    mount --rbind /sys /mnt/gentoo/sys
    mount --make-rslave /mnt/gentoo/sys
    mount --rbind /dev /mnt/gentoo/dev
    mount --make-rslave /mnt/gentoo/dev

    test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
    mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
    chmod 1777 /dev/shm

    chroot /mnt/gentoo /bin/bash
    source /etc/profile
    export PS1="(chroot) ${PS1}"
}

fast_gentoo_chroot
