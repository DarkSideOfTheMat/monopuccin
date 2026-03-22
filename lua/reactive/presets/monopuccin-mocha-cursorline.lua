local palette = require("monopuccin.palettes").get_palette "mocha"
local presets = require "monopuccin.utils.reactive"

return presets.cursorline("monopuccin-mocha-cursorline", palette)
