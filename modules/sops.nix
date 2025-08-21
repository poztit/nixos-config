{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  rootHome = if isDarwin then "/Users/francoisillien" else "/home/fillien";
  keyFilePath = "${rootHome}/.config/sops/age/keys.txt";
in {
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
