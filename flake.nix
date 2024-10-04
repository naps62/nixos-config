{
  description = "naps62's nix config";

  nixConfig = { experimental-features = [ "nix-command" "flakes" ]; };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland.git";
      ref = "refs/tags/v0.43.0";
      submodules = true;
    };
    nix-colors.url = "github:misterio77/nix-colors";
    nixvim.url = "github:nix-community/nixvim";
    catppuccin.url = "github:catppuccin/nix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-starter";
    };
    nvchad-starter = {
      url = "github:naps62/nvchad-starter";
      flake = false;
    };
    foundry = { url = "github:shazow/foundry.nix/monthly"; };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, systems, nixpkgs, home-manager, utils, catppuccin, foundry
    , ... }@inputs:
    let
      inherit (self) outputs;
      pkgsFor = nixpkgs.lib.genAttrs (import systems) (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
      x86 = nixpkgs.legacyPackages.x86_64-linux;
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      forEachPkg = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
      mkNixOS = extraModules:
        nixpkgs.lib.nixosSystem {
          inherit extraModules;
          modules = extraModules ++ [ catppuccin.nixosModules.catppuccin ];
          specialArgs = { inherit inputs outputs; };
        };

      mkHome = modules: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit modules pkgs;
          extraSpecialArgs = { inherit inputs outputs catppuccin; };
        };
    in {
      nixosConfigurations = {
        laptop = mkNixOS [ ./hosts/laptop ];
        arrakis = mkNixOS [ ./hosts/arrakis ];
        desktop = mkNixOS [ ./hosts/desktop ];
        test = mkNixOS [ ./hosts/test ];
        pi = mkNixOS [ ./hosts/pi ];
        live = mkNixOS [ ./hosts/live ];
      };

      homeConfigurations = {
        laptop = mkHome [ ./home-manager/laptop ] pkgsFor.x86_64-linux;
        arrakis = mkHome [ ./home-manager/arrakis ] pkgsFor.x86_64-linux;
        desktop = mkHome [ ./home-manager/desktop ] pkgsFor.x86_64-linux;
        pi = mkHome [ ./home-manager/pi ] pkgsFor.aarch64-linux;
        test = mkHome [ ./home-manager/test ] pkgsFor.x86_64-linux;
      };

      devShells = forEachPkg (pkgs: import ./shell.nix { inherit pkgs; });
    };
}
