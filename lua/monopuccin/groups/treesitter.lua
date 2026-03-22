local M = {}

function M.get()
	if vim.treesitter.highlighter.hl_map then
		vim.notify_once(
			[[Monopuccin (info):
nvim-treesitter integration requires neovim 0.8
If you want to stay on nvim 0.7, pin monopuccin tag to v0.2.4 and nvim-treesitter commit to 4cccb6f494eb255b32a290d37c35ca12584c74d0.
]],
			vim.log.levels.INFO
		)
		return {}
	end

	local colors = { -- Reference: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md
		-- Identifiers
		["@variable"] = { fg = C.text, style = O.styles.variables or {} }, -- Any variable name that does not have another highlight.
		["@variable.builtin"] = { fg = C.subtext1, style = { "italic" } }, -- Variable names that are defined by the languages, like this or self.
		["@variable.parameter"] = { fg = C.peach, style = { "italic" } }, -- For parameters of a function.
		["@variable.member"] = { fg = C.text }, -- For fields.

		["@constant"] = { link = "Constant" }, -- For constants
		["@constant.builtin"] = { fg = C.mauve, style = O.styles.keywords or {} }, -- For constant that are built in the language: nil in Lua.
		["@constant.macro"] = { link = "Macro" }, -- For constants that are defined by macros: NULL in C.

		["@module"] = { fg = C.sapphire, style = O.styles.miscs or { "italic" } }, -- For identifiers referring to modules and namespaces.
		["@label"] = { fg = C.sapphire }, -- For labels: label: in C and :label: in Lua.

		-- Literals
		["@string"] = { link = "String" }, -- For strings.
		["@string.documentation"] = { fg = C.overlay0, style = O.styles.strings or {} }, -- For strings documenting code (e.g. Python docstrings).
		["@string.regexp"] = { fg = C.yellow, style = O.styles.strings or {} }, -- For regexes.
		["@string.escape"] = { fg = C.mauve, style = O.styles.strings or {} }, -- For escape characters within a string.
		["@string.special"] = { link = "Special" }, -- other special strings (e.g. dates)
		["@string.special.path"] = { link = "Special" }, -- filenames
		["@string.special.symbol"] = { fg = C.flamingo }, -- symbols or atoms
		["@string.special.url"] = { fg = C.blue, style = { "italic", "underline" } }, -- urls, links and emails
		["@punctuation.delimiter.regex"] = { link = "@string.regexp" },

		["@character"] = { fg = C.yellow }, -- character literals
		["@character.special"] = { link = "SpecialChar" }, -- special characters (e.g. wildcards)

		["@boolean"] = { link = "Boolean" }, -- For booleans.
		["@number"] = { link = "Number" }, -- For all numbers
		["@number.float"] = { link = "Float" }, -- For floats.

		-- Types
		["@type"] = { link = "Type" }, -- For types.
		["@type.builtin"] = { fg = C.sapphire, style = { "italic" } }, -- For builtin types.
		["@type.definition"] = { fg = C.green }, -- type definitions (e.g. `typedef` in C)

		["@attribute"] = { fg = C.green }, -- attribute annotations (e.g. Python decorators)
		["@property"] = { fg = C.text, style = O.styles.properties or {} }, -- For fields, like accessing `bar` property on `foo.bar`. Overriden later for data languages and CSS.

		-- Functions
		["@function"] = { link = "Function" }, -- For function (calls and definitions).
		["@function.builtin"] = { fg = C.green, style = O.styles.functions or {} }, -- For builtin functions: table.insert in Lua.
		["@function.call"] = { link = "Function" }, -- function calls
		["@function.macro"] = { fg = C.green, style = O.styles.functions or {} }, -- For macro defined functions (calls and definitions): each macro_rules in Rust.

		["@function.method"] = { link = "Function" }, -- For method definitions.
		["@function.method.call"] = { link = "Function" }, -- For method calls.

		["@constructor"] = { fg = C.green }, -- For constructor calls and definitions: = { } in Lua, and Java constructors.
		["@operator"] = { link = "Operator" }, -- For any operator: +, but also -> and * in C.

		-- Keywords
		["@keyword"] = { link = "Keyword" }, -- For keywords that don't fall in previous categories.
		["@keyword.modifier"] = { link = "Keyword" }, -- For keywords modifying other constructs (e.g. `const`, `static`, `public`)
		["@keyword.type"] = { fg = C.sapphire, style = { "italic" } }, -- For keywords describing composite types (e.g. `struct`, `enum`)
		["@keyword.coroutine"] = { link = "Keyword" }, -- For keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
		["@keyword.function"] = { fg = C.sapphire, style = { "italic" } }, -- For keywords used to define a function.
		["@keyword.operator"] = { fg = C.red, style = O.styles.keywords or {} }, -- For new keyword operator
		["@keyword.import"] = { link = "Include" }, -- For includes: #include in C, use or extern crate in Rust, or require in Lua.
		["@keyword.repeat"] = { link = "Repeat" }, -- For keywords related to loops.
		["@keyword.return"] = { fg = C.red, style = O.styles.keywords or {} },
		["@keyword.debug"] = { link = "Exception" }, -- For keywords related to debugging
		["@keyword.exception"] = { link = "Exception" }, -- For exception related keywords.

		["@keyword.conditional"] = { link = "Conditional" }, -- For keywords related to conditionnals.
		["@keyword.conditional.ternary"] = { link = "Operator" }, -- For ternary operators (e.g. `?` / `:`)

		["@keyword.directive"] = { link = "PreProc" }, -- various preprocessor directives & shebangs
		["@keyword.directive.define"] = { link = "Define" }, -- preprocessor definition directives
		-- JS & derivative
		["@keyword.export"] = { fg = C.red, style = O.styles.keywords },

		-- Punctuation
		["@punctuation.delimiter"] = { fg = C.overlay1 }, -- For delimiters (e.g. `;` / `.` / `,`).
		["@punctuation.bracket"] = { fg = C.red }, -- For brackets and parenthesis.
		["@punctuation.special"] = { fg = C.overlay1 }, -- For special punctuation that does not fall in the categories before (e.g. `{}` in string interpolation).

		-- Comment
		["@comment"] = { link = "Comment" },
		["@comment.documentation"] = { link = "Comment" }, -- For comments documenting code

		["@comment.error"] = { fg = C.base, bg = C.red },
		["@comment.warning"] = { fg = C.base, bg = C.yellow },
		["@comment.hint"] = { fg = C.base, bg = C.blue },
		["@comment.todo"] = { fg = C.base, bg = C.flamingo },
		["@comment.note"] = { fg = C.base, bg = C.rosewater },

		-- Markup
		["@markup"] = { fg = C.text }, -- For strings considerated text in a markup language.
		["@markup.strong"] = { fg = C.text, style = { "bold" } }, -- bold
		["@markup.italic"] = { fg = C.text, style = { "italic" } }, -- italic
		["@markup.strikethrough"] = { fg = C.text, style = { "strikethrough" } }, -- strikethrough text
		["@markup.underline"] = { link = "Underlined" }, -- underlined text

		["@markup.heading"] = { fg = C.green, style = { "bold" } }, -- titles like: # Example
		["@markup.heading.markdown"] = { style = { "bold" } }, -- bold headings in markdown, but not in HTML or other markup

		["@markup.math"] = { fg = C.blue }, -- math environments (e.g. `$ ... $` in LaTeX)
		["@markup.quote"] = { fg = C.pink }, -- block quotes
		["@markup.environment"] = { fg = C.pink }, -- text environments of markup languages
		["@markup.environment.name"] = { fg = C.blue }, -- text indicating the type of an environment

		["@markup.link"] = { fg = C.peach, style = { "underline" } }, -- text references, footnotes, citations, etc.
		["@markup.link.label"] = { fg = C.peach }, -- link, reference descriptions
		["@markup.link.url"] = { fg = C.peach, style = { "italic", "underline" } }, -- urls, links and emails

		["@markup.raw"] = { fg = C.yellow }, -- used for inline code in markdown and for doc in python (""")

		["@markup.list"] = { fg = C.teal },
		["@markup.list.checked"] = { fg = C.green }, -- todo notes
		["@markup.list.unchecked"] = { fg = C.overlay1 }, -- todo notes

		-- Diff
		["@diff.plus"] = { link = "diffAdded" }, -- added text (for diff files)
		["@diff.minus"] = { link = "diffRemoved" }, -- deleted text (for diff files)
		["@diff.delta"] = { link = "diffChanged" }, -- deleted text (for diff files)

		-- Tags
		["@tag"] = { fg = C.red }, -- Tags like HTML tag names.
		["@tag.builtin"] = { fg = C.red }, -- JSX tag names.
		["@tag.attribute"] = { fg = C.sapphire, style = { "italic" } }, -- XML/HTML attributes (foo in foo="bar").
		["@tag.delimiter"] = { fg = C.overlay1 }, -- Tag delimiter like < > /

		-- Misc
		["@error"] = { link = "Error" },

		-- Language specific:

		-- Bash
		["@function.builtin.bash"] = { fg = C.red, style = O.styles.miscs or { "italic" } },
		["@variable.parameter.bash"] = { fg = C.peach },

		-- markdown
		["@markup.heading.1.markdown"] = { link = "rainbow1" },
		["@markup.heading.2.markdown"] = { link = "rainbow2" },
		["@markup.heading.3.markdown"] = { link = "rainbow3" },
		["@markup.heading.4.markdown"] = { link = "rainbow4" },
		["@markup.heading.5.markdown"] = { link = "rainbow5" },
		["@markup.heading.6.markdown"] = { link = "rainbow6" },

		-- html
		["@markup.heading.html"] = { link = "@markup" },
		["@markup.heading.1.html"] = { link = "@markup" },
		["@markup.heading.2.html"] = { link = "@markup" },
		["@markup.heading.3.html"] = { link = "@markup" },
		["@markup.heading.4.html"] = { link = "@markup" },
		["@markup.heading.5.html"] = { link = "@markup" },
		["@markup.heading.6.html"] = { link = "@markup" },

		-- Java
		["@constant.java"] = { fg = C.teal },

		-- CSS
		["@property.css"] = { fg = C.blue },
		["@property.scss"] = { fg = C.blue },
		["@property.id.css"] = { fg = C.yellow },
		["@property.class.css"] = { fg = C.yellow },
		["@type.css"] = { fg = C.lavender },
		["@type.tag.css"] = { fg = C.blue },
		["@string.plain.css"] = { fg = C.text },
		["@number.css"] = { fg = C.peach },
		["@keyword.directive.css"] = { link = "Keyword" }, -- CSS at-rules: https://developer.mozilla.org/en-US/docs/Web/CSS/At-rule.

		-- HTML
		["@string.special.url.html"] = { fg = C.green }, -- Links in href, src attributes.
		["@markup.link.label.html"] = { fg = C.text }, -- Text between <a></a> tags.
		["@character.special.html"] = { fg = C.red }, -- Symbols such as &nbsp;.

		-- Lua
		["@constructor.lua"] = { link = "@punctuation.bracket" }, -- For constructor calls and definitions: = { } in Lua.

		-- Go
		["@type.definition.go"] = { fg = C.green }, -- type names in type declarations

		-- Python
		["@constructor.python"] = { fg = C.green }, -- __init__(), __new__().

		-- YAML
		["@label.yaml"] = { fg = C.yellow }, -- Anchor and alias names.

		-- Ruby
		["@string.special.symbol.ruby"] = { fg = C.flamingo },

		-- PHP
		["@function.method.php"] = { link = "Function" },
		["@function.method.call.php"] = { link = "Function" },

		-- C/CPP
		["@keyword.import.c"] = { fg = C.red },
		["@keyword.import.cpp"] = { fg = C.red },

		-- C#
		["@attribute.c_sharp"] = { fg = C.green },

		-- gitcommit
		["@comment.warning.gitcommit"] = { fg = C.yellow },

		-- gitignore
		["@string.special.path.gitignore"] = { fg = C.text },

		-- Misc
		gitcommitSummary = { fg = C.rosewater, style = O.styles.miscs or { "italic" } },
		zshKSHFunction = { link = "Function" },
	}

	-- Legacy highlights
	colors["@parameter"] = colors["@variable.parameter"]
	colors["@field"] = colors["@variable.member"]
	colors["@namespace"] = colors["@module"]
	colors["@float"] = colors["@number.float"]
	colors["@symbol"] = colors["@string.special.symbol"]
	colors["@string.regex"] = colors["@string.regexp"]

	colors["@text"] = colors["@markup"]
	colors["@text.strong"] = colors["@markup.strong"]
	colors["@text.emphasis"] = colors["@markup.italic"]
	colors["@text.underline"] = colors["@markup.underline"]
	colors["@text.strike"] = colors["@markup.strikethrough"]
	colors["@text.uri"] = colors["@markup.link.url"]
	colors["@text.math"] = colors["@markup.math"]
	colors["@text.environment"] = colors["@markup.environment"]
	colors["@text.environment.name"] = colors["@markup.environment.name"]

	colors["@text.title"] = colors["@markup.heading"]
	colors["@text.literal"] = colors["@markup.raw"]
	colors["@text.reference"] = colors["@markup.link"]

	colors["@text.todo.checked"] = colors["@markup.list.checked"]
	colors["@text.todo.unchecked"] = colors["@markup.list.unchecked"]

	colors["@comment.note"] = colors["@comment.hint"]

	-- @text.todo is now for todo comments, not todo notes like in markdown
	colors["@text.todo"] = colors["@comment.todo"]
	colors["@text.warning"] = colors["@comment.warning"]
	colors["@text.note"] = colors["@comment.note"]
	colors["@text.danger"] = colors["@comment.error"]

	-- @text.uri is now
	-- > @markup.link.url in markup links
	-- > @string.special.url outside of markup
	colors["@text.uri"] = colors["@markup.link.uri"]

	colors["@method"] = colors["@function.method"]
	colors["@method.call"] = colors["@function.method.call"]

	colors["@text.diff.add"] = colors["@diff.plus"]
	colors["@text.diff.delete"] = colors["@diff.minus"]

	colors["@type.qualifier"] = colors["@keyword.modifier"]
	colors["@keyword.storage"] = colors["@keyword.modifier"]
	colors["@define"] = colors["@keyword.directive.define"]
	colors["@preproc"] = colors["@keyword.directive"]
	colors["@storageclass"] = colors["@keyword.storage"]
	colors["@conditional"] = colors["@keyword.conditional"]
	colors["@exception"] = colors["@keyword.exception"]
	colors["@include"] = colors["@keyword.import"]
	colors["@repeat"] = colors["@keyword.repeat"]

	colors["@symbol.ruby"] = colors["@string.special.symbol.ruby"]

	colors["@variable.member.yaml"] = colors["@field.yaml"]

	colors["@text.title.1.markdown"] = colors["@markup.heading.1.markdown"]
	colors["@text.title.2.markdown"] = colors["@markup.heading.2.markdown"]
	colors["@text.title.3.markdown"] = colors["@markup.heading.3.markdown"]
	colors["@text.title.4.markdown"] = colors["@markup.heading.4.markdown"]
	colors["@text.title.5.markdown"] = colors["@markup.heading.5.markdown"]
	colors["@text.title.6.markdown"] = colors["@markup.heading.6.markdown"]

	colors["@method.php"] = colors["@function.method.php"]
	colors["@method.call.php"] = colors["@function.method.call.php"]

	return colors
end

return M
