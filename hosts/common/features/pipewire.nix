{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ pulseaudio ];
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Disable the LC3-SWB HFP codec. BlueZ 5.86's experimental LC3 super-wideband
    # headset path (lit up by hardware.bluetooth Experimental=true) is broken for
    # the Sony WF-1000XM6: when a call opens the mic, WirePlumber auto-switches to
    # the highest-priority headset profile (LC3-SWB), the audio link fails to set
    # up ("Hands-Free Voice gateway: Transport endpoint is not connected"), and the
    # buds reset with no call audio/mic. Omitting lc3_swb from the codec allow-list
    # makes autoswitch fall back to mSBC, which is stable wideband voice. Everything
    # else (A2DP LDAC/AAC/SBC, and lc3 for any future LE Audio) stays enabled.
    wireplumber.extraConfig."51-disable-lc3swb-hfp" = {
      "monitor.bluez.properties" = {
        "bluez5.codecs" = [
          "sbc"
          "sbc_xq"
          "aac"
          "aptx"
          "aptx_hd"
          "aptx_ll"
          "ldac"
          "lc3"
          "cvsd"
          "msbc"
        ];
      };
    };
  };
}
