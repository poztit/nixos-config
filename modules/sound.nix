{ ... }:
{
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.extraConfig.pipewire = {
    "10-default-clock" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 ];
      };
    };
  };
}
