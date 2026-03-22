local function reload()
	for name, _ in pairs(package.loaded) do
		if name:match "^monopuccin" then package.loaded[name] = nil end
	end
	vim.g.monopuccin_flavour = nil
	vim.cmd [[highlight clear]]
end

-- TODO: Move this to setup_spec
describe("get palette", function()
	before_each(function() reload() end)
	it("before setup", function()
		assert.equals(pcall(function() require("monopuccin.palettes").get_palette() end), true)
	end)
	it("after setup", function()
		require("monopuccin").setup()
		assert.equals(pcall(function() require("monopuccin.palettes").get_palette() end), true)
	end)
end)
