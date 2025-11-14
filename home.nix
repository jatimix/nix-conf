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

  programs.fish = {
    enable = true;
    shellAliases = {
      tree ="lsd --tree";
    };
    interactiveShellInit = ''
      # rebind M-p and M-n to behave like Zsh  instead of adding "&| less"
      # at the end of every command
      bind \ep up-or-search
      bind \en down-or-search
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
  };

  home.packages = with pkgs; [
    lsd
    starship
  ];
}
