return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          -- Disable problematic diagnostics
          settings = {
            experimental = {
              useFlatConfig = false,
            },
          },
          on_attach = function(client)
            -- Fully disable diagnostics from eslint, if necessary
            client.server_capabilities.diagnosticProvider = nil
          end,
        },
      },
    },
  },
}
