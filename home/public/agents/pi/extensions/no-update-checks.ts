// original source https://github.com/xddxdd/nixos-config/blob/master/home/client-apps/ai-coding/extensions/no-update-check.ts
export default async function () {
  try {
    const mod: any = await import("@earendil-works/pi-coding-agent");
    const PM = mod.DefaultPackageManager;
    if (!PM?.prototype) return;
    const proto = PM.prototype;
    if (proto.__noUpdateCheckPatched) return;
    proto.__noUpdateCheckPatched = true;
    proto.checkForAvailableUpdates = async () => [];
  } catch {
    // Export unavailable in this pi version; fail harmlessly.
  }
}
