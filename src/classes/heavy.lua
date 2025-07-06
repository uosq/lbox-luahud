local heavy = {}

---@param plocal Entity
---@param current_weapon Entity
---@param info Info
---@param utils Utils
function heavy:Run(plocal, current_weapon, info, utils)
	local sandvich = plocal:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY)
	if sandvich and sandvich:GetClass() == "CTFLunchBox" then
		local width, height, x, y
		local ready = plocal:GetPropDataTableInt("m_iAmmo")[5] == 1
		local text = ready and "sandvich ready" or "sandvich not ready"

		width, height = draw.GetTextSize(text)
		x, y = info.center_x - (width // 2), info.start_y

		if ready then
			utils.DrawText({ 143, 188, 187 }, x, y, text)
		else
			utils.DrawText({ 191, 97, 106 }, x, y, text)
		end

		info.start_y = info.start_y + height + 5
	end
end

return heavy
