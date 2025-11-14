{ config, pkgs, lib, osConfig, inputs,  ... }:

let
  hostname = osConfig.networking.hostName;
  isWork = hostname == "nagra-wsl";
  username = if isWork then "bineau" else "tim";
in
{
  imports = [
    inputs.nix-doom-emacs-unstraightened.homeModule
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = if isWork then "Timothee Bineau" else "Tim";
      user.email = if isWork then "REDACTED_EMAIL" else "jatimix@gmail.com";
      pull.rebase = "true";
      core.autocrlf = "input";
      init.defaultBranch = "master";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-git;
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;  # or e.g. `./doom.d` for a local configuration
    provideEmacs = false; # comes from git
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      tree ="lsd --tree";
      la = lib.mkForce "lsd -la";
    };
    shellInit = ''
      function track_directories --on-event fish_postexec; printf '\e]51;A'(pwd)'\e\\'; end
    '';
    interactiveShellInit = ''
      # rebind M-p and M-n to behave like Zsh  instead of adding "&| less"
      # at the end of every command
      bind \ep up-or-search
      bind \en down-or-search
      set fish_greeting
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
    };
  };

  programs.lsd = {
    enable = true;
  };

  home.packages = with pkgs; [
    lsd
    starship
  ];
}
