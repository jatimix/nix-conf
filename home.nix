{ config, pkgs, lib, osConfig, inputs, ... }:

let
  hostname = osConfig.networking.hostName;
  isWork = hostname == "nagra-wsl";
  username = if isWork then "bineau" else "tim";
in
{
  imports = [
    inputs.nix-doom-emacs-unstraightened.homeModule
    (import ./secrets.nix { inherit config lib pkgs isWork; })
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = lib.mkIf (!isWork) {
        name = "Tim";
        email = "jatimix@gmail.com";
      };
      pull.rebase = "true";
      core.autocrlf = "input";
      init.defaultBranch = "master";
    };
    includes = lib.optional isWork {
      path = "~/.config/git/work.inc";
    };
    ignores = [
      ".DS_Store"
      ".idea"
      "*.log"
      "tmp/"
      ".dir-locals.el"
      "*.tern-port"
      "node_modules/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      "*.tsbuildinfo"
      ".npm"
      ".eslintcache"
      ".log"
      "__build"
      "__build/*"
      "build/"
    ];
  };

  programs.emacs = {
    enable = true;
    #   package = pkgs.emacs-git;
    package = pkgs.emacs-git.overrideAttrs (old: {
      src = inputs.emacs-igc-src;
      buildInputs = old.buildInputs ++ [ pkgs.mps ];
      configureFlags = old.configureFlags ++ [
        "--with-mps=yes"
      ];
    });
    extraPackages = (epkgs: [ epkgs.treesit-grammars.with-all-grammars ]);
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;  # or e.g. `./doom.d` for a local configuration
    doomLocalDir = "/home/${username}/.doom.d";
    provideEmacs = false; # comes from git
    extraPackages = epkgs:
      with epkgs; [
        vterm
        sqlite3
        emacsql
        treesit-grammars.with-all-grammars
        mu4e
      ];
  };

  home.sessionVariables = {
    EDITOR = "doom-emacs";
    DEFAULT_BROWSER = "firefox";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      tree ="lsd --tree";
      la = lib.mkForce "lsd -la";
      top = "htop";
    };
    shellInit = ''
      # emacs vterm directory tracking... to-check
      function track_directories --on-event fish_postexec; printf '\e]51;A'(pwd)'\e\\'; end
    '';
    interactiveShellInit = ''
      # rebind M-p and M-n to behave like Zsh  instead of adding "&| less"
      # at the end of every command
      bind \ep up-or-search
      bind \en down-or-search
      bind alt-backspace 'backward-kill-word'
      set fish_greeting
      set -gx READ_REG_TOKEN "$(cat ${config.sops.secrets.read_reg_token.path})"
    '';
    plugins = with pkgs.fishPlugins; [ {name = "grc"; src = grc.src;} ];
  };

  programs.docker-cli = {
    enable = true;
    settings = {
      "detachKeys" = "ctrl-e,e";
    };
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
    sops
    grc
    lsd
    starship
    ripgrep
    fd
    nixfmt
    p7zip
    dockerfile-language-server
    htop
    direnv
    wild
    # This is specific for wsl
    # If we want to switch to a non wsl thinggy it needs to be removed
    (pkgs.writeShellScriptBin "firefox" ''
       exec "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" "$@"
      '')
  ] ++ lib.optionals isWork [
    awscli2
  ];
}
