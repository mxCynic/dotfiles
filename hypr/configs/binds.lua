local terminal = "kitty"
local fileManager = "pkill dolphin || dolphin"
-- local menu = "hyprlauncher"
local menu = "pkill rofi || rofi -show drun"
local mainMod = "SUPER + " -- Sets "Windows" key as main modifier
local mxbin = "/home/mx/.mxbin/"

-- 一些太长的命令放在这里,尽量让hl.bind不会过长,能在一行写完,(在启动格式化的情况下,太长会分成多行)
local cliphist_rofi = "pkill rofi || cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
local hypr_shutdown = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- local closeWindowBind = hl.bind(mainMod .. "D", hl.dsp.window.close())
-- closeWindowBind:set_enabled(true)

hl.bind(mainMod .. "Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "D", hl.dsp.window.close())
hl.bind(mainMod .. "SHIFT + M", hl.dsp.exec_cmd(hypr_shutdown))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "F", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. "P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. "J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. "H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "J", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. "K", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. "SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. "SHIFT + J", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. "SHIFT + K", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. "" .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. "W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. "SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. "mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. "mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. "SHIFT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. "SHIFT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(mxbin .. "volume-notify mute"), { locked = true, repeating = true })
hl.bind("F1", hl.dsp.exec_cmd(mxbin .. "volume-notify mute"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(mxbin .. "volume-notify down"), { locked = true, repeating = true })
hl.bind("F2", hl.dsp.exec_cmd(mxbin .. "volume-notify down"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(mxbin .. "volume-notify up"), { locked = true, repeating = true })
hl.bind("F3", hl.dsp.exec_cmd(mxbin .. "volume-notify up"), { locked = true, repeating = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


hl.bind(mainMod .. "O", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. "SHIFT + O", hl.dsp.window.fullscreen())
hl.bind(mainMod .. "S", hl.dsp.window.tag({ tag = "opacity" })) -- toggle 窗口的透明
hl.bind(mainMod .. "A", hl.dsp.window.pin())
hl.bind(mainMod .. "C", hl.dsp.window.center())
hl.bind(mainMod .. "B", hl.dsp.exec_cmd("pkill ashell || ashell"))
hl.bind(mainMod .. "T", hl.dsp.exec_cmd("pkill pavucontrol || pavucontrol"))
hl.bind(mainMod .. "SHIFT + Q", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + code:47", hl.dsp.exec_cmd(cliphist_rofi))
hl.bind("CTRL + ALT + A", hl.dsp.exec_cmd(mxbin .. "flameshot-gui"))
hl.bind(mainMod .. "F1", hl.dsp.exec_cmd(mxbin .. "gamemode.sh"))
hl.bind(mainMod .. "U", hl.dsp.exec_cmd(mxbin .. "chwp"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(mxbin .. "obs-toggle"))
hl.bind(mainMod .. "N", hl.dsp.exec_cmd(mxbin .. "wl-clicker --cps 20 --count 100"))
