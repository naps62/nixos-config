_:
{
  programs.ssh = {
    enable = true;

    # Opt out of the soon-to-be-removed implicit `settings."*"` defaults.
    # They only ever matched OpenSSH's own defaults, so nothing is lost.
    enableDefaultConfig = false;

    # `settings` is a freeform block set: attribute names are Host/Match
    # patterns, values use OpenSSH directive names directly.
    settings = {
      "*" = {
        # Connection multiplexing — reuse one TCP/auth connection for
        # repeated ssh/git/scp to the same host. `%C` is a hash, so no
        # parent directory needs pre-creating.
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%C";
        ControlPersist = "10m";

        # Keep idle sessions alive; drop genuinely dead ones after ~3 min.
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;

        # Load the key into the (gpg-)agent on first use — passphrase once
        # per session. Requires services.gpg-agent.enableSshSupport.
        AddKeysToAgent = "yes";
      };

      "yolo" = {
        HostName = "10.7.10.2";
        RemoteForward = [
          {
            bind.port = 9222;
            host.address = "localhost";
            host.port = 9222;
          }
        ];
      };
    };
  };
}
