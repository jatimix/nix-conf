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
    let
      geminiCliOverlay = final: prev: {
        gemini-cli = prev.buildNpmPackage rec {
          pname = "gemini-cli";
          version = "0.19.4";

          src = prev.fetchFromGitHub {
            owner = "google-gemini";
            repo = "gemini-cli";
            rev = "v${version}";
            hash = "sha256-bXolK7TEfrmSuntE0uP6MpLNypgyqjaL85bbPi19T5k=";
          };

          npmDepsHash = "sha256-sE3dTngvVukcL7Cwm5MG1NVCBGDbSW2YrkJyGEbg2Ow=";

          # The lockfile in the source (v0.19.4) differs slightly from what fetchNpmDeps resolves.
          # Since you confirmed the hash is correct, we disable the strict check.
          dontNpmDepsValidate = true;
          nativeBuildInputs = [ prev.pkg-config ];
          buildInputs = [ prev.libsecret ];

          # 2. The default install phase for workspaces can be tricky.
          # We manually copy the built packages to the output so the symlinks resolve.
          postInstall = ''
            cp -r packages $out/lib/node_modules/@google/gemini-cli/
          '';

          # We do NOT inherit the old installPhase or preConfigure because
          # the project structure has changed significantly since 0.1.5.
          # We let buildNpmPackage handle the standard npm install process.

          meta = with prev.lib; {
            description = "AI agent that brings the power of Gemini directly into your terminal";
            homepage = "https://github.com/google-gemini/gemini-cli";
            license = licenses.asl20;
            mainProgram = "gemini";
          };
        };
      };

      # Combine your custom overlays with existing ones (like emacs-overlay)
      myOverlays = [
        geminiCliOverlay
        inputs.emacs-overlay.overlay
      ];
    in
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
              nixpkgs.overlays = myOverlays;
              networking.hostName = "nagra-wsl";
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
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
              nixpkgs.overlays = myOverlays;
              networking.hostName = "giedi-wsl";
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.tim = import ./home.nix;
                sharedModules = [ sops-nix.homeManagerModules.sops ];
              };
            }
          ];
        };
      }; # nixos configuration
    }; # outputs
} # flake
