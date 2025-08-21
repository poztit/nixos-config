{ config, lib, ... }:

let
  sys = (builtins.currentSystem or "");
  isLinux = lib.hasSuffix "-linux" sys;
in {
  sops.secrets.tailscale_key = { };

  services.tailscale =
    {
      enable = true;
      # Optionally add extra flags for 'tailscale up', e.g.:
      # extraUpFlags = [ "--accept-dns=false" "--advertise-exit-node" ];
    }
    // lib.optionalAttrs isLinux {
      # Only NixOS module exposes `authKeyFile`.
      authKeyFile = config.sops.secrets.tailscale_key.path;
    };

  # Apply firewall config only on Linux; Darwin doesn't have `networking.firewall`.
} // lib.optionalAttrs isLinux {
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ (lib.attrByPath [ "services" "tailscale" "port" ] 41641 config) ];
    allowedTCPPorts = [ 22 ];
  };
}
