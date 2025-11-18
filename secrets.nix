{ config, lib, pkgs, isWork, ... }:

let
  token = if isWork then "token_1" else "token_2";
  secretsYaml = ./secrets/secrets.yaml;
in
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      work_gitconfig = {
        sopsFile = ./secrets/work.yaml;
        format = "yaml";
        path = "${config.home.homeDirectory}/.config/git/work.inc";
      };
      ssh_key = {
        sopsFile = secretsYaml;
        format = "yaml";
        key = "secrets/${token}/data";
        path = "${config.home.homeDirectory}/.ssh/id_rsa";
      };
      aws_config = {
        sopsFile = secretsYaml;
        format = "yaml";
        key = "secrets/token_3/data";
        path = "${config.home.homeDirectory}/.aws/config";
      };
      read_reg_token = {
        sopsFile = secretsYaml;
        format = "yaml";
        key = "secrets/token_4/data";
      };
    };
  };
}
