{
  config,
  lib,
  pkgs,
  ...
}:

{
  security.pki.certificateFiles = [ ./n62.casa.pem ];
}
