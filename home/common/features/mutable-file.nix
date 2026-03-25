{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.home.mutableFiles;
  repoPath = config.home.mutableFilesRepoPath;
  flakePrefix = self.outPath;

  fileEntries = lib.attrsToList cfg;

  toRepoPath = storePath: repoPath + lib.removePrefix flakePrefix (toString storePath);

  checkScript = lib.concatMapStringsSep "\n" (
    { name, value }:
    let
      target = "${config.home.homeDirectory}/${name}";
      storePath = value.source;
      originalPath = toRepoPath value.source;
    in
    ''
      if [ -f "${target}" ] && ! ${lib.getExe' pkgs.diffutils "diff"} -q "${storePath}" "${target}" > /dev/null 2>&1; then
        echo ""
        echo "!! mutable file changed: ${name}"
        echo "   To bring changes upstream:"
        echo "   cp ${target} ${originalPath}"
        echo ""
        ${lib.getExe' pkgs.diffutils "diff"} -u "${storePath}" "${target}" || true
        _mutable_changed=1
      fi
    ''
  ) fileEntries;

  copyScript = lib.concatMapStringsSep "\n" (
    { name, value }:
    let
      target = "${config.home.homeDirectory}/${name}";
      source = value.source;
      dirName = builtins.dirOf target;
    in
    ''
      mkdir -p "${dirName}"
      cp -f "${source}" "${target}"
      chmod ${if value.executable then "755" else "644"} "${target}"
    ''
  ) fileEntries;
in
{
  options.home.mutableFilesRepoPath = lib.mkOption {
    type = lib.types.str;
    description = "Absolute path to the nixos-config repo on disk.";
  };

  options.home.mutableFiles = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.path;
            description = "Path to the source file.";
          };
          executable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether the file should be executable.";
          };
        };
      }
    );
    default = { };
    description = "Files to copy (not symlink) into the home directory, with change detection.";
  };

  config = lib.mkIf (cfg != { }) {
    home.activation.mutableFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      _mutable_changed=0
      ${checkScript}
      if [ "$_mutable_changed" -eq 1 ]; then
        echo ""
        echo "!! Aborting: mutable files have been modified outside of nix."
        echo "   Bring the changes upstream first, then re-run."
        exit 1
      fi
      ${copyScript}
    '';
  };
}
