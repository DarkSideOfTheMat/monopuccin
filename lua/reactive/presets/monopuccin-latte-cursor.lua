local palette = require("monopuccin.palettes").get_palette "latte"
local presets = require "monopuccin.utils.reactive"

local preset = presets.cursor("monopuccin-latte-cursor", palette)

preset.modes.R.hl.ReactiveCursor = { bg = palette.flamingo }

return preset
