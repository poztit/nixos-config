{ lib, pkgs, ... }:
let
  rootHome = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/francoisillien" else "/home/fillien";
  keyFilePath = "${rootHome}/.config/sops/age/keys.txt";
in
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    gnupg.sshKeyPaths = [ ];
    age = {
      sshKeyPaths = [ ];
      keyFile = keyFilePath;
    };
  };
}
