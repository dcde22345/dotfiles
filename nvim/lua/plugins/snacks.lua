return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          yank_relative_path = function(picker)
            local items = picker:selected({ fallback = true })
            local paths = vim.tbl_map(function(item)
              return vim.fn.fnamemodify(Snacks.picker.util.path(item), ":.")
            end, items)
            local value = table.concat(paths, "\n")
            vim.fn.setreg("+", value)
            Snacks.notify.info("Yanked relative path: " .. value)
          end,
          yank_absolute_path = function(picker)
            local items = picker:selected({ fallback = true })
            local paths = vim.tbl_map(function(item)
              return Snacks.picker.util.path(item)
            end, items)
            local value = table.concat(paths, "\n")
            vim.fn.setreg("+", value)
            Snacks.notify.info("Yanked absolute path: " .. value)
          end,
        },
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                keys = {
                  ["y"] = "yank_relative_path",
                  ["Y"] = "yank_absolute_path",
                },
              },
            },
          },
          grep = {
            hidden = true,
            ignored = true,
          },
          files = {
            hidden = true,
            ignored = true,
          },
          git_log_line = {
            layout = "default",
          },
        },
      },
    },
  },
}
