{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  jq,
  git,
  coreutils,
  gnugrep,
  gnused,
  gawk,
  findutils,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ralph-claude-code";
  version = "unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "frankbria";
    repo = "ralph-claude-code";
    rev = "605e50f725cd30bcaa53d132939746d37cc08c9d";
    hash = "sha256-AS8/z06kZV42O6NrvRdosFEDVdJ1YoYoj/q4OMF2o+0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    jq
    git
    coreutils
    gnugrep
    gnused
    gawk
    findutils
  ];

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/bin
    mkdir -p $out/share/ralph

    # Install core scripts to share directory
    cp ralph_loop.sh $out/share/ralph/
    cp ralph_monitor.sh $out/share/ralph/
    cp ralph_import.sh $out/share/ralph/
    cp migrate_to_ralph_folder.sh $out/share/ralph/
    cp ralph_enable.sh $out/share/ralph/
    cp ralph_enable_ci.sh $out/share/ralph/
    cp setup.sh $out/share/ralph/

    # Install templates and lib directories
    cp -r templates $out/share/ralph/
    cp -r lib $out/share/ralph/

    # Create wrapper scripts in bin
    # Main ralph command
    cat > $out/bin/ralph <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/ralph_loop.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph

    # ralph-monitor
    cat > $out/bin/ralph-monitor <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/ralph_monitor.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-monitor

    # ralph-setup
    cat > $out/bin/ralph-setup <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/setup.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-setup

    # ralph-import
    cat > $out/bin/ralph-import <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/ralph_import.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-import

    # ralph-migrate
    cat > $out/bin/ralph-migrate <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/migrate_to_ralph_folder.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-migrate

    # ralph-enable
    cat > $out/bin/ralph-enable <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/ralph_enable.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-enable

    # ralph-enable-ci
    cat > $out/bin/ralph-enable-ci <<EOF
    #!/usr/bin/env bash
    export RALPH_HOME="$out/share/ralph"
    exec "$out/share/ralph/ralph_enable_ci.sh" "\$@"
    EOF
    chmod +x $out/bin/ralph-enable-ci

    # Make all scripts executable
    chmod +x $out/share/ralph/*.sh

    # Wrap binaries to ensure PATH contains required tools
    for prog in $out/bin/*; do
      wrapProgram $prog \
        --prefix PATH : ${lib.makeBinPath buildInputs}
    done

    runHook postInstall
  '';

  meta = {
    description = "Autonomous AI development framework for Claude Code";
    homepage = "https://github.com/frankbria/ralph-claude-code";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ralph";
  };
}
