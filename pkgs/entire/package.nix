{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "entire";
  version = "unstable-2026-02-11";

  src = fetchFromGitHub {
    owner = "entireio";
    repo = "cli";
    rev = "4f09f97c2a2d90f5fa28609ff98dbd9ccb988794";
    hash = "sha256-b3XjU4f/W0OicWlyvCua5LH8IBBRNs9fggFdwBh1rFY=";
  };

  vendorHash = "sha256-bzSJfN77v2huchYZwD8ftBRffVLP4OiZqO++KXj3onI=";

  subPackages = [ "cmd/entire" ];

  # Relax Go version requirement since 1.25.5 is compatible with 1.25.6
  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.25.6" "go 1.25.5"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Developer platform that integrates with git workflow to capture AI agent sessions";
    homepage = "https://github.com/entireio/cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "entire";
  };
}
