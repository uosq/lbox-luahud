local demo = {}

---@param pLocal Entity
---@param pWeapon Entity
---@param info Info
---@param utils Utils
function demo:Run(pLocal, pWeapon, info, utils)
	if pWeapon:GetClass() == "CTFPipebombLauncher" then
		local width, height, x, y
		width, height = 100, 10
		x, y = info.center_x - (width // 2), info.start_y

		local MAX_CHARGE_STOCK = 4 --- seconds
		local MAX_CHARGE_QUICKIE = 1.2 --- seconds

		--- not sure if this works
		local chosen_max = pWeapon:AttributeHookFloat("sticky_arm_time") == 1 and MAX_CHARGE_STOCK or MAX_CHARGE_QUICKIE

		local charge_ratio = (
			globals.CurTime() - pWeapon:GetPropFloat("PipebombLauncherLocalData", "m_flChargeBeginTime")
		) / chosen_max

		if charge_ratio > chosen_max then
			charge_ratio = 0
		end

		draw.Color(67, 76, 94, 255)
		draw.FilledRect(x, y, x + width, y + height)

		draw.Color(236, 239, 244, 255)
		draw.FilledRect(x, y, x + (width * charge_ratio) // 1, y + height)

		info.start_y = info.start_y + height + 5
	end

	local sticky_count = pLocal
		:GetEntityForLoadoutSlot(E_LoadoutSlot.LOADOUT_POSITION_SECONDARY)
		:GetPropInt("PipebombLauncherLocalData", "m_iPipebombCount")

	local sticky_text = tostring(sticky_count)
	local sticky_w, sticky_h = draw.GetTextSize(sticky_text)

	utils.DrawText(nil, info.center_x - (sticky_w // 2), info.start_y, sticky_text)

	info.start_y = info.start_y + sticky_h + 5
end

return demo
