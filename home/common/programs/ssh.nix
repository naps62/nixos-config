_: {
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

        # Quiet the "channel N: open failed: connect failed: Connection
        # refused" noise (logged at INFO) when a forwarded port has nothing
        # listening yet. ExitOnForwardFailure stays off (default), so the
        # connection still succeeds over idle forwards.
        LogLevel = "ERROR";

        RemoteForward = [
          {
            bind.port = 9222;
            host.address = "localhost";
            host.port = 9222;
          }
        ];

        # Auto-forward localhost:47100/47101 to the same ports on yolo.
        LocalForward = [
          {
            bind.port = 41700;
            host.address = "localhost";
            host.port = 41700;
          }
          {
            bind.port = 41701;
            host.address = "localhost";
            host.port = 41701;
          }
        ];
      };
    };
  };
}
