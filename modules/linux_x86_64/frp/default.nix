{ }:
{
  services.frp = {
    enable = true;
    role = "client";
    settings = builtins.fromTOML (builtins.readFile ./frpc.toml);
  };
}
