{ config, ... }:
let
  cfg = config.services.gitea;
in
{
  services.gitea = {
    enable = true;
    appName = "selfcloud Gitea";
    stateDir = "/var/lib/gitea";
    database.type = "sqlite3";
    lfs.enable = true;
    settings = {
      server = {
        ROOT_URL = "http://gitea.selfcloud.lan/";
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3000;
        START_SSH_SERVER = true;
        SSH_DOMAIN = "gitea.selfcloud.lan";
        SSH_LISTEN_HOST = "0.0.0.0";
        SSH_LISTEN_PORT = 2222;
        SSH_PORT = 2222;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    cfg.settings.server.HTTP_PORT
    cfg.settings.server.SSH_LISTEN_PORT
  ];

  environment.systemPackages = [ cfg.package ];
}
