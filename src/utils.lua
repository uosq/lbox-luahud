local utils = {}

---@alias RGB {[1]: integer, [2]: integer, [3]: integer}

---@param color RGB?
---@param x integer
---@param y integer
---@param text string
function utils.DrawText(color, x, y, text)
	draw.Color(41, 46, 57, 255)
	draw.Text(x + 2, y + 2, text)

	if color then
		draw.Color(color[1], color[2], color[3], 255)
	else
		draw.Color(236, 239, 244, 255)
	end
	draw.Text(x, y, text)
end

-- i will not lie, i asked AI to do this
--- but only this function was made by AI
--- the other ones were made by me (thats why they are shit LOL)
---@param font_size integer
---@param x integer
---@param y integer
---@param text string
---@param maxWidth integer
---@param drawNow boolean
---@return integer
function utils.DrawColoredText(font_size, x, y, text, maxWidth, drawNow)
	local defaultColor = { 255, 255, 255, 255 }
	local lineHeight = font_size + 2
	local currentColor = defaultColor
	local cursorX = x
	local cursorY = y
	local usedHeight = lineHeight

	local function parseTag(s)
		local r, g, b, a = 255, 255, 255, 255
		if #s == 6 then
			r = tonumber(s:sub(1, 2), 16) or 255
			g = tonumber(s:sub(3, 4), 16) or 255
			b = tonumber(s:sub(5, 6), 16) or 255
		elseif #s == 8 then
			r = tonumber(s:sub(1, 2), 16) or 255
			g = tonumber(s:sub(3, 4), 16) or 255
			b = tonumber(s:sub(5, 6), 16) or 255
			a = tonumber(s:sub(7, 8), 16) or 255
		end
		return r, g, b, a
	end

	local segments = {}
	local i = 1
	while i <= #text do
		local tagStart, tagEnd, hex = text:find("{#([%x]+)}", i)
		if tagStart then
			if tagStart > i then
				table.insert(segments, { color = currentColor, text = text:sub(i, tagStart - 1) })
			end
			currentColor = { parseTag(hex) }
			i = tagEnd + 1
		else
			table.insert(segments, { color = currentColor, text = text:sub(i) })
			break
		end
	end

	for _, seg in ipairs(segments) do
		local color = seg.color
		local chunk = seg.text

		while #chunk > 0 do
			local word = chunk:match("^%S+%s*") or chunk
			if not word or word == "" then
				break
			end

			local wordW = draw.GetTextSize(word)

			if cursorX + wordW > x + maxWidth then
				-- Too wide for line, need to split it further by characters
				for c in word:gmatch(".") do
					local charW = draw.GetTextSize(c)
					if cursorX + charW > x + maxWidth then
						cursorX = x
						cursorY = cursorY + lineHeight
						usedHeight = usedHeight + lineHeight
					end
					if drawNow then
						draw.Color(table.unpack(color))
						draw.Text(cursorX, cursorY, c)
					end
					cursorX = cursorX + charW
				end
			else
				if drawNow then
					draw.Color(table.unpack(color))
					draw.Text(cursorX, cursorY, word)
				end
				cursorX = cursorX + wordW
			end

			chunk = chunk:sub(#word + 1)
			if chunk == "" then
				break
			end
		end
	end

	return usedHeight
end

function utils:DrawCrosshair(pWeapon, center_x, center_y)
	local size = 8
	local spread = pWeapon:GetWeaponSpread()
	if spread then
		size = size * (1 + (spread * 10)) // 1
	end

	draw.Color(136, 192, 208, 255)
	draw.Line(center_x, center_y, center_x + size, center_y) -- x--
	draw.Line(center_x - size, center_y, center_x, center_y) -- --x
	draw.Line(center_x, center_y - size, center_x, center_y + size) -- center to top
	draw.Line(center_x, center_y, center_x, center_y + size) -- center to bottom
end

return utils
