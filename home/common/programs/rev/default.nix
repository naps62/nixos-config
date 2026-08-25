{ inputs, ... }:
# rev: the always-on code review server. Module only — no `enable` here. It
# discovers every repo under its roots and serves them without auth, so only a
# box that is already a trusted single-user machine should run it.
{
  imports = [ inputs.rev.homeManagerModules.default ];
}
