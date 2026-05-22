return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      nix = { "alejandra" },
      rust = { "rustfmt" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      graphql = { "prettier" },
    },
    formatters = {
      prettier = {
        -- Ensure conform uses the project's prettier from node_modules
        -- Falls back to global if not found
        command = function(self, bufnr)
          local util = require("conform.util")
          local cwd = vim.fn.getcwd()
          -- Try to find local prettier first
          local local_prettier = cwd .. "/node_modules/.bin/prettier"
          if vim.fn.executable(local_prettier) == 1 then
            return local_prettier
          end
          -- Try package root (for monorepo)
          local root = util.root_file({ "package.json", ".git" })(self, bufnr)
          if root then
            local root_prettier = root .. "/node_modules/.bin/prettier"
            if vim.fn.executable(root_prettier) == 1 then
              return root_prettier
            end
          end
          return "prettier"
        end,
      },
    },
  },
}
