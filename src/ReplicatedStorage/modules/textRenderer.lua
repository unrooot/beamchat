-- currently unused
local lib = {}

local gsub = string.gsub
local gmatch = string.gmatch
local format = string.format
local split = string.split

function lib.toSyntax(str)
	local formatted = str
	local patterns = {
		["{bold,italic:%s}"] = {"%*%*_(.-)_%*%*", "_%*%*(.-)%*%*_"},
		["{bold:%s}"] = "%*%*(.-)%*%*",
		["{italic:%s}"] = "_(.-)_",
		["{emote:%s}"] = ":(.-):"
	}

	for i,v in pairs(patterns) do
		if typeof(v) == "string" then
			for match in gmatch(formatted, v) do
				formatted = gsub(formatted, v, format(i, match))
			end
		elseif typeof(v) == "table" then
			for _,x in pairs(v) do
				for match in gmatch(formatted, x) do
					formatted = gsub(formatted, x, format(i, match))
				end
			end
		end
	end

	return formatted
end

--[[

raw:
yo guys, what the **heck** is _up?????_ y'all eatin _**beans**_??

converted:
yo guys, what the {bold:heck} is {italic:up?????} y'all eatin {bold,italic:beans}??

added:
{bold,c3(172, 56, 38):unroot:} yo guys, what the {bold:heck} is {italic:up?????} y'all eatin {bold,italic:beans}??

--]]

function lib.render(str, parent)
	-- get each special string
	for match in gmatch(str, "{(.-)}") do
		local parameters = split(str, ",")
		if #parameters > 1 then

		end
	end
end

return lib