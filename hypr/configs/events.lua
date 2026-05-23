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
