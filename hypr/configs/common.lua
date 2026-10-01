hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border = { colors = { "rgba(39c5bbee)", "rgba(39c5bbee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing = true,

    snap = {
      enabled        = true,
      window_gap     = 5,
      monitor_gap    = 5,
      border_overlap = true,
      respect_gaps   = false,

    }
  },


  decoration = {
    rounding = 10,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      sharp = true,
      color = "rgba(39c5bbee)",
      color_inactive = "rgba(39c5bbee)",
      offset = { 0, 0 },
      scale = 1,

    },

    blur = {
      enabled = false,
      size = 5,
      passes = 1,
      vibrancy = 0.1696,
      xray = false,
      variant = "drops",
    },

    glow = {
      enabled = false,
      range = 10,
      render_power = 1,
      color = "rgba(39c5bbee)",
      --color_inactive = 1,

    },
    wobble = {
      enabled = false,
    }
  },


  misc = {
    force_default_wallpaper = -1,  -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
  },

  binds = {
    movefocus_cycles_fullscreen = true
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  }
})
