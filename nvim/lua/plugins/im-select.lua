return {
  {
    "keaising/im-select.nvim",
    opts = {
      default_command = "/Users/hank.tsai/.local/bin/macism",
      default_im_select = "com.apple.keylayout.ABC",
      set_default_events = { "InsertLeave", "CmdlineEnter", "CmdlineLeave" },
      set_previous_events = { "InsertEnter" },
      keep_quiet_on_no_binary = true,
      async_switch_im = true,
    },
  },
}
