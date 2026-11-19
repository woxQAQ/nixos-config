# Trust anchors for our internal services. Hosts that talk to these services
# import this directory in their module list.
{
  # HTTPS for *.selfcloud.lan is issued by Caddy's internal CA on selfcloud.
  # The root rotates when the server is reinstalled; re-export it with:
  #   sudo cat /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt
  # On NixOS this feeds the OpenSSL system store; on macOS it only covers
  # OpenSSL-based CLI tools, since browsers there use the system keychain.
  security.pki.certificateFiles = [ ./selfcloud-caddy-root.crt ];
}
