#!/bin/sh

nix build .#nixosConfigurations.live.config.system.build.isoImage
