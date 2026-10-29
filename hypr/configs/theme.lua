local primary = "rgba(39c5bbee)"
local inactive = "rgba(595959aa)"

-- Keep a complete hand-written palette for when Noctalia is unavailable.
hl.config({
  general = {
    col = {
      active_border = { colors = { primary, primary }, angle = 45 },
      inactive_border = inactive,
    },
  },
  decoration = {
    shadow = {
      color = primary,
      color_inactive = primary,
    },
    glow = {
      color = primary,
    },
  },
})

-- Noctalia generates ~/.config/hypr/noctalia.lua from the wallpaper palette.
local noctalia_ok, noctalia = pcall(require, "noctalia")
if noctalia_ok and type(noctalia) == "table" and type(noctalia.apply_theme) == "function" then
  local apply_ok, apply_err = pcall(noctalia.apply_theme)
  if not apply_ok then
    io.stderr:write("Noctalia theme failed; keeping hand-written colors: " .. tostring(apply_err) .. "\n")
  end
else
  io.stderr:write("Noctalia theme unavailable; keeping hand-written colors\n")
end
