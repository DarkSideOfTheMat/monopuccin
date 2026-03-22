# Monopuccin

Monokai-style syntax highlighting with [Catppuccin](https://github.com/catppuccin/catppuccin)'s soothing pastel palette.

Monopuccin remaps Catppuccin's syntax highlight assignments to follow Monokai's color philosophy while keeping the full Catppuccin color palette and all 4 flavors (Latte, Frappe, Macchiato, Mocha).

## Color Philosophy

| Syntax Element       | Color     | Catppuccin Palette |
|---------------------|-----------|--------------------|
| Keywords/Operators  | Pink      | `pink`             |
| Strings             | Yellow    | `yellow`           |
| Functions           | Green     | `green`            |
| Types/Built-ins     | Cyan      | `sapphire`         |
| Constants/Numbers   | Purple    | `mauve`            |
| Parameters          | Orange    | `peach`            |
| Comments            | Gray      | `overlay0`         |
| Variables           | Text      | `text`             |

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "DarkSideOfTheMat/monopuccin",
    name = "monopuccin",
    priority = 1000,
    opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { "DarkSideOfTheMat/monopuccin", as = "monopuccin" }
```

## Usage

```lua
require("monopuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
})

vim.cmd.colorscheme "monopuccin"
```

You can also use flavor-specific colorschemes directly:

```vim
colorscheme monopuccin-mocha
colorscheme monopuccin-macchiato
colorscheme monopuccin-frappe
colorscheme monopuccin-latte
```

## Configuration

Monopuccin inherits all configuration options from catppuccin/nvim. See the [catppuccin/nvim documentation](https://github.com/catppuccin/nvim#configuration) for the full list of options.

```lua
require("monopuccin").setup({
    flavour = "mocha",
    transparent_background = false,
    no_italic = false,
    no_bold = false,
    styles = {
        comments = { "italic" },
        conditionals = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
    },
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = { enabled = true },
        -- See catppuccin/nvim docs for the full list
    },
})
```

## Credits

Built on [catppuccin/nvim](https://github.com/catppuccin/nvim) (MIT License). All palette colors, integrations, and infrastructure come from the Catppuccin project. Monopuccin modifies only the syntax highlight color assignments to follow Monokai's highlighting conventions.
