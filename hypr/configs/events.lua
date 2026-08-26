if os and os.time then
  math.randomseed(os.time())
end

local always_opaque_classes = {
  flameshot = true,
  cs2 = true,
}

local always_transparent_classes = {
  kitty = true,
  ["org.telegram.desktop"] = true,
}

hl.on("window.open", function(window)
  if always_opaque_classes[window.class] then
    return
  end

  if always_transparent_classes[window.class] then
    hl.dispatch(hl.dsp.window.tag({ window = window, tag = "opacity" }))
    return
  end

  if math.random() < 0.5 then
    hl.dispatch(hl.dsp.window.tag({ window = window, tag = "opacity" }))
  end
end)

hl.on("window.move_to_workspace", function(window, workspace)
  local text = window.title .. " moved to workspace " .. workspace.name
  hl.exec_cmd("notify-send " .. string.format("%q", text))
end)

hl.on("workspace.active", function(workspace)
  local text = "active workspace " .. workspace.name
  hl.exec_cmd("notify-send " .. string.format("%q", text))
end)

-- confine_pointer 的游戏重新获得焦点时,把鼠标拉回窗口中心:
-- 避免切走工作区/弹窗抢焦点后,鼠标停在窗口外,被 confine 钳在窗口边缘导致"卡鼠标"。
local confine_pointer_games = {
  ["cs2"]  = "class",
  ["原神"] = "title",
}

hl.on("window.active", function(window)
  if not window then
    return
  end

  local by = confine_pointer_games[window.class] or confine_pointer_games[window.title]
  if not by then
    return
  end

  local pos  = window.at
  local size = window.size
  if not pos or not size then
    return
  end

  hl.dispatch(hl.dsp.cursor.move({ x = pos.x + size.x / 2, y = pos.y + size.y / 2 }))
end)
