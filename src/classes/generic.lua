local generic = {}

local health_unformatted = "%s / %s"
local ammo_unformatted = "%s / %s"

---@param info Info
---@param current_weapon Entity
---@param utils Utils
function generic:Run(plocal, current_weapon, info, utils)
	local health = plocal:GetHealth()
	local max_health = plocal:GetMaxHealth()
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

	if not current_weapon:IsMeleeWeapon() then
		local is_primary = current_weapon:GetLoadoutSlot() == E_LoadoutSlot.LOADOUT_POSITION_PRIMARY
		local ammo_datatable = plocal:GetPropDataTableInt("m_iAmmo")
		local clip1 = current_weapon:GetPropInt("m_iClip1")
		local primary_clip2, secondary_clip2 = ammo_datatable[2], ammo_datatable[3]

		local ammo_text = ""

		if clip1 ~= -1 and clip1 then
			ammo_text = is_primary and string.format(ammo_unformatted, clip1, primary_clip2)
				or string.format(ammo_unformatted, clip1, secondary_clip2)
		else
			ammo_text = string.format("%s", primary_clip2)
		end

		local ammo_w, ammo_h = draw.GetTextSize(ammo_text)
		utils.DrawText({ 180, 142, 173 }, info.center_x - (ammo_w // 2), info.start_y, ammo_text)

		info.start_y = info.start_y + ammo_h + 5
	end

	--- crit bar
	if current_weapon:CanRandomCrit() then
		---  stuff "borrowed" from the docs
		local critChance = current_weapon:GetCritChance()
		local dmgStats = current_weapon:GetWeaponDamageStats()
		local totalDmg = dmgStats["total"]
		local criticalDmg = dmgStats["critical"]

		-- (the + 0.1 is always added to the comparsion)
		local cmpCritChance = critChance + 0.1
		---

		local crit_ratio = 0

		-- If we are allowed to crit
		if cmpCritChance > current_weapon:CalcObservedCritChance() then
			crit_ratio = current_weapon:GetCritTokenBucket() / 1000
			local x, y, width, height
			width, height = 100, 10
			x, y = info.center_x - (width // 2), info.start_y

			draw.Color(67, 76, 94, 255)
			draw.FilledRect(x, y, x + width, y + height)

			draw.Color(236, 239, 244, 255)
			draw.FilledRect(x, y, x + (width * crit_ratio) // 1, y + height)
			info.start_y = info.start_y + height + 5
		else --Figure out how much damage we need
			local requiredTotalDamage = (criticalDmg * (2.0 * cmpCritChance + 1.0)) / cmpCritChance / 3.0
			local requiredDamage = requiredTotalDamage - totalDmg
			local text = string.format("required damage: %.0f", requiredDamage)
			local tw = draw.GetTextSize(text)

			utils.DrawText(nil, info.center_x - (tw // 2), info.start_y, text)
			info.start_y = info.start_y + info.font_size + 5
		end

		---
	end
end

return generic
