{ config, lib, ... }:

let
  sys = (builtins.currentSystem or "");
  isLinux = lib.hasSuffix "-linux" sys;
in
{
  # Secret is defined in modules/sops.nix

  services.tailscale =
    {
      enable = true;
      # Optionally add extra flags for 'tailscale up', e.g.:
      # extraUpFlags = [ "--accept-dns=false" "--advertise-exit-node" ];
    }
    // lib.optionalAttrs isLinux {
      authKeyFile = config.sops.secrets.tailscale_key.path;
    };

} // lib.optionalAttrs isLinux {
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ (lib.attrByPath [ "services" "tailscale" "port" ] 41641 config) ];
    allowedTCPPorts = [
      22   # SSH
      80   # HTTP
    ];
  };
}
