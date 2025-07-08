local medic = {}

---@param pLocal Entity
---@param info Info
local function DrawUberChargeBar(pLocal, info, x, y, width, height)
	local medigun = pLocal:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY)
	local charge_level = medigun:GetPropFloat("LocalTFWeaponMedigunData", "m_flChargeLevel") --- [0, $max_charge]
	local max_charge = medigun:AttributeHookFloat("mult_medigun_uberchargerate")
	local charge_ratio = charge_level / max_charge

	draw.Color(67, 76, 94, 255)
	draw.FilledRect(x, y, x + width, y + height)

	if charge_ratio >= 1 then
		draw.Color(143, 188, 187, 255)
	else
		draw.Color(236, 239, 244, 255)
	end

	draw.FilledRect(x, y, x + (width * charge_ratio) // 1, y + height)

	info.start_y = info.start_y + height + 5
end

---@param pWeapon Entity
---@param info Info
---@param x integer
---@param y integer
---@param width integer
---@param height integer
local function DrawHealingBar(pWeapon, info, x, y, width, height)
	local heal_target = pWeapon:GetPropEntity("m_hHealingTarget")
	if heal_target then
		local heal_ratio = 0
		local over_ratio = 0

		if (heal_target:GetHealth() / heal_target:GetMaxHealth()) > 1 then
			over_ratio = (heal_target:GetHealth() - heal_target:GetMaxHealth())
				/ (heal_target:GetMaxBuffedHealth() - heal_target:GetMaxHealth())

			heal_ratio = math.min(heal_target:GetHealth() / heal_target:GetMaxHealth(), 1)
		else
			heal_ratio = heal_target:GetHealth() / heal_target:GetMaxHealth()
		end

		draw.Color(67, 76, 94, 255)
		draw.FilledRect(x, y, x + width, y + height)

		draw.Color(236, 239, 244, 255)
		draw.FilledRect(x, y, x + (width * heal_ratio) // 1, y + height)

		draw.Color(136, 192, 208, 255)
		draw.FilledRect(x, y, x + (width * over_ratio) // 1, y + height)

		info.start_y = info.start_y + height + 5
	end
end

---@param pLocal Entity
---@param pWeapon Entity
---@param info Info
---@param utils Utils Not used here, but to be consistent
function medic:Run(pLocal, pWeapon, info, utils)
	local width, height, x, y

	width, height = 100, 10
	x, y = info.center_x - (width * 0.5), info.start_y

	DrawUberChargeBar(pLocal, info, x, y, width, height)

	if pWeapon:GetLoadoutSlot() == E_LoadoutSlot.LOADOUT_POSITION_SECONDARY and pWeapon:GetPropBool("m_bHealing") then
		DrawHealingBar(pWeapon, info, x, info.start_y, width, height)
	end
end

return medic
