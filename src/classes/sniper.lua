local sniper = {}

---@param pWeapon Entity
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param info Info
local function DrawChargedBar(pWeapon, x, y, width, height, info)
	local MACHINA_INDEX = 526
	local multiplier = pWeapon:GetPropInt("m_Item", "m_iItemDefinitionIndex") == MACHINA_INDEX and 1.15 or 1
	local current_charge = pWeapon:GetPropFloat("SniperRifleLocalData", "m_flChargedDamage")
	local max_charge = 150 * multiplier
	local charge_ratio = current_charge / max_charge

	--- sniper charge
	draw.Color(67, 76, 94, 255)
	draw.FilledRect(x, y, x + width, y + height)

	draw.Color(236, 239, 244, 255)
	draw.FilledRect(x, y, x + (width * charge_ratio) // 1, y + height)

	info.start_y = info.start_y + height + 5
end

---@param pLocal Entity
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param info Info
local function DrawJarateBar(pLocal, x, y, width, height, info)
	local last_firetime =
		pLocal:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY):GetPropFloat("m_flLastFireTime")

	local jarate_ratio = 0

	if pLocal:GetPropDataTableInt("m_iAmmo")[5] == 1 then
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

---@param pLocal Entity
---@param pWeapon Entity
---@param info Info
---@param utils Utils
function sniper:Run(pLocal, pWeapon, info, utils)
	local width, height = 100, 10
	local x, y = info.center_x - (width * 0.5), info.start_y

	if pLocal:InCond(E_TFCOND.TFCond_Zoomed) then
		DrawChargedBar(pWeapon, x, y, width, height, info)
	end

	--- jarate
	DrawJarateBar(pLocal, x, y, width, height, info)
end

return sniper
