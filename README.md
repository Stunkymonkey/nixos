# nixos-config [![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repository holds my NixOS configuration.
It is fully reproducible, flakes based, and position-independent, meaning there is no moving around of `configuration.nix`.

Deployment is done using [deploy-rs](https://github.com/serokell/deploy-rs), see [usage](#usage).
Secret are managed using [sops-nix](https://github.com/Mic92/sops-nix).
For formatting [pre-commit-hooks](https://github.com/cachix/pre-commit-hooks.nix) is used.

## structure

```
.
├── modules      # Own nix-options, to modularize services/hardware/...
├── machines     # Machine definitions
└── pkgs         # Own packages, which are not available in nixpkgs
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

## inspired by
- [deploy hugo with nix](https://ayats.org/blog/flake-blog/)
- [Nix config by Mic92](https://github.com/Mic92/dotfiles)
- [Nix config by ambroisie](https://github.com/ambroisie/nix-config)
- [Nix config by pborzenkov](https://github.com/pborzenkov/nix-config)
- [Nix config by nyanloutre](https://gitea.nyanlout.re/nyanloutre/nixos-config)
- [deploy-rs by disassembler](https://samleathers.com/posts/2022-02-03-my-new-network-and-deploy-rs.html)
- [pre-commit config](https://github.com/cachix/pre-commit-hooks.nix/blob/master/template/flake.nix)
