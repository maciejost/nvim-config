local bazel_config = function()
  return vim.g.bazel_config or ""
end

return {
  -- https://github.com/alexander-born/bazel.nvim
  {
    "alexander-born/bazel.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    -- Load when editing Bazel files or when one of the keymaps below is pressed.
    ft = { "bzl", "bazel" },
    init = function()
      -- The go-to-definition / label features shell out to the python3 provider
      -- (pynvim). Point Neovim at the isolated venv created for it, unless the
      -- user already configured a python3 host.
      if vim.g.python3_host_prog == nil then
        local py = vim.fs.joinpath(vim.fn.stdpath("data"), "venv-pynvim", "bin", "python")
        if vim.fn.executable(py) == 1 then
          vim.g.python3_host_prog = py
        end
      end
    end,
    keys = {
      {
        "<leader>bzb",
        function()
          require("bazel").run_here("build", bazel_config())
        end,
        desc = "Build target of current file",
      },
      {
        "<leader>bzr",
        function()
          require("bazel").run_here("run", bazel_config())
        end,
        desc = "Run target of current file",
      },
      {
        "<leader>bzt",
        function()
          require("bazel").run_here("test", bazel_config() .. " --test_output=all")
        end,
        desc = "Test target of current file",
      },
      {
        "<leader>bzT",
        function()
          require("bazel").run_here(
            "test",
            bazel_config() .. " --test_output=all --test_arg=" .. require("bazel.gtest").get_gtest_filter_args()[1]
          )
        end,
        desc = "Test single GTest at cursor",
      },
      {
        "<leader>bzl",
        function()
          require("bazel").run_last()
        end,
        desc = "Run last Bazel command",
      },
      { "<leader>bzg", "<cmd>call GoToBazelTarget()<cr>", desc = "Go to BUILD file of current buffer" },
      { "<leader>bzd", "<cmd>call GoToBazelDefinition()<cr>", desc = "Go to Bazel definition" },
      { "<leader>bzp", "<cmd>PrintLabel<cr>", desc = "Print Bazel label at cursor" },
    },
    config = function()
      vim.g.bazel_config = vim.g.bazel_config or ""
      -- Override the executable if you use a wrapper, e.g. vim.g.bazel_cmd = "blaze".

      -- Inside BUILD/bzl files, use `gd` to jump to the definition under the cursor.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "bzl", "bazel" },
        callback = function(ev)
          vim.keymap.set(
            "n",
            "gd",
            "<cmd>call GoToBazelDefinition()<cr>",
            { buffer = ev.buf, desc = "Go to Bazel definition" }
          )
        end,
      })
    end,
  },

  -- Register the which-key group label for the Bazel keymaps.
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>bz", group = "bazel" },
      },
    },
  },

  -- Ensure the Starlark parser is installed for BUILD/bzl highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "starlark" } },
  },
}
