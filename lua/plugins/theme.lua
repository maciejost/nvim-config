return {
  "projekt0n/github-nvim-theme",
  priority = 1000,
  config = function()
    require("github-theme").setup({})

    -- Detect system theme and set background
    local function detect_system_theme()
      local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        -- If the command returns "Dark", we're in dark mode
        -- If it returns empty/errors, we're in light mode
        if result:match("Dark") then
          vim.o.background = "dark"
        else
          vim.o.background = "light"
        end
      end
    end

    -- Function to set theme based on background
    local function set_theme()
      if vim.o.background == "dark" then
        vim.cmd("colorscheme github_dark_high_contrast")
      else
        vim.cmd("colorscheme github_light")
      end
    end

    -- Detect and set initial theme
    detect_system_theme()
    set_theme()

    -- Auto-update theme when background changes
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = set_theme,
    })
  end,
}
