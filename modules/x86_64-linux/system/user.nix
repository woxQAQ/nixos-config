{ username, ... }:
{
  # imports = [ inputs.home-manager.nixosModules.home-manager ];
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "wireshark"
      "samba"
      "input"
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
      "docker"
    ];
    openssh.authorizedKeys.keys =
      let
        nixos-woxQAQ = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrL5gG/7PPvCr8U/uBXp4B7GRjSu9zZVoFQgffQpQUS srkmyk@woxqaq";
        darwin-machine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAVB5rGXF8TrlRrKwRwUGju/yrenIqy78osPf9itUkq root@woxMac";
        darwin-woxQAQ = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOoMXR0qWpbMU+39FsJ9zUiD7q8yGgpG7RYUc3tasPN woxqaq@woxMac";
      in
      [
        nixos-woxQAQ
        darwin-machine
        darwin-woxQAQ
      ];
  };
  nix.settings.allowed-users = [ "${username}" ];
}
