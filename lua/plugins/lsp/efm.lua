return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      efm = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "json",
          "yaml",
          "markdown",
        },
        init_options = { documentFormatting = true },
        settings = {
          rootMarkers = { ".git/" },
          languages = {
            javascript = {
              {
                formatCommand = "prettierd ${INPUT}",
                formatStdin = true,
              },
            },
            typescript = {
              {
                formatCommand = "prettierd ${INPUT}",
                formatStdin = true,
              },
            },
            json = {
              {
                formatCommand = "prettierd ${INPUT}",
                formatStdin = true,
              },
            },
            -- Add others as needed
          },
        },
      },
    },
  },
}
