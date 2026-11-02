//! Bind the initial niri profile to a physical OpenLogi device once.

use std::error::Error;
use std::path::PathBuf;

use openlogi_agent_core::device_order::DeviceStableId;
use openlogi_core::config::Config;
use openlogi_core::device::DeviceKind;
use openlogi_hid::DeviceRoute;

type Result<T> = std::result::Result<T, Box<dyn Error>>;

#[tokio::main]
async fn main() -> Result<()> {
    let mut args = std::env::args_os().skip(1);
    let path = PathBuf::from(args.next().ok_or("expected a config path")?);
    if !path.is_file() {
        return Err("initial OpenLogi config is not available".into());
    }
    let explicit_key = match args.next() {
        None => None,
        Some(flag) if flag == "--device-key" => Some(
            args.next()
                .ok_or("--device-key needs a value")?
                .into_string()
                .map_err(|_| "device key must be UTF-8")?,
        ),
        Some(_) => return Err("expected --device-key <physical key>".into()),
    };
    if args.next().is_some() {
        return Err("unexpected argument".into());
    }
    let mut config = Config::load_from_path(&path)?;
    if !config.devices.contains_key("niri") {
        return Ok(());
    }
    let key = if let Some(key) = explicit_key {
        if openlogi_agent_core::device_order::PhysicalDeviceKey::parse(&key).is_none() {
            return Err("--device-key must be a stable physical device key".into());
        }
        key
    } else {
        let mut keys = Vec::new();
        for inventory in openlogi_hid::enumerate().await? {
            for device in &inventory.paired {
                if !device.online
                    || device.kind != DeviceKind::Mouse
                    || !device
                        .codename
                        .as_deref()
                        .is_some_and(|name| name.contains("MX Master 2S"))
                {
                    continue;
                }
                let Some(model) = device.model_info.as_ref() else {
                    continue;
                };
                let route = DeviceRoute::device_route_for(&inventory, device.slot);
                if let Some(key) = DeviceStableId::from_parts(
                    route.as_ref(),
                    device.slot,
                    model.serial_number.as_deref(),
                    model.unit_id,
                )
                .physical_key()
                {
                    keys.push(key.into_string());
                }
            }
        }
        keys.sort();
        keys.dedup();
        if keys.len() != 1 {
            return Err(
                "expected one awake MX Master 2S with readable HID++; check udev permissions"
                    .into(),
            );
        }
        keys.remove(0)
    };
    let profile = config
        .devices
        .remove("niri")
        .ok_or("initial profile disappeared")?;
    // Existing physical-device settings always win over the initial defaults.
    config.devices.entry(key.clone()).or_insert(profile);
    if config
        .selected_device
        .as_deref()
        .is_none_or(|selected| selected == "niri")
    {
        config.selected_device = Some(key);
    }
    config.save_to_path(&path)?;
    Ok(())
}
