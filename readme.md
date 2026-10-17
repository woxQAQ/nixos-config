# :snowflake: woxQAQ flake

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2FwoxQAQ%2Fnixos-config%2Fbadge%3Fref%3Dmain&style=flat)](https://actions-badge.atrox.dev/woxQAQ/nixos-config/goto?ref=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

It is a nix flake which manages my all NixOS host and MacOS host

## Binary caches

缓存地址和签名公钥统一维护在 `modules/public/system.nix`，供 NixOS 和
nix-darwin 共用。官方缓存通过 USTC 镜像和官方地址访问；nix-community、
Numtide（llm-agents）和 Catppuccin 提供对应项目的构建产物。
Catppuccin 的 Home Manager 缓存注入已关闭，避免用户级配置重复维护信任列表。
不默认启用尚未确认有实际命中收益的 nixpkgs-unfree 缓存。

`flake.nix`、Makefile 和 justfile 不再维护另一份镜像列表，也不提供
`USE_SUBSTITUTERS` / `_USE_SUBSTITUTERS` / `SUBSTITUTERS` 开关。
日常构建使用已激活的系统配置；首次安装或临时排查使用 Nix 原生参数：

```sh
# 追加镜像，保留当前缓存和签名验证。
nix build --extra-substituters https://mirrors.ustc.edu.cn/nix-channels/store \
  .#nixosConfigurations.woxQAQ.config.system.build.toplevel

# 仅查询指定缓存，不构建或激活系统。
nix store info --store https://cache.numtide.com
```

`--option substituters "URL ..."` 会替换本次调用的缓存列表，只用于明确需要隔离
缓存来源的排查。新增第三方缓存还需要独立审核其签名公钥；不要关闭签名验证。

### 网络排查

macOS 系统代理设置不保证被终端中的 Nix 或 nix-daemon 使用。若直连失败，可用
本机已有代理对照检查；下面的地址需要按实际代理端口调整：

```sh
https_proxy=http://127.0.0.1:7897 \
  nix store info --store https://cache.numtide.com
```

这里的环境变量只影响本次客户端命令，不会配置已经运行的 nix-daemon。
若客户端代理访问成功而系统构建仍下载失败，需要检查 daemon 自身的代理环境或
透明代理路由。代理策略应按主机设置，不在公共模块里硬编码本机端口。
`store info` 只验证缓存可达性，不代表目标包一定命中，也不代表 NAR 下载速度。

## Reference

Projects which inspire me

[ryan4yin's nix config](https://github.com/ryan4yin/nix-config) has provided a
nix flake project layout for me.
