local spectate = {}

---@param pLocal Entity
---@param info Info
---@param utils Utils
function spectate:Run(pLocal, info, utils)
	if not pLocal:IsAlive() then
		local start_y = info.screen_h // 6
		local m_hObserverTarget = pLocal:GetPropEntity("m_hObserverTarget")

		if m_hObserverTarget then
			local text_w, text_h = draw.GetTextSize("spectating")
			utils.DrawText(nil, info.center_x - (text_w // 2), start_y, "spectating")

			start_y = start_y + text_h + 5

			local name = m_hObserverTarget:GetName()
			name = name == "" and string.format("entity index: %i", m_hObserverTarget:GetIndex()) or name

			text_w, text_h = draw.GetTextSize(name)
			utils.DrawText(nil, info.center_x - (text_w // 2), start_y, name)

			start_y = start_y + text_h + 5
		end

		local resources = entities.GetPlayerResources()
		if resources then
			local lp_res = resources:GetPropDataTableFloat("m_flNextRespawnTime")[
				pLocal:GetIndex() + 1 --[[ wtf? is this because 1 is CWorld? not sure ]]
			]
			local text = string.format("respawn in %i seconds", (lp_res - globals.CurTime()) // 1)
			local text_w = draw.GetTextSize(text)
			utils.DrawText(nil, info.center_x - (text_w // 2), start_y, text)
			start_y = start_y + info.font_size + 5
		end

		return true
	end

	return false
end

return spectate
