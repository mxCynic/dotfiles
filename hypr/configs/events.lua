if os and os.time then
  math.randomseed(os.time())
end

hl.on("window.open", function(window)
  if math.random() < 0.5 then
    hl.dispatch(hl.dsp.window.tag({ window = window, tag = "opacity" }))
  end
end)

hl.on("window.move_to_workspace", function(window, workspace)
  hl.notification.create({
    text = window.title .. " moved to workspace " .. workspace.name,
    timeout = 4000,
    icon = "ok",
  })
end)
