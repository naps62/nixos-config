{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # top-level elixir_* aliases are deprecated in favour of the beamPackages sets
    beamPackages.elixir_1_18
  ];
}
