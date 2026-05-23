hl.on("hyprland.start", function()
  hl.exec_cmd("clash-verge")
  hl.exec_cmd("SPlayer")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("ashell")
  hl.exec_cmd("udiskie")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("nwg-look -a")
  hl.exec_cmd("/usr/lib/mate-polkit/polkit-mate-authentication-agent-1")
  hl.exec_cmd("sleep 2 && $HOME/.config/hypr/scripts/clipboard.sh")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("hyprlauncher -d")
  -- 先给mako.service加入这些环境变量
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP QT_QPA_PLATFORMTHEME HYPRLAND_INSTANCE_SIGNATURE DBUS_SESSION_BUS_ADDRESS")
  hl.exec_cmd(
    " systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP QT_QPA_PLATFORMTHEME HYPRLAND_INSTANCE_SIGNATURE DBUS_SESSION_BUS_ADDRESS")
  hl.exec_cmd("mako")


  hl.dispatch(hl.dsp.focus({ monitor = "DP-1" }))
end)
