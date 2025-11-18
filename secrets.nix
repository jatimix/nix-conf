{ config, lib, pkgs, isWork, ... }:

let
  token = if isWork then "token_1" else "token_2";
in
{
  # sops = lib.mkIf isWork {
  #   age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  #   defaultSopsFile = ./secrets/work.yaml;
  #   defaultSopsFormat = "yaml";  # <- Add this line
  #   secrets.work_gitconfig = {
  #     path = "${config.home.homeDirectory}/.config/git/work.inc";
  #     format = "yaml";  # <- Add this line
  #   };
  # };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  sops.secrets.work_gitconfig = {
    sopsFile = ./secrets/work.yaml;
    format = "yaml";
  };

  sops.secrets.secrets_file = {
    sopsFile = ./secrets/secrets.yaml;
    format = "yaml";
  };

  # SSH key - conditional based on token
  home.file.".ssh/id_rsa".source = config.sops.secrets.secrets_file.value.secrets.${token}.data;

  # Git config file
  # Only required because for some reason it's forbidden to have the email in public...
  # Which is public anyway as it appears on the public accounts :D But anyway...
  home.file.".config/git/work.inc".source = lib.mkIf config.sops.secrets.work_gitconfig.path;

  # AWS config - only if isWork is true
  home.file.".aws/config" = lib.mkIf isWork {
    source = config.sops.secrets.secrets_file.value.secrets.token_3.data;
  };

  # Environment variables
  home.sessionVariables = lib.mkIf isWork {
    READ_REG_TOKEN = config.sops.secrets.secrets_file.value.secrets.token_4.data;
  };
}
