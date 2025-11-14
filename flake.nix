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
    doom-config.url = "github:jatimix/doom-conf";
    doom-config.flake = false;
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      nagra-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
            networking.hostName = "nagra-wsl";
            home-manager = {
              extraSpecialArgs = { inherit inputs; };  # <- ADD THIS
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
          inputs.nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          inputs.nix-doom-emacs-unstraightened.homeModule
          {
            nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
            networking.hostName = "giedi-wsl";
            home-manager = {
              extraSpecialArgs = { inherit inputs; };  # <- ADD THIS
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
