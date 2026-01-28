export def download-wallhaven [id: string] {
  let file_name = $"wallhaven-($id).jpg"
  http get https://w.wallhaven.cc/full/gw/($file_name).jpg | save ($env.HOME)/.wallpaper/($file_name)
}
