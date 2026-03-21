{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "yolo" = {
        hostname = "10.7.10.2";
        remoteForwards = [{
          bind.port = 9222;
          host.address = "localhost";
          host.port = 9222;
        }];
      };
    };
  };
}
