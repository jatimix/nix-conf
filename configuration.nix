{ config, lib, pkgs, ... }:

let
  isWork = config.networking.hostName == "nagra-wsl";
  username = if isWork then "bineau" else "tim";
in
{
  wsl = {
    enable = true;
    defaultUser = username;
    interop.includePath = false; # remove windows PATH
    wslConf.user.default = username; # start WSL as this user
    #useWindowsDriver = true;
  };

  hardware.graphics.enable = !isWork;
  hardware.nvidia.datacenter.enable = !isWork;
  hardware.nvidia-container-toolkit.enable = !isWork;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = !isWork;

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" username ]; # Allow this user to modify and access nix store
  };

  # Allow to run UV and other stuff linked on normal linux
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      stdenv.cc.cc
    ];
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.symbols-only
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      userland-proxy = false;
      experimental = true;
      ipv6 = true;
      fixed-cidr-v6 = "fd00::/80";
    };
  };

  programs = {
    fish.enable = true;
    ssh.startAgent = true;
  };

  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    killall
    git
    wget
    curl
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
