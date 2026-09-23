-- ESLint config files, ordered so flat config wins over legacy eslintrc.
local eslint_config_files = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- Lint as you type instead of only on save
            run = "onType",
            -- Report on files that are ignored by .eslintignore / ignores
            quiet = false,
          },
          -- Root the server at the nearest ESLint config instead of the
          -- monorepo lockfile root. lspconfig's default roots every package at
          -- the workspace root, so a single server process loads several
          -- `eslint.config.*` files. typescript-eslint records the directory of
          -- each config it loads in a process-global set, and then refuses to
          -- infer `tsconfigRootDir` once that set holds more than one entry:
          --   "No tsconfigRootDir was set, and multiple candidate
          --    TSConfigRootDirs are present"
          -- Rooting per package gives one server per package, so only a single
          -- candidate is ever registered.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == "" then
              return
            end

            -- Deno projects use their own linter.
            if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
              return
            end

            local config = vim.fs.find(eslint_config_files, {
              path = fname,
              upward = true,
              type = "file",
              limit = 1,
            })[1]

            -- No ESLint config anywhere above the file: don't attach.
            if not config then
              return
            end

            on_dir(vim.fs.dirname(config))
          end,
        },
      },
    },
  },
}
