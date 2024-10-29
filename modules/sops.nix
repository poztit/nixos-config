{ ... }: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    gnupg.sshKeyPaths = [ ];
    age = {
      sshKeyPaths = [ ];
      keyFile = "/home/fillien/.config/sops/age/keys.txt";
    };
  };
}
