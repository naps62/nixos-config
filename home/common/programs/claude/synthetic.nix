{
  pkgs,
  inputs,
  ...
}:
# Claude Code pointed at synthetic.new. The three model aliases below are bound
# to three Synthetic models, so `/model opus|sonnet|haiku` swaps between them
# live; anything else there is reachable by full id (`/model hf:...`).
let
  claude = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # `hf:` ids pin one exact model. The `syn:large:*` aliases in Synthetic's own
  # docs move under you whenever they rotate what "large" means.
  kimi = "hf:moonshotai/Kimi-K3";
  glm = "hf:zai-org/GLM-5.2";
  qwen = "hf:Qwen/Qwen3.6-27B";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "synclaude" ''
      set -euo pipefail

      if [ -z "''${SYNTHETIC_API_KEY:-}" ] && [ -r "$HOME/.env.claude" ]; then
        set +u
        # Silenced: the file greets missing tooling on stderr, which would
        # otherwise print before every session.
        . "$HOME/.env.claude" >/dev/null 2>&1
        set -u
      fi

      if [ -z "''${SYNTHETIC_API_KEY:-}" ]; then
        echo "synclaude: SYNTHETIC_API_KEY is not set" >&2
        exit 1
      fi

      export ANTHROPIC_BASE_URL="https://api.synthetic.new/anthropic"
      export ANTHROPIC_AUTH_TOKEN="$SYNTHETIC_API_KEY"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="${kimi}"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="${glm}"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="${qwen}"
      export CLAUDE_CODE_SUBAGENT_MODEL="${glm}"
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export CLAUDE_CODE_ATTRIBUTION_HEADER=0

      # ~/.env.claude exports both. ANTHROPIC_MODEL outranks the DEFAULT_* trio
      # above, and ANTHROPIC_API_KEY would send Anthropic's credential to
      # Synthetic.
      unset ANTHROPIC_MODEL ANTHROPIC_API_KEY

      # ~/.claude/settings.json pins model "opus[1m]". The [1m] context-window
      # suffix survives alias resolution and reaches Synthetic as part of the id,
      # which 404s there — so pick the alias explicitly unless the caller did.
      for arg in "$@"; do
        case "$arg" in
        --model | --model=*)
          exec ${claude}/bin/claude "$@"
          ;;
        esac
      done

      exec ${claude}/bin/claude --model sonnet "$@"
    '')
  ];
}
