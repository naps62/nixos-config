{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.blender;
in
{
  options.custom.blender = {
    cuda = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Build Blender with CUDA/OptiX so Cycles renders on the GPU instead of
        the CPU. Only useful on an NVIDIA host; enabling it on arrakis (Intel)
        would mean a long build for nothing.

        No binary cache serves this — cuda-maintainers was measured to make no
        difference — so flipping this on rebuilds Blender, OpenUSD, OpenSubdiv
        and OpenImageDenoise from source.
      '';
    };
  };

  config = {
    home.packages = [
      (if cfg.cuda then pkgs.blender.override { cudaSupport = true; } else pkgs.blender)
      pkgs.prusa-slicer
    ];

    fonts.fontconfig.enable = true;

    xdg.desktopEntries.prusaslicer-url-handler = {
      name = "PrusaSlicer Protocol Handler";
      exec = "prusa-slicer %u";
      type = "Application";
      noDisplay = true;
      mimeType = [ "x-scheme-handler/prusaslicer" ];
    };
  };
}
