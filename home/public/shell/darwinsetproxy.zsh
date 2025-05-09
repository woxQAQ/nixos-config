#!/bin/zsh

function darwinSetProxy {
  eval $(scutil --proxy | awk '
    /HTTPEnable/ { printf "http_enabled=%s;", $3 }
    /HTTPProxy/ { printf "http_proxy_addr=%s;", $3 }
    /HTTPPort/ { printf "http_port=%s;", $3 }
    /HTTPSEnable/ { printf "https_enabled=%s;", $3 }
    /HTTPSProxy/ { printf "https_proxy_addr=%s;", $3 }
    /HTTPSPort/ { printf "https_port=%s;", $3 }
  ');
  http_proxy="http://$http_proxy_addr:$http_port"
  https_proxy="http://$https_proxy_addr:$https_port"
}
