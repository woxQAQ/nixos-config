{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    logiops
  ];
  environment.etc."logid.cfg".source = ./logid.cfg;
  systemd.services.logid = {
    description = "Logitech Configuration Daemon";
    after = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
    wantedBy = [ "graphical.target" ];

    unitConfig = {
      StartLimitIntervalSec = 0;
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid";
      User = "root";
    };
  };
}
