function()
  local ok, noice = pcall(require, "noice")
  if not ok then
    return false
  end
  return noice.api.status.mode.get()
end
