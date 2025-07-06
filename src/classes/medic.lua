local medic = {}

---@param plocal Entity
---@param current_weapon Entity
---@param info Info
---@param utils Utils
function medic:Run(plocal, current_weapon, info, utils)
	local medigun = plocal:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY)
	local charge_level = medigun:GetPropFloat("LocalTFWeaponMedigunData", "m_flChargeLevel") --- 0 to max_charge
	local max_charge = medigun:AttributeHookFloat("mult_medigun_uberchargerate")
	local charge_ratio = charge_level / max_charge
	local width, height, x, y

	width, height = 100, 10
	x, y = info.center_x - (width * 0.5), info.start_y

	draw.Color(67, 76, 94, 255)
	draw.FilledRect(x, y, x + width, y + height)

	if charge_ratio >= 1 then
		draw.Color(143, 188, 187, 255)
	else
		draw.Color(236, 239, 244, 255)
	end

	draw.FilledRect(x, y, x + (width * charge_ratio) // 1, y + height)

	info.start_y = info.start_y + height + 5

	if
		current_weapon:GetLoadoutSlot() == E_LoadoutSlot.LOADOUT_POSITION_SECONDARY
		and current_weapon:GetPropBool("m_bHealing")
	then
		local heal_target = current_weapon:GetPropEntity("m_hHealingTarget")
		if heal_target then
			y = info.start_y
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
end

return medic
