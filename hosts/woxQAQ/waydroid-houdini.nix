# Waydroid ARM 转译层（libhoudini, HPE/Google Play Games PC 版）固化。
#
# 背景：官方 Android 13 镜像（lineage-20）运行 ARM-only 应用（如明日方舟）需要
# x86→ARM 转译层。选型 HPE 版 houdini v14.0.0（从 Google Play Games PC 镜像提取），
# 因为 ChromeOS/WSA 版（38765/38795）面向 Android 11，其 nativebridge ABI 与
# Android 13 不兼容，System.loadLibrary 时必然空指针崩溃。
#
# 本服务幂等地完成四件事：
# 1. 安装 houdini prebuilts 到 /var/lib/waydroid/overlay/system（NOP 掉 time-bomb 检查）
# 2. 安装 houdini.rc（binfmt_misc 注册）与 houdini-ldconfig.sh
# 3. 修正 /proc/cpuinfo bind-mount 所需的伪 ARM cpuinfo 文件
# 4. 写入 waydroid.cfg [properties]（abilist / native.bridge 等）
#
# houdini 会 dlopen("/apex/com.android.art/lib64/libart.so")，而 Android 13 的
# 应用命名空间默认不放行该路径，houdini-ldconfig.sh 在每次开机的 zygote-start
# 触发器里把该路径注入生成的 /linkerconfig/ld.config.txt（动态补丁而非静态快照，
# 镜像 OTA 更新后依然有效）。
{ pkgs, ... }:
let
  version = "14.0.0_y.GoogleGame_com1.3";

  houdiniSrc = pkgs.fetchzip {
    url = "https://github.com/supremegamers/vendor_intel_proprietary_houdini/archive/2f8f088671182e17e67321e098e8411a3972a628.tar.gz";
    hash = "sha256-eXkgwP3n5y2XDRB4yDEivpWvhZuPlvUy5/hjALt6cFs=";
    stripRoot = true;
  };

  # binfmt_misc 注册 ARM 可执行文件解释器；zygote-start 时注入 linker 配置。
  houdiniRc = pkgs.writeText "houdini.rc" ''
    on early-init
        mount binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc

    on property:ro.enable.native.bridge.exec=1
        exec -- /system/bin/sh -c "echo ':arm_exe:M::\\x7f\\x45\\x4c\\x46\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x28::/system/bin/houdini:P' > /proc/sys/fs/binfmt_misc/register"
        exec -- /system/bin/sh -c "echo ':arm_dyn:M::\\x7f\\x45\\x4c\\x46\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x03\\x00\\x28::/system/bin/houdini:P' >> /proc/sys/fs/binfmt_misc/register"
        exec -- /system/bin/sh -c "echo ':arm64_exe:M::\\x7f\\x45\\x4c\\x46\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"
        exec -- /system/bin/sh -c "echo ':arm64_dyn:M::\\x7f\\x45\\x4c\\x46\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x03\\x00\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"

    on zygote-start
        exec -- /system/bin/sh /system/etc/houdini-ldconfig.sh
  '';

  # 容器内 /system/bin/sh（toybox）执行。先剥离旧注入行保证幂等，
  # 只在 [system] 段的 default namespace 赋值行后插入。
  ldconfigPatch =
    pkgs.writeText "houdini-ldconfig.sh" # sh
      ''
        #!/system/bin/sh
        CFG=/linkerconfig/ld.config.txt
        TMP=/data/local/tmp/.ldcfg.$$
        grep -v 'permitted.paths += /apex/com.android.art' "$CFG" > "$TMP"
        in_sys=0
        while IFS= read -r line; do
          case "$line" in
            "[system]") in_sys=1 ;;
            "["*) in_sys=0 ;;
          esac
          echo "$line"
          if [ "$in_sys" = 1 ]; then
            case "$line" in
              "namespace.default.permitted.paths = "*)
                echo 'namespace.default.permitted.paths += /apex/com.android.art/lib64'
                echo 'namespace.default.permitted.paths += /apex/com.android.art/lib'
                ;;
            esac
          fi
        done < "$TMP" > "$CFG"
        rm -f "$TMP"
      '';

  # props 写入与清理。单独成文件以避免 heredoc 缩进破坏 Python。
  propsScript =
    pkgs.writeText "waydroid-houdini-props.py" # py
      ''
        import os
        import re

        props = {
            "ro.product.cpu.abilist": "x86_64,arm64-v8a,x86,armeabi-v7a,armeabi",
            "ro.product.cpu.abilist32": "x86,armeabi-v7a,armeabi",
            "ro.product.cpu.abilist64": "x86_64,arm64-v8a",
            "ro.dalvik.vm.native.bridge": "libhoudini.so",
            "ro.enable.native.bridge.exec": "1",
            "ro.dalvik.vm.isa.arm": "x86",
            "ro.dalvik.vm.isa.arm64": "x86_64",
        }

        cfg_path = "/var/lib/waydroid/waydroid.cfg"
        content = open(cfg_path).read() if os.path.exists(cfg_path) else "[waydroid]\n"
        for key in props:
            content = re.sub(rf"^{re.escape(key)}=.*\n?", "", content, flags=re.M)
        block = "[properties]\n" + "".join(f"{k}={v}\n" for k, v in props.items())
        if "[properties]" in content:
            content = re.sub(r"\[properties\]\n?", block, content, count=1)
        else:
            content = content.rstrip() + "\n\n" + block
        open(cfg_path, "w").write(content)

        # 调试期曾把同一组 props 直接追加进 waydroid_base.prop；
        # cfg [properties] 优先级更高且 base.prop 随镜像重置，清掉重复项。
        base = "/var/lib/waydroid/waydroid_base.prop"
        if os.path.exists(base):
            content = open(base).read()
            for key in props:
                content = re.sub(rf"^{re.escape(key)}=.*\n?", "", content, flags=re.M)
            open(base, "w").write(content)
      '';
