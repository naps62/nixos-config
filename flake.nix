{
  description = "naps62's nix config";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

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
    foundry = {
      url = "github:shazow/foundry.nix/monthly";
    };
    utils.url = "github:numtide/flake-utils";
    hardware.url = "github:NixOS/nixos-hardware/master";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      home-manager,
      utils,
      catppuccin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      pkgsFor = nixpkgs.lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.foundry.overlay
          ];
        }
      );

      x86 = pkgsFor.x86_64-linux;
      aarch64 = pkgsFor.aarch64-linux;

      mkNixOS =
        name:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${name}
            catppuccin.nixosModules.catppuccin
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };

      mkHome =
        name: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/${name} ];
          extraSpecialArgs = {
            inherit inputs outputs catppuccin;
          };
        };
    in
    {
      nixosConfigurations = {
        laptop = mkNixOS "laptop";
        arrakis = mkNixOS "arrakis";
        desktop = mkNixOS "desktop";
        pi = mkNixOS "pi";
        live = mkNixOS "live";
      };

      homeConfigurations = {
        laptop = mkHome "laptop" x86;
        arrakis = mkHome "arrakis" x86;
        desktop = mkHome "desktop" x86;
        pi = mkHome "pi" aarch64;
      };

      devShells =
        let
          forEachSystem = nixpkgs.lib.genAttrs [
            "x86_64-linux"
            "aarch64-linux"
          ];
          forEachPkg = f: forEachSystem (sys: f pkgsFor.${sys});
        in
        forEachPkg (pkgs: import ./shell.nix { inherit pkgs; });
    };
}
# Note: Can also be referenced withou
