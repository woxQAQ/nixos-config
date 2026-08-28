{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "yes";
      Compression = true;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 2;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%h:%p";
      ControlPersist = "no";
    };
    settings = {
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentitiesOnly = true;
      };
      "tangled.org" = {
        HostName = "tangled.org";
        Port = 22;
        User = "git";
        IdentitiesOnly = true;
      };
    };
  };
}
