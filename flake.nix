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
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, emacs-overlay }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      nagra-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ emacs-overlay.overlay ];
            networking.hostName = "nagra-wsl";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.bineau = import ./home.nix;
            };
          }
        ];
      };

      home-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ emacs-overlay.overlay ];
            networking.hostName = "giedi-wsl";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tim = import ./home.nix;
            };
          }
        ];
      };
    };
  };
}
