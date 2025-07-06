local engineer = {}

---@param plocal Entity
---@param current_weapon Entity
---@param info Info
---@param utils Utils
function engineer:Run(plocal, current_weapon, info, utils)
	local ammo_datatable = plocal:GetPropDataTableInt("m_iAmmo")
	local quantity = ammo_datatable[4]
	local text = string.format("%i / 200", quantity)
	local metal_w, metal_h = draw.GetTextSize(text)

	utils.DrawText({ 235, 203, 139 }, info.center_x - (metal_w // 2), info.start_y, text)

	info.start_y = info.start_y + metal_h + 10

	if current_weapon:GetLoadoutSlot() == 3 or current_weapon:GetLoadoutSlot() == 4 then
		--- really stupid
		--- and not memory efficient
		--- but we have modern hardware with 4+ gb of ram so fuck it
		local buildings = { "sentry", "dispenser", "teleporter", "teleporter exit" }
		local has_buildings = { false, false, false, false }

		local total_size = 0

		for i = 1, 4 do
			local w = draw.GetTextSize(buildings[i])
			total_size = (total_size + w) // 1
		end

		local text_x = info.center_x - (total_size // 2)
		local text_y = info.start_y

		local plocal_index = plocal:GetIndex()

		for _, sentry in pairs(entities.FindByClass("CObjectSentrygun")) do
			local builder = sentry:GetPropEntity("m_hBuilder")
			if builder and builder:GetIndex() == plocal_index then
				has_buildings[1] = true
				break
			end
		end

		for _, dispenser in pairs(entities.FindByClass("CObjectDispenser")) do
			local builder = dispenser:GetPropEntity("m_hBuilder")
			if builder and builder:GetIndex() == plocal_index then
				has_buildings[2] = true
				break
			end
		end

		for _, tele in pairs(entities.FindByClass("CObjectTeleporter")) do
			local builder = tele:GetPropEntity("m_hBuilder")
			if builder and builder:GetIndex() == plocal_index then
				local exit = tele:GetPropInt("m_iObjectMode") == 1
				if exit then
					has_buildings[4] = true
				else
					has_buildings[3] = true
				end
			end
		end

		for i = 1, 4 do
			local text_w, text_h = draw.GetTextSize(buildings[i])

			utils.DrawText(nil, text_x, text_y, buildings[i])

			local number = tostring(i)
			local number_w, number_h = draw.GetTextSize(number) --- fucking stupid
			local number_x, number_y
			number_x = text_x + (text_w // 2) - (number_w // 2)
			number_y = text_y + (text_h // 1) + 5

			utils.DrawText(nil, number_x, number_y, number)

			if has_buildings[i] then
				local w, h = draw.GetTextSize("(built)")
				local x, y
				x = text_x + (text_w // 2) - (w // 2)
				y = number_y + number_h + 5
				utils.DrawText(nil, x, y, "(built)")
			end

			text_x = text_x + (text_w // 1) + 5
		end

		info.start_y = info.start_y + info.font_size + 5
	end
end

return engineer
