local palette = require("monopuccin.palettes").get_palette "macchiato"
local presets = require "monopuccin.utils.reactive"
local darken = require("monopuccin.utils.colors").darken

local preset = presets.cursorline("monopuccin-macchiato-cursorline", palette)

preset.static.winhl.inactive.CursorLine = { bg = darken(palette.surface0, 0.8) }
preset.static.winhl.inactive.CursorLineNr = { bg = darken(palette.surface0, 0.8) }

return preset
