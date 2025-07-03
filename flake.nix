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
    nix-colors.url = "github:misterio77/nix-colors";
    nixvim.url = "github:nix-community/nixvim";
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
      url = "github:shazow/foundry.nix";
    };
    utils.url = "github:numtide/flake-utils";
    hardware.url = "github:NixOS/nixos-hardware/master";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      home-manager,
      utils,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      pkgsFor = nixpkgs.lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
          overlays = [
            inputs.foundry.overlay
            inputs.hyprpanel.overlay
            # inputs.neovim-nightly-overlay.overlays.default
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
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };

      mkHome =
        name: pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/${name}
          ];
          extraSpecialArgs = {
            inherit inputs outputs;
          };
        };
    in
    {
      nixosConfigurations = {
        arrakis = mkNixOS "arrakis";
        trantor = mkNixOS "trantor";
        desktop = mkNixOS "desktop";
        pi = mkNixOS "pi";
        live = mkNixOS "live";
      };

      homeConfigurations = {
        arrakis = mkHome "arrakis" x86;
        trantor = mkHome "trantor" x86;
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
