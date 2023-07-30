# nixos-config [![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)![CI](https://github.com/Stunkymonkey/nixos/actions/workflows/nix.yml/badge.svg)

This repository holds my NixOS configuration.
It is fully reproducible, flakes based, and position-independent, ...

used flakes:

- image generation: [nixos-generators](https://github.com/nix-community/nixos-generators)
- disk formatting: [disko](https://github.com/nix-community/disko)
- secrets: [sops-nix](https://github.com/Mic92/sops-nix)
- deployment: [deploy-rs](https://github.com/serokell/deploy-rs), see [usage](#usage)
- formatting: [pre-commit-hooks](https://github.com/cachix/pre-commit-hooks.nix)

## structure

```text
.
├── images       # custom image generations
├── machines     # machine definitions
├── modules      # own nix-options, to modularize services/hardware/...
├── overlays     # overlays
├── pkgs         # own packages, which are not available in nixpkgs
└── profiles     # summarize module collections into single options
```

## usage

updating:

```bash
nix flake update
```

deployment:

```bash
deploy .#myHost
```

secrets:

```bash
sops ./machines/myHost/secrets.yaml
```

images:

```bash
nix build .#install-iso
nix build .#aarch64-install --system aarch64-linux
```

## inspired by

- [Nix config by Mic92](https://github.com/Mic92/dotfiles)
- [Nix config by ambroisie](https://github.com/ambroisie/nix-config)
- [Nix config by pborzenkov](https://github.com/pborzenkov/nix-config)
- [Nix config by nyanloutre](https://gitea.nyanlout.re/nyanloutre/nixos-config)
- [deploy-rs by disassembler](https://samleathers.com/posts/2022-02-03-my-new-network-and-deploy-rs.html)
- [pre-commit config](https://github.com/cachix/pre-commit-hooks.nix/blob/master/template/flake.nix)
