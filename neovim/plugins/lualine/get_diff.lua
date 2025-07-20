function()
  local gitsigns = vim.b.gitsigns_status_dict
  if vim.b.gitsigns_status_dict then
    return {
      added=gitsigns.added,
      modified=gitsigns.changed,
      removed=gitsigns.removed,
    }
  end
end
