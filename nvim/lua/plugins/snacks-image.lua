return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = false,
      },
    },
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
        html = {
          enabled = true,
        },
        css = {
          enabled = true,
        },
      },
      max_width_window_percentage = 100,
      max_height_window_percentage = 100,
      scale_factor = 1.0,
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
    },
  },
}
