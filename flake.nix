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
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-starter";
    };
    nvchad-starter = {
      url = "git+https://git.naps.pt/naps62/nvim-config.git";
      flake = false;
    };
    foundry = {
      url = "github:shazow/foundry.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ethui pins its own nixpkgs (verified rust/tauri build) — do not follow.
    ethui.url = "github:ethui/ethui/nix";
    # hyprland pins its own nixpkgs to match its cachix cache — do not follow,
    # or it compiles from source.
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    codex-cli = {
      url = "github:sadjow/codex-cli-nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned to the tag, and pins its own nixpkgs for the same reason ethui does
    # — it is a verified Rust build. Bump deliberately, not via `flake update`.
    agent-of-empires.url = "git+https://git.naps.pt/yolo/agent-of-empires.git";
    # Semantic-diff tool rev calls via REV_SEM_BIN. NOT nixpkgs' `sem`, which is
    # the unrelated Semaphore CI cli.
    sem.url = "github:Ataraxy-Labs/sem";
    # Claude Code + Codex skills, commands, hooks and CLAUDE.md fragments.
    agent-skills.url = "git+https://git.naps.pt/yolo/agent-skills.git";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      home-manager,
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
          ];
        }
      );

      x86 = pkgsFor.x86_64-linux;

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
            inherit inputs outputs self;
          };
        };
    in
    {
      nixosConfigurations = {
        arrakis = mkNixOS "arrakis";
        konishi = mkNixOS "konishi";
        yolo = mkNixOS "yolo";
      };

      # Named "<user>@<host>" so `nh home switch` auto-detects them
      # (nh home tries "$USER@$(hostname)", not the bare hostname).
      homeConfigurations = {
        "naps62@arrakis" = mkHome "arrakis" x86;
        "naps62@konishi" = mkHome "konishi" x86;
        "naps62@yolo" = mkHome "yolo" x86;
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
