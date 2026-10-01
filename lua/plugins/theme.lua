return {
  "projekt0n/github-nvim-theme",
  priority = 1000,
  config = function()
    require("github-theme").setup({})

    -- Always use dark mode, regardless of the system appearance
    vim.o.background = "dark"
    vim.cmd("colorscheme github_dark_high_contrast")

    -- Re-apply the dark colorscheme if anything flips 'background'
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = function()
        if vim.o.background ~= "dark" then
          vim.o.background = "dark"
        end
        vim.cmd("colorscheme github_dark_high_contrast")
      end,
    })
  end,
}
