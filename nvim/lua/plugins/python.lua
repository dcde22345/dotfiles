return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
          },
        },
        ruff = { enabled = false },
      },
    },
  },
}
