local spy = {}

---@param plocal Entity
---@param current_weapon Entity
---@param info Info
---@param utils Utils
function spy:Run(plocal, current_weapon, info, utils)
	local cloak = plocal:GetPropFloat("m_flCloakMeter")
	local cloak_ratio = cloak / 100 --- 100 is max cloak
	local width, height = 100, 10
	local x, y = info.center_x - (width * 0.5), info.start_y

	draw.Color(67, 76, 94, 255)
	draw.FilledRect(x, y, x + width, y + height)

	draw.Color(236, 239, 244, 255)
	draw.FilledRect(x, y, x + (width * cloak_ratio) // 1, y + height)

	info.start_y = info.start_y + y + height + 5
end

return spy
