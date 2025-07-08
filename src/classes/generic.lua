local generic = {}

local health_unformatted = "%s / %s"
local ammo_unformatted = "%s / %s"

---@param pLocal Entity
---@param utils Utils
---@param info Info
local function DrawHealth(pLocal, utils, info)
	local health = pLocal:GetHealth()
	local max_health = pLocal:GetMaxHealth()
	local health_ratio = health / max_health

	local health_text = string.format(health_unformatted, health, max_health)
	local health_w, health_h = draw.GetTextSize(health_text)
	local health_x = info.center_x - (health_w // 2)

	if health_ratio >= 0.5 then
		utils.DrawText({ 163, 190, 140 }, health_x, info.start_y, health_text)
	else
		utils.DrawText({ 191, 97, 106 }, health_x, info.start_y, health_text)
	end

	info.start_y = info.start_y + health_h + 5
end

---@param pLocal Entity
---@param pWeapon Entity
---@param info Info
---@param utils Utils
local function DrawMeleeWeapon(pLocal, pWeapon, info, utils)
	local ammo_datatable = pLocal:GetPropDataTableInt("m_iAmmo")
	local clip1 = pWeapon:GetPropInt("m_iClip1")
	local primary_clip2, secondary_clip2 = ammo_datatable[2], ammo_datatable[3]

	local ammo_text = ""

	if clip1 ~= -1 and clip1 then
		if pWeapon:GetLoadoutSlot() == E_LoadoutSlot.LOADOUT_POSITION_PRIMARY then
			ammo_text = string.format(ammo_unformatted, clip1, primary_clip2)
		else
			ammo_text = string.format(ammo_unformatted, clip1, secondary_clip2)
		end
	else
		ammo_text = string.format("%s", primary_clip2)
	end

	local ammo_w, ammo_h = draw.GetTextSize(ammo_text)
	utils.DrawText({ 180, 142, 173 }, info.center_x - (ammo_w // 2), info.start_y, ammo_text)

	info.start_y = info.start_y + ammo_h + 5
end

---@param pWeapon Entity
---@param info Info
---@param utils Utils
local function DrawCritBar(pWeapon, info, utils)
	local critChance = pWeapon:GetCritChance()
	local dmgStats = pWeapon:GetWeaponDamageStats()

	-- (the + 0.1 is always added to the comparison)
	local cmpCritChance = critChance + 0.1

	local crit_ratio = 0

	-- If we are allowed to crit
	if cmpCritChance > pWeapon:CalcObservedCritChance() then
		crit_ratio = pWeapon:GetCritTokenBucket() / 1000
		local x, y, width, height
		width, height = 100, 10
		x, y = info.center_x - (width // 2), info.start_y

		draw.Color(67, 76, 94, 255)
		draw.FilledRect(x, y, x + width, y + height)

		draw.Color(236, 239, 244, 255)
		draw.FilledRect(x, y, x + (width * crit_ratio) // 1, y + height)

		info.start_y = info.start_y + height + 5
	else --Figure out how much damage we need
		local totalDmg = dmgStats["total"]
		local criticalDmg = dmgStats["critical"]
		local requiredTotalDamage = (criticalDmg * (2.0 * cmpCritChance + 1.0)) / cmpCritChance / 3.0
		local requiredDamage = requiredTotalDamage - totalDmg
		local text = string.format("required damage: %.0f", requiredDamage)
		local tw = draw.GetTextSize(text)

		utils.DrawText(nil, info.center_x - (tw // 2), info.start_y, text)
		info.start_y = info.start_y + info.font_size + 5
	end
end

---@param info Info
---@param pWeapon Entity
---@param utils Utils
function generic:Run(pLocal, pWeapon, info, utils)
	DrawHealth(pLocal, utils, info)

	if not pWeapon:IsMeleeWeapon() then
		DrawMeleeWeapon(pLocal, pWeapon, info, utils)
	end

	--- crit bar
	if pWeapon:CanRandomCrit() then
		DrawCritBar(pWeapon, info, utils)
	end
end

return generic
