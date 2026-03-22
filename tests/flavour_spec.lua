local function reload()
	for name, _ in pairs(package.loaded) do
		if name:match "^monopuccin" then package.loaded[name] = nil end
	end
	vim.g.monopuccin_flavour = nil
	vim.cmd [[highlight clear]]
end

describe("set background to", function()
	before_each(function()
		reload()
		vim.cmd.colorscheme "monopuccin-nvim"
	end)
	it("light", function()
		vim.o.background = "light"
		assert.equals("monopuccin-latte", vim.g.colors_name)
	end)
	it("dark", function()
		vim.o.background = "dark"
		assert.equals("monopuccin-mocha", vim.g.colors_name)
	end)
end)

describe("respect vim.o.background =", function()
	before_each(function() reload() end)
	it("light", function()
		vim.o.background = "light"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-latte", vim.g.colors_name)
	end)
	it("dark", function()
		vim.o.background = "dark"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-mocha", vim.g.colors_name)
	end)
end)

describe("change flavour to", function()
	before_each(function() reload() end)
	it("latte", function()
		vim.cmd.colorscheme "monopuccin-latte"
		assert.equals("monopuccin-latte", vim.g.colors_name)
	end)
	it("frappe", function()
		vim.cmd.colorscheme "monopuccin-frappe"
		assert.equals("monopuccin-frappe", vim.g.colors_name)
	end)
	it("macchiato", function()
		vim.cmd.colorscheme "monopuccin-macchiato"
		assert.equals("monopuccin-macchiato", vim.g.colors_name)
	end)
	it("mocha", function()
		vim.cmd.colorscheme "monopuccin-mocha"
		assert.equals("monopuccin-mocha", vim.g.colors_name)
	end)
end)

describe("respect setup flavour =", function()
	before_each(function() reload() end)
	it("latte", function()
		require("monopuccin").setup { flavour = "latte" }
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-latte", vim.g.colors_name)
	end)
	it("frappe", function()
		require("monopuccin").setup { flavour = "frappe" }
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-frappe", vim.g.colors_name)
	end)
	it("macchiato", function()
		require("monopuccin").setup { flavour = "macchiato" }
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-macchiato", vim.g.colors_name)
	end)
	it("mocha", function()
		require("monopuccin").setup { flavour = "mocha" }
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-mocha", vim.g.colors_name)
	end)
end)

describe("(deprecated) respect vim.g.monopuccin_flavour =", function()
	before_each(function() reload() end)
	it("latte", function()
		vim.g.monopuccin_flavour = "latte"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-latte", vim.g.colors_name)
	end)
	it("frappe", function()
		vim.g.monopuccin_flavour = "frappe"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-frappe", vim.g.colors_name)
	end)
	it("macchiato", function()
		vim.g.monopuccin_flavour = "macchiato"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-macchiato", vim.g.colors_name)
	end)
	it("mocha", function()
		vim.g.monopuccin_flavour = "mocha"
		vim.cmd.colorscheme "monopuccin-nvim"
		assert.equals("monopuccin-mocha", vim.g.colors_name)
	end)
end)
