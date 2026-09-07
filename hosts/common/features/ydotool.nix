{ ... }:
{
  # OpenWhispr's global-hotkey paste on Wayland shells out to ydotool, which
  # needs the ydotoold daemon + /dev/uinput access via this group.
  programs.ydotool.enable = true;
  users.users.naps62.extraGroups = [ "ydotool" ];
}
