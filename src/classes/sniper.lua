local sniper = {}

---@param plocal Entity
---@param current_weapon Entity
---@param info Info
---@param utils Utils
function sniper:Run(plocal, current_weapon, info, utils)
	local width, height = 100, 10
	local x, y = info.center_x - (width * 0.5), info.start_y
	if plocal:InCond(E_TFCOND.TFCond_Zoomed) then
		local MACHINA_INDEX = 526
		local multiplier = current_weapon:GetPropInt("m_Item", "m_iItemDefinitionIndex") == MACHINA_INDEX and 1.15 or 1
		local current_charge = current_weapon:GetPropFloat("SniperRifleLocalData", "m_flChargedDamage")
		local max_charge = 150 * multiplier
		local charge_ratio = current_charge / max_charge

		--- sniper charge
		draw.Color(67, 76, 94, 255)
		draw.FilledRect(x, y, x + width, y + height)

		draw.Color(236, 239, 244, 255)
		draw.FilledRect(x, y, x + (width * charge_ratio) // 1, y + height)

		info.start_y = info.start_y + height + 5
	end

	--- jarate
	local last_firetime =
		plocal:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY):GetPropFloat("m_flLastFireTime")

	local jarate_ratio = 0

	if plocal:GetPropDataTableInt("m_iAmmo")[5] == 1 then
		jarate_ratio = 1
	else
		jarate_ratio = math.min((globals.CurTime() - last_firetime) / 20, 1) --- clamp to max 1
	end

	y = info.start_y

	draw.Color(67, 76, 94, 255)
	draw.FilledRect(x, y, x + width, y + height)

	draw.Color(235, 203, 139, 255)
	draw.FilledRect(x, y, x + (width * jarate_ratio) // 1, y + height)

	info.start_y = info.start_y + height + 5
end

return sniper
