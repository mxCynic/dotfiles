hl.on("hyprland.start", function()
  hl.exec_cmd("clash-verge")
  hl.exec_cmd("SPlayer")
  hl.exec_cmd("noctalia")
  hl.exec_cmd("udiskie")
  hl.exec_cmd("/home/mx/.mxbin/rime-clipboard-learn.py --import")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  -- 桥接 QQ 原生 Wayland 下隐藏 X11 客户端的剪贴板到 Wayland
  hl.exec_cmd("/home/mx/.cargo/bin/xwayclip")
  hl.exec_cmd("xrdb -merge ~/.Xresources")
  hl.exec_cmd("nwg-look -a")
  hl.exec_cmd("/home/mx/.mxbin/hyprsunsetctl start")

  -- 启动时聚焦在特定屏幕
  hl.dispatch(hl.dsp.focus({ monitor = "DP-1" }))
end)
