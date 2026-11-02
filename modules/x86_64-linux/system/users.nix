{ username, ... }: {
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = [
      "wireshark"
      "samba"
      "input"
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
      "docker"
      "kvm"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys =
      let
        nixos-woxQAQ = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErm4Zne8GJFo8zrGYcAyhZqZQbkV4sMlj5k0D+CbelW srkmyk@woxQAQ";
        darwin-machine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAVB5rGXF8TrlRrKwRwUGju/yrenIqy78osPf9itUkq root@woxMac";
        darwin-woxQAQ = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOoMXR0qWpbMU+39FsJ9zUiD7q8yGgpG7RYUc3tasPN woxqaq@woxMac";
      in
      [
        nixos-woxQAQ
        darwin-machine
        darwin-woxQAQ
      ];
  };
  nix.settings.allowed-users = [ username ];
}
