return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim",  },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    harpoon:extend(require("harpoon.extensions").builtins.highlight_current_file())

    -- Override LazyVim default <leader><leader> (find files) with Harpoon quick menu
    vim.keymap.set("n", "<leader><leader>", function()
      require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
    end, { desc = "Harpoon quick menu" })

    vim.keymap.set("n", "<leader>h", function()
      harpoon:list():add()
    end, { desc = "Harpoon add file" })

    vim.keymap.set("n", "<leader>1", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon file 1" })

    vim.keymap.set("n", "<leader>2", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon file 2" })

    vim.keymap.set("n", "<leader>3", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon file 3" })

    vim.keymap.set("n", "<leader>4", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon file 4" })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<S-Tab>", function()
      harpoon:list():prev({ ui_nav_wrap = true })
    end, { desc = "Harpoon prev" })

    vim.keymap.set("n", "<Tab>", function()
      harpoon:list():next({ ui_nav_wrap = true })
    end, { desc = "Harpoon next" })
  end,
}
