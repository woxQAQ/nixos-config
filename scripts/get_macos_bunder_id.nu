#!/usr/bin/env nu

def main [app: string] {
    let info_plist = $"/Applications/($app).app/Contents/Info.plist"

    if not ($info_plist | path exists) {
        error make --unspanned {msg: $"App not found: ($info_plist)"}
    }

    let bundle_id = (plutil -extract CFBundleIdentifier raw $info_plist)
    $bundle_id
}
