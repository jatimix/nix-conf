{
  description = "WSL configurations for work and home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    doom-config = {
      url = "github:jatimix/doom-conf";
      flake = false;
    };
    emacs-igc-src = {
      url = "github:emacs-mirror/emacs/feature/igc";
      flake = false;
    };
    wild-linker = {
      url = "github:davidlattimore/wild";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    {
      nixosConfigurations = {
        nagra-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = with inputs; [
            sops-nix.nixosModules.sops
            nixos-wsl.nixosModules.wsl
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
              networking.hostName = "nagra-wsl";
              home-manager = {
                extraSpecialArgs = { inherit inputs; }; # <- ADD THIS
                useGlobalPkgs = true;
                useUserPackages = true;
                users.bineau = import ./home.nix;
                sharedModules = [ sops-nix.homeManagerModules.sops ];
              };
            }
          ];
        };

        home-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = with inputs; [
            nixos-wsl.nixosModules.wsl
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
              networking.hostName = "giedi-wsl";
              home-manager = {
                extraSpecialArgs = { inherit inputs; }; # <- ADD THIS
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tim = import ./home.nix;
                sharedModules = [ sops-nix.homeManagerModules.sops ];
              };
            }
          ];
        };
      }; # nixos configuration

      # Development shell for direnv and nixd
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            nixd
          ];

          shellHook = ''
            echo "Nix development environment loaded"
            echo "nixd available for Emacs LSP"
          '';
        };

    }; # outputs
} # flake
