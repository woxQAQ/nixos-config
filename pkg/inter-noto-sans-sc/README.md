# Inter Noto Sans SC

实际合并的 TrueType 字体家族，不依赖应用的字体回退。名称中的 Inter 和
Noto 标明字形来源，SC 表示使用简体中文区域字形；这是本仓库的派生字体，
不是两个上游项目的官方发行版。

## 合并规则

- Inter 覆盖的西文、数字、标点及符号优先使用 Inter。
- CJK 标点（U+3000–303F）、半角及全角形式（U+FF00–FFEF）和其余字符使用
  Noto Sans CJK SC，保留两个源字体的 Unicode 字符覆盖并集。
- Noto 从 1000 units/em 等比转换为 Inter 的 2048 units/em；中文保持全宽，
  不压缩、不拉伸。Inter 的 optical size 固定为适合正文/UI 的 14。
- 使用常规字体基线及合并后的行高指标；不携带 fontTools 无法实例化的
  Noto 可变 `BASE` 表（用于高级跨文字基线对齐）。
- 保留 OpenType 排版特性，包括 Inter 的 kerning、连字、数字样式及 CJK
  竖排。Noto 的默认字形已经是简体中文；只保留这个默认 layout language，
  避免地区记录遮蔽 Inter 的特性，并避免合并后超过 OpenType 的 65,535
  字形上限。因此它不适合需要自动切换日文、韩文或繁体地区字形的排版。
- 输出九个静态正体字重：Thin 100、ExtraLight 200、Light 300、Regular 400、
  Medium 500、SemiBold 600、Bold 700、ExtraBold 800、Black 900。不生成伪斜体。
- 保留源字体版权声明，附带两份 SIL OFL 1.1 许可证，不覆盖原字体。

源版本：Inter 来自 flake 锁定的 `pkgs.inter`；Noto Sans CJK SC 为 2.004。
构建仅需 Python 和 fontTools，所有输入均由 Nix 固定。

## 构建和使用

在仓库根目录运行（`path:.` 也包含尚未加入 Git 的本地文件）：

```sh
nix build path:.#darwinConfigurations.woxMac.pkgs.inter-noto-sans-sc \
  --out-link result-font
```

字体文件位于 `result-font/share/fonts/truetype/`。可以直接取出 TTF 文件，
或通过仓库的 macOS 字体配置安装，然后在应用里选择 **Inter Noto Sans SC**。
旧式字体选择器可能把非 Regular/Bold 字重显示为独立家族。

安装不会替换 macOS 系统 UI 字体；需要在支持自选字体的应用中选择它。
