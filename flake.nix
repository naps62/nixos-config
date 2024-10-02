{
  description = "naps62's nix config";

  nixConfig = { experimental-features = [ "nix-command" "flakes" ]; };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs:
    let
      inherit (self) outputs;
      pkgs = import nixpkgs { };
      x86 = nixpkgs.legacyPackages.x86_64-linux;
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      forEachPkg = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
      mkNixOS = extraModules:
        nixpkgs.lib.nixosSystem {
          inherit extraModules;
          specialArgs = { inherit inputs outputs; };
          modules = extraModules ++ [ catppuccin.nixosModules.catppuccin ];
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
        "naps62@laptop" = mkHome [ ./home-manager/laptop ] x86;
        "naps62@arrakis" = mkHome [ ./home-manager/arrakis ] x86;
        "naps62@desktop" = mkHome [ ./home-manager/desktop ] x86;
        "naps62@pi" = mkHome [ ./home-manager/pi ] x86;
        "naps62@test" = mkHome [ ./home-manager/test ] x86;
      };

      devShells = forEachPkg (pkgs: import ./shell.nix { inherit pkgs; });
    };
}
