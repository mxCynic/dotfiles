-- stylua: ignore start
local terminal = "kitty"
local fileManager = "pkill strata || strata"
local functions = require("configs.function")
-- local menu = "hyprlauncher"
local menu = "pkill rofi || rofi -show drun"
local mainMod = "SUPER + " -- Sets "Windows" key as main modifier
local mxbin = "/home/mx/.mxbin/"

-- StyLua: 本文件整体禁用手工排版以外的格式化，见文末 ignore end。

-- 一些太长的命令放在这里,尽量让hl.bind不会过长,能在一行写完,(在启动格式化的情况下,太长会分成多行)
local cliphist_rofi = "pkill rofi || cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
local cliphist_fuzzel = "pkill fuzzel || cliphist list | fuzzel --dmenu --with-nth=2 --prompt='剪贴板 > ' | cliphist decode | wl-copy"
local hypr_shutdown = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- local closeWindowBind = hl.bind(mainMod .. "D", hl.dsp.window.close())
-- closeWindowBind:set_enabled(true)

hl.bind(mainMod .. "Q", hl.dsp.exec_cmd(terminal), { description = "打开终端" })
hl.bind(mainMod .. "D", hl.dsp.window.close(), { description = "关闭当前窗口" })
hl.bind(mainMod .. "SHIFT + M", hl.dsp.exec_cmd(hypr_shutdown), { description = "退出 Hyprland" })
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(menu), { description = "打开应用菜单" })
hl.bind(mainMod .. "E", hl.dsp.exec_cmd(fileManager), { description = "打开文件管理器" })
hl.bind(mainMod .. "F", hl.dsp.window.float({ action = "toggle" }), { description = "切换浮动窗口" })
-- hl.bind(mainMod .. "P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. "J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. "H", hl.dsp.focus({ direction = "left" }), { description = "聚焦左侧窗口" })
hl.bind(mainMod .. "L", hl.dsp.focus({ direction = "right" }), { description = "聚焦右侧窗口" })
hl.bind(mainMod .. "J", hl.dsp.focus({ workspace = "+1" }), { description = "切换到下一工作区" })
hl.bind(mainMod .. "K", hl.dsp.focus({ workspace = "-1" }), { description = "切换到上一工作区" })
hl.bind(mainMod .. "ALT + J", hl.dsp.exec_cmd(mxbin .. "hypr-swap-workspace +1"), { description = "当前工作区与下一工作区对调" })
hl.bind(mainMod .. "ALT + K", hl.dsp.exec_cmd(mxbin .. "hypr-swap-workspace -1"), { description = "当前工作区与上一工作区对调" })
hl.bind(mainMod .. "SHIFT + H", hl.dsp.layout("swapcol l"), { description = "当前列左移" })
hl.bind(mainMod .. "SHIFT + L", hl.dsp.layout("swapcol r"), { description = "当前列右移" })
hl.bind(mainMod .. "SHIFT + J", hl.dsp.window.move({ workspace = "+1" }), { description = "当前窗口移至下一工作区" })
hl.bind(mainMod .. "SHIFT + K", hl.dsp.window.move({ workspace = "-1" }), { description = "当前窗口移至上一工作区" })
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }), { description = "切换到下一个非空工作区" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "切换到上一个非空工作区" })


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. "" .. key, hl.dsp.focus({ workspace = i }), { description = ("切换到工作区 %d"):format(i) })
  hl.bind(mainMod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = ("当前窗口移至工作区 %d"):format(i) })
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. "W", hl.dsp.workspace.toggle_special("magic"), { description = "切换 magic 特殊工作区" })
hl.bind(mainMod .. "SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }), { description = "当前窗口移至 magic 特殊工作区" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. "mouse_down", hl.dsp.focus({ workspace = "+1" }), { description = "滚轮向下：切换到下一工作区" })
hl.bind(mainMod .. "mouse_up", hl.dsp.focus({ workspace = "-1" }), { description = "滚轮向上：切换到上一工作区" })
hl.bind(mainMod .. "SHIFT + mouse_down", hl.dsp.window.move({ workspace = "+1" }), { description = "滚轮向下：当前窗口移至下一工作区" })
hl.bind(mainMod .. "SHIFT + mouse_up", hl.dsp.window.move({ workspace = "-1" }), { description = "滚轮向上：当前窗口移至上一工作区" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. "mouse:272", hl.dsp.window.drag(), { mouse = true, description = "按住 Super 拖动窗口" })
hl.bind(mainMod .. "mouse:273", hl.dsp.window.resize(), { mouse = true, description = "按住 Super 调整窗口大小" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(mxbin .. "volume-notify mute"), { locked = true, repeating = true, description = "切换音频静音" })
hl.bind("F1", hl.dsp.exec_cmd(mxbin .. "volume-notify mute"), { locked = true, repeating = true, description = "切换音频静音" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(mxbin .. "volume-notify down"), { locked = true, repeating = true, description = "降低音量" })
hl.bind("F2", hl.dsp.exec_cmd(mxbin .. "volume-notify down"), { locked = true, repeating = true, description = "降低音量" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(mxbin .. "volume-notify up"), { locked = true, repeating = true, description = "提高音量" })
hl.bind("F3", hl.dsp.exec_cmd(mxbin .. "volume-notify up"), { locked = true, repeating = true, description = "提高音量" })

hl.bind(mainMod .. "F9", hl.dsp.exec_cmd(mxbin .. "hyprsunsetctl identity"), { repeating = true, description = "重置 hyprsunset" })
hl.bind("F7", hl.dsp.exec_cmd(mxbin .. "hyprsunsetctl gamma -10"), { repeating = true, description = "降低 gamma" })
hl.bind("F8", hl.dsp.exec_cmd(mxbin .. "hyprsunsetctl gamma +10"), { repeating = true, description = "提高 gamma" })
hl.bind(mainMod .. "F7", hl.dsp.exec_cmd(mxbin .. "hyprsunsetctl temperature -2500"), { repeating = true, description = "降低色温" })
hl.bind(mainMod .. "F8", hl.dsp.exec_cmd(mxbin .. "hyprsunsetctl temperature +2500"), { repeating = true, description = "提高色温" })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "切换麦克风静音" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true, description = "提高屏幕亮度" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true, description = "降低屏幕亮度" })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "下一首" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "暂停或继续播放" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "暂停或继续播放" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "上一首" })

-- 截图
hl.bind("CTRL + ALT + A", hl.dsp.exec_cmd("omasnap" .. " --editor overlay"), { description = "打开截图编辑器" })
hl.bind("PRINT", hl.dsp.exec_cmd("omasnap" .. " --capture-fullscreen"), { description = "全屏截图" })


hl.bind(mainMod .. "O", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle", layout_aware = true }), { description = "切换真全屏" })
hl.bind(mainMod .. "SHIFT + O", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "切换伪全屏" })
hl.bind(mainMod .. "S", hl.dsp.window.tag({ tag = "opacity" }), { description = "切换窗口透明标签" })
hl.bind(mainMod .. "A", functions.pin_nofocus.toggle, { description = "固定悬浮窗并禁止自动聚焦" })
hl.bind(mainMod .. "Z", functions.workspace.toggle_empty, { description = "切换空工作区或返回上一工作区" })
hl.bind(mainMod .. "C", hl.dsp.window.center(), { description = "窗口居中" })
hl.bind(mainMod .. "B", hl.dsp.exec_cmd("noctalia msg bar-toggle"), { description = "切换 Noctalia 状态栏" })
hl.bind(mainMod .. "T", hl.dsp.exec_cmd("pkill pavucontrol || pavucontrol"), { description = "打开音量控制面板" })
hl.bind(mainMod .. "X", functions.touchpad.toggle, { description = "切换内置触摸板" })
hl.bind(mainMod .. "TAB", functions.focus.toggle_floating_tiled, { description = "在浮动与平铺窗口间切换焦点" })
hl.bind(mainMod .. "F1", hl.dsp.exec_cmd(mxbin .. "gamemode.sh"), { description = "切换游戏模式" })
hl.bind(mainMod .. "U", hl.dsp.exec_cmd("noctalia msg wallpaper-random"), { description = "随机更换壁纸" })
hl.bind(mainMod .. "I", hl.dsp.exec_cmd(mxbin .. "clipimg"), { description = "剪贴板图片贴图" })
hl.bind(mainMod .. "P", hl.dsp.exec_cmd("skwd-wall-v2"), { description = "打开壁纸选择器" })
hl.bind("CTRL + code:47", hl.dsp.exec_cmd(cliphist_fuzzel), { description = "打开剪贴板历史" })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(mxbin .. "obs-toggle"), { description = "切换 OBS 录制" })

-- Resize mode: SUPER+R toggles the submap; HJKL adjusts the active window.
hl.bind(mainMod .. "R", hl.dsp.submap("resize"), { description = "进入窗口调整模式" })
hl.define_submap("resize", function()
  hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "向左调整窗口宽度" })
  hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true, description = "向右调整窗口宽度" })
  hl.bind("K", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true, description = "向上调整窗口高度" })
  hl.bind("J", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true, description = "向下调整窗口高度" })
  hl.bind(mainMod .. "R", hl.dsp.submap("reset"), { description = "退出窗口调整模式" })
end)

-- stylua: ignore end
