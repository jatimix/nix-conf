{ config, pkgs, lib, osConfig, ... }:

let
  hostname = osConfig.networking.hostName;
  isWork = hostname == "nagra-wsl";
  username = if isWork then "bineau" else "tim";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = if isWork then "Timothee Bineau" else "Tim";
    userEmail = if isWork then "REDACTED_EMAIL" else "jatimix@gmail.com";
    autocrlf = "input";
    rebase = true;
    defaultBranch = "master";
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-git;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      ll = "lsd -la";
      la = "ls -la";
      tree ="lsd --tree";
    };
    bindings = {
      "\ep" = "up-or-search";
      "\en" = "down-or-search";
    };
    interactiveShellInit = ''
      starship init fish | source
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  home.packages = with pkgs; [
    lsd
    starship
  ];
}
