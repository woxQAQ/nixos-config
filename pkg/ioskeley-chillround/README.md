# Ioskeley ChillRound Mono

实际合并的 TrueType 字体，英文、代码符号和 Nerd Font 图标来自
`ioskeley-mono.term-nf`，缺失字符由寒蝉全圆体 `chillroundf` 补齐。
新名称用于区分本地合成字体和两个上游字体。

- 提供 Regular、Bold、Italic、Bold Italic 四种样式；中文斜体使用直立字形。
- Ioskeley 已有字符优先，保留其字宽、hinting 和 OpenType shaping 特性。
- ChillRoundF 的宽字符字框为两个英文单元，其余补充字符为一个单元，
  组合标记为零宽；字形水平居中，保持轮廓大小和比例。
- 保留 Ioskeley 的行高指标。中文不带比例字距和替换特性，避免终端偏离网格。
- 字符覆盖范围之外仍由系统字体回退处理。
- 构建时重新读取四个产物，检查字符覆盖、原有字符的水平指标、中文双宽及样式。

两款来源字体遵循 SIL Open Font License 1.1，许可证和版权信息随产物安装。
