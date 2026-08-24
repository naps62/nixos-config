{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.mpv;
in
{
  options.custom.mpv = {
    hwdec = lib.mkOption {
      type = lib.types.str;
      default = "auto-safe";
      example = "nvdec-copy";
      description = ''
        Value for mpv's `hwdec`. `auto-safe` only picks a decoder mpv considers
        reliable for the running driver and falls back to software otherwise,
        so it is correct on Intel (arrakis) and on hosts with no usable GPU
        decoder (yolo). NVIDIA hosts override it.
      '';
    };
  };

  config = {
    programs.mpv = {
      enable = true;

      config = {
        hwdec = cfg.hwdec;
        vo = lib.mkDefault "gpu-next";
        save-position-on-quit = true;
        keep-open = "yes";
      };
    };
  };
}
