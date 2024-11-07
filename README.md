# nixos-config [![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)![CI](https://github.com/Stunkymonkey/nixos/actions/workflows/nix.yml/badge.svg)

This repository holds my NixOS configuration.
It is fully reproducible, flakes based, and position-independent, ...

used flakes:

- image generation: [nixos-generators](https://github.com/nix-community/nixos-generators)
- disk partitioning: [disko](https://github.com/nix-community/disko)
- secrets: [sops-nix](https://github.com/Mic92/sops-nix)
- deployment: [nixinate](https://github.com/MatthewCroughan/nixinate), see [usage](#usage)
- formatting: [git-hooks](https://github.com/cachix/git-hooks.nix)
- install: [nixos-anywhere](https://github.com/numtide/nixos-anywhere/)

## Structure

```text
.
├── images       # custom image generations
├── machines     # machine definitions
├── modules      # own nix-options, to modularize services/hardware/...
├── overlays     # overlays
├── pkgs         # own packages, which are not available in nixpkgs
└── profiles     # summarize module collections into single options
```

## Usage

- updating:

    ```bash
    nix flake update
    ```

- deployment/update:

    ```bash
    nix run .#<flake>
    ```

- secrets:

    ```bash
    sops ./machines/<host>/secrets.yaml
    ```

- images:

    ```bash
    nix build .#install-iso
    nix build .#aarch64-install --system aarch64-linux
    ```

- vms:

    ```bash
    nixos-rebuild build-vm --flake .#<flake>
    ```

- (re-)install:

    make sure you have ssh-root access to the machine and the ssh-key is used properly.
    (It does not matter what system is installed before.)

    1. generate config (only needed for new host)

        get `nixos-generate-config` to run via nix and execute

        ```bash
        nixos-generate-config --no-filesystems --root $(mktemp -d)
        ```

        reuse the `hardware-configuration.nix` to create a new machine with its flake.

    1. setup secrets

        1. new host

            then prepare the secrets in the following layout:

            ```bash
            # enter disk encryption key
            echo "my-super-safe-password" > /tmp/disk.key

            temp=$(mktemp -d)
            # ssh-host keys
            install -d -m755 "$temp/etc/ssh"
            ssh-keygen -o -t rsa -a 100 -N "" -b 4096 -f "$temp/etc/ssh/ssh_host_rsa_key"
            chmod 600 "$temp/etc/ssh/ssh_host_rsa_key"
            ssh-keygen -o -t ed25519 -a 100 -N "" -f "$temp/etc/ssh/ssh_host_ed25519_key"
            chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
            # initrd key
            install -d -m755 "$temp/etc/secrets/initrd"
            ssh-keygen -o -t ed25519 -a 100 -N "" -f "$temp/etc/secrets/initrd/ssh_host_ed25519_key"
            chmod 600 "$temp/etc/secrets/initrd/ssh_host_ed25519_key"
            ```

        1. existing host

            ```bash
            echo "my-super-safe-password" > /tmp/disk.key
            temp=$(mktemp -d)
            find $temp -printf '%M %p\n'
            ```

            should result in something looking like this

            ```text
            drwx------ $temp
            drwxr-xr-x $temp/etc
            drwxr-xr-x $temp/etc/ssh
            -rw------- $temp/etc/ssh/ssh_host_rsa_key
            -rw------- $temp/etc/ssh/ssh_host_ed25519_key
            -rw-r--r-- $temp/etc/ssh/ssh_host_rsa_key.pub
            -rw-r--r-- $temp/etc/ssh/ssh_host_ed25519_key.pub
            drwxr-xr-x $temp/etc/secrets
            drwxr-xr-x $temp/etc/secrets/initrd
            -rw------- $temp/etc/secrets/initrd/ssh_host_ed25519_key
            -rw-r--r-- $temp/etc/secrets/initrd/ssh_host_ed25519_key.pub
            ```

    1. execute install

        now simply install by executing (this will delete all data!):

        ```bash
        nix run github:numtide/nixos-anywhere -- \
            --disk-encryption-keys /tmp/disk.key /tmp/disk.key \
            --extra-files "$temp" \
            --flake .#<flake> \
            root@<host>
        ```

## Inspired by

- [Nix config by Mic92](https://github.com/Mic92/dotfiles)
- [Nix config by ambroisie](https://github.com/ambroisie/nix-config)
- [Nix config by pborzenkov](https://github.com/pborzenkov/nix-config)
- [Nix config by nyanloutre](https://gitea.nyanlout.re/nyanloutre/nixos-config)
- [Nix config by disassembler](https://github.com/disassembler/network)
- [git-hook config](https://github.com/cachix/git-hooks.nix/blob/master/template/flake.nix)
