-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Ensure Neo-tree is loaded before setting the keymap

-- Toggle Copilot CLI panel (open/hide/show)
vim.keymap.set("n", "<leader>ac", function()
  -- Copy current buffer path to clipboard for easy context sharing
  local bufpath = vim.api.nvim_buf_get_name(0)
  if bufpath ~= "" then
    vim.fn.setreg("+", bufpath)
  end
  -- If the terminal window is visible, hide it
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("term://.*copilot") then
      vim.api.nvim_win_hide(win)
      return
    end
  end
  -- If a copilot terminal buffer exists but is hidden, show it
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("term://.*copilot") and vim.api.nvim_buf_is_loaded(buf) then
      vim.cmd("botright vsplit")
      vim.api.nvim_win_set_buf(0, buf)
      return
    end
  end
  -- Otherwise, create a new one
  vim.cmd("botright vsplit | terminal copilot")
  -- Auto-close the window when the terminal exits
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
      local win = vim.fn.bufwinid(vim.api.nvim_get_current_buf())
      if win ~= -1 then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end, { desc = "Toggle Copilot CLI" })

-- Ctrl+Esc to exit terminal mode and jump back to code
vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n><C-w>h", { desc = "Exit terminal, focus code" })