in
{
  systemd.services.waydroid-houdini-setup = {
    description = "Install libhoudini ARM translation into the Waydroid overlay";
    # 容器启动前确保 overlay 就绪；container 服务由 NixOS waydroid 模块提供
    wantedBy = [ "waydroid-container.service" ];
    before = [ "waydroid-container.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [
      coreutils
      gnused
      python3
    ];
    script = ''
      set -euo pipefail

      OVERLAY=/var/lib/waydroid/overlay/system
      STAMP="$OVERLAY/.houdini-version"

      if [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "${version}" ]; then
        echo "houdini ${version} already installed, skipping"
        exit 0
      fi

      mkdir -p "$OVERLAY"

      # 1. prebuilts → overlay
      cp -r ${houdiniSrc}/prebuilts/* "$OVERLAY/"
      mkdir -p "$OVERLAY/etc/init"

      # 2. time-bomb 检查 NOP 补丁（原始文件偏移 0xe61d5，6 字节 JAE → NOP）
      #    参考 waydroid-helper/waydroid-helper#127
      printf '\x90\x90\x90\x90\x90\x90' | dd of="$OVERLAY/lib64/libhoudini.so" \
        bs=1 seek=$((0xe61d5)) conv=notrunc status=none

      # 3. 伪 ARM cpuinfo（nativebridge bind-mount /proc/cpuinfo 所需）
      cp "$OVERLAY/lib64/arm64/cpuinfo" "$OVERLAY/etc/cpuinfo.arm64.txt"
      cp "$OVERLAY/lib/arm/cpuinfo" "$OVERLAY/etc/cpuinfo.arm.txt"

      # 4. init rc 与 linker 配置补丁脚本
      cp ${houdiniRc} "$OVERLAY/etc/init/houdini.rc"
      cp ${ldconfigPatch} "$OVERLAY/etc/houdini-ldconfig.sh"
      chmod 755 "$OVERLAY/etc/houdini-ldconfig.sh"

      # 清理早期调试遗留：静态 linker 快照与被证明无效的 public.libraries.txt 改动
      rm -f "$OVERLAY/etc/ld.config.houdini.txt" "$OVERLAY/etc/public.libraries.txt"

      chown -R root:root "$OVERLAY"
      find "$OVERLAY" -type d -exec chmod 755 {} +

      # 5. props：写 waydroid.cfg [properties]，并清掉调试期直接追加到
      #    waydroid_base.prop 的重复项（cfg 优先级更高，base.prop 随镜像重置）
      python3 ${propsScript}

      echo "${version}" > "$STAMP"
      echo "houdini ${version} installed into waydroid overlay"
    '';
  };
}
