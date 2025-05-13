return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  opts = function(_, opts)
    -- You can customize default Telescope behavior here
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      winblend = 0,
    })
  end,
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)

    -- Optional: load fzf-native if installed
    pcall(telescope.load_extension, "fzf")

    -- Override <space><space> to use current working directory
    vim.keymap.set("n", "<space><space>", function()
      require("telescope.builtin").find_files({ cwd = vim.fn.getcwd() })
    end, { desc = "Find Files (cwd)" })
  end,
}
