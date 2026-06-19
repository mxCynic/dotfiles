hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.dsp.focus({ workspace = "-1" })
  end
})
hl.gesture({
  fingers = 3,
  direction = "down",
  action = function()
    hl.dsp.focus({ workspace = "+1" })
  end
})

hl.gesture({
  fingers = 3,
  direction = "pinch",
  action = "fullscreen"
})
