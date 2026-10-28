-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki
require("./configs/*")

-- Noctalia applies generated wallpaper colors after the hand-written modules,
-- so configs/common.lua remains a complete fallback if the generated theme
-- is missing or invalid.
local noctalia_ok, noctalia = pcall(function()
  return require("noctalia")
end)
if noctalia_ok and type(noctalia) == "table" and type(noctalia.apply_theme) == "function" then
  local apply_ok, apply_err = pcall(noctalia.apply_theme)
  if not apply_ok then
    io.stderr:write("Noctalia theme failed; keeping hand-written colors: " .. tostring(apply_err) .. "\n")
  end
else
  io.stderr:write("Noctalia theme unavailable; keeping hand-written colors\n")
end
