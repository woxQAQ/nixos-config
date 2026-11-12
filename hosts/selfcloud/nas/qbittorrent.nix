{
  pkgs,
  username,
  ...
}:
let
  profileDir = "/home/${username}/.config/qBittorrent";
  configFile = "${profileDir}/qBittorrent/config/qBittorrent.conf";
in
{
  networking.firewall.allowedTCPPorts = [ 8080 ]; # qBittorrent WebUI

  systemd.services.qbittorrent-nox = {
    description = "qBittorrent-nox";
    after = [
      "network.target"
      "mnt-data.mount"
    ];
    wantedBy = [ "multi-user.target" ];
    # Merge proxy settings into the writable profile, retaining credentials and torrents.
    preStart = ''
      umask 077
      mkdir -p ${profileDir}/qBittorrent/config
      ${pkgs.crudini}/bin/crudini --set ${configFile} Preferences 'WebUI\ServerDomains' qbittorrent.selfcloud.lan
      ${pkgs.crudini}/bin/crudini --set ${configFile} Preferences 'WebUI\ReverseProxySupportEnabled' true
      ${pkgs.crudini}/bin/crudini --set ${configFile} Preferences 'WebUI\TrustedReverseProxiesList' 127.0.0.1
    '';
    serviceConfig = {
      Type = "simple";
      User = username;
      Group = "users";
      # Prefer interactive directory reads over background torrent I/O.
      IOSchedulingClass = "idle";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=${profileDir} --webui-port=8080";
      Restart = "on-failure";
    };
  };
}
