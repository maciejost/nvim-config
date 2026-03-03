return {
  "projekt0n/github-nvim-theme",
  priority = 1000,
  config = function()
    require("github-theme").setup({})
    vim.cmd("colorscheme github_dark_high_contrast")
  end,
}
